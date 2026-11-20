"""Acceptance checks for fixture parity, boundaries, and evidence arbitration."""

from __future__ import annotations

import json
import unittest
from pathlib import Path
from unittest.mock import patch

from fastapi.testclient import TestClient

import app as api
from engine.hybrid import Hybrid


ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "tests" / "fixtures"
ASSETS = ROOT / "engine" / "assets"


class SmartNanoFormulatorApiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.engine = Hybrid(ASSETS)
        cls.client = TestClient(api.app)

    def _post_with_engine(self, path: str, payload: dict):
        with patch("app.ready_engine", return_value=self.engine):
            return self.client.post(path, json=payload)

    @staticmethod
    def _load(name: str):
        return json.loads((FIXTURES / name).read_text())

    def _assert_fixture(self, response, expected):
        self.assertEqual(response.status_code, 200, response.text)
        body = response.json()
        self.assertEqual(body["request_id"], response.headers["X-Request-ID"])
        self.assertEqual(body["api_version"], api.API_VERSION)
        self.assertEqual(body["request"], expected["request"])
        self.assertEqual(set(body["results"]), set(expected["results"]))
        for endpoint, expected_result in expected["results"].items():
            actual = body["results"][endpoint]
            self.assertEqual(actual["decision"], expected_result["decision"])
            self.assertEqual(actual["model"]["status"], expected_result["model"]["status"])
            for key in ("value", "unit", "formation_score", "grouped_cv_mae"):
                if key in expected_result["model"]:
                    self.assertEqual(actual["model"].get(key), expected_result["model"][key])
            self.assertEqual(
                [item["id"] for item in actual["evidence"]],
                [item["id"] for item in expected_result["evidence"]],
            )
        return body

    def test_health_reports_releases(self):
        with patch("app.ready_engine", return_value=self.engine):
            response = self.client.get("/healthz")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "ready")
        self.assertTrue(response.json()["model_release"])
        self.assertTrue(response.json()["corpus_release"])

    def test_archived_process_case(self):
        request = self._load("process.json")
        expected = self._load("process_result.json")
        response = self._post_with_engine("/v1/process-assessments", request)
        body = self._assert_fixture(response, expected)
        self.assertEqual(body["results"]["size"]["model"]["value"], 461.4)
        self.assertEqual(body["results"]["pdi"]["model"]["value"], 0.1425)
        self.assertEqual(body["results"]["formation"]["model"]["value"], 1.0)
        self.assertEqual(body["results"]["formation"]["model"]["unit"], "uncalibrated score")

    def test_archived_celecoxib_case_keeps_target_and_measurement_separate(self):
        request = self._load("celecoxib.json")
        expected = self._load("celecoxib_result.json")
        response = self._post_with_engine("/v1/formulation-assessments", request)
        body = self._assert_fixture(response, expected)
        self.assertEqual(body["request"]["desired_release"], {"hours": 24, "percent": 65})
        entr = body["results"]["entrapment"]
        self.assertEqual(entr["decision"], "literature_candidate")
        self.assertEqual(entr["evidence"][0]["measurements"]["entrapment"], {"value": 54.4, "unit": "%"})
        release = body["results"]["release"]
        self.assertEqual(release["decision"], "background_only")
        self.assertNotIn("value", release["model"])

    def test_archived_evidence_gap_case(self):
        request = self._load("gap.json")
        expected = self._load("gap_result.json")
        body = self._assert_fixture(
            self._post_with_engine("/v1/formulation-assessments", request), expected
        )
        for endpoint in ("ratios", "release", "tissue"):
            self.assertEqual(body["results"][endpoint]["decision"], "insufficient_evidence")
            self.assertEqual(body["results"][endpoint]["evidence"], [])

    def test_invalid_unknown_fields_return_contract_error(self):
        response = self._post_with_engine(
            "/v1/formulation-assessments",
            {"drug": "celecoxib", "route": "topical", "tissue": "skin", "targets": ["release"], "surprise": True},
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()["code"], "INVALID_REQUEST")
        self.assertEqual(response.json()["request_id"], response.headers["X-Request-ID"])
        self.assertIn("fields", response.json())

    def test_invalid_process_composition_returns_contract_error(self):
        request = self._load("process.json")
        request["candidate"]["cholesterol_pct"] = 80
        request["candidate"]["peg_pct"] = 30
        response = self._post_with_engine("/v1/process-assessments", request)
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()["code"], "INVALID_REQUEST")

    def test_unseen_lipid_chip_pairing_is_a_normal_out_of_scope_result(self):
        request = self._load("process.json")
        request["targets"] = ["size"]
        request["candidate"]["primary_lipid"] = "UNSEEN-LIPID"
        response = self._post_with_engine("/v1/process-assessments", request)
        self.assertEqual(response.status_code, 200, response.text)
        result = response.json()["results"]["size"]
        self.assertEqual(result["decision"], "background_only")
        self.assertEqual(result["model"]["status"], "out_of_scope")
        self.assertIn("pairing is absent", result["model"]["reason"])

    def test_synthetic_independent_measurement_exercises_conflict_review(self):
        request = self._load("process.json")
        request["targets"] = ["size"]
        request["assay"] = "synthetic-independent-assay"
        expected_size = self.engine.answer({**request, "carrier": "liposome", "model_family": "eugster"})["results"]["size"]["model"]
        source = next(doc for doc in self.engine.docs if doc["id"] == "eugster-process")
        source.pop("training_source", None)
        source["id"] = "synthetic-conflict-test"
        source["title"] = "Synthetic test-only independent measurement (not a publication)"
        source["url"] = "https://example.org/synthetic-conflict-test"
        source["text"] = "Synthetic test fixture used only to exercise the conflict review path."
        source["limitation"] = "Synthetic test-only evidence; never included in a release corpus."
        source["locator"] = "unit test fixture"
        source["independently_verified"] = True
        source["candidate"] = request["candidate"]
        source["assay"] = request["assay"]
        source.setdefault("measurements", {})["size"] = {
            "value": expected_size["value"] + expected_size["grouped_cv_absolute_error_p90"] + 10,
            "unit": "nm",
        }
        response = self._post_with_engine("/v1/process-assessments", request)
        self.assertEqual(response.status_code, 200, response.text)
        result = response.json()["results"]["size"]
        self.assertEqual(result["decision"], "conflicting_evidence")
        comparison = next(item for item in result["evidence"] if item["id"] == "synthetic-conflict-test")
        self.assertEqual(comparison["comparison"], "discordant")
        self.assertIn("beyond the grouped-CV error screen", result["rationale"])

    def test_nonfinite_process_values_return_validation_error(self):
        request = self._load("process.json")
        request["candidate"]["tfr_ml_min"] = float("nan")
        # HTTPX's JSON encoder rejects NaN before sending the request.
        response = self.client.post(
            "/v1/process-assessments",
            content=json.dumps(request),
            headers={"Content-Type": "application/json"},
        )
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()["code"], "INVALID_REQUEST")


if __name__ == "__main__":
    unittest.main()
