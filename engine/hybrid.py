"""SmartNanoFormulator evidence retrieval and model arbitration."""
import argparse
import csv
from functools import cached_property, lru_cache
import json
import math
from pathlib import Path
import re

import joblib
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer

TARGETS = ("carrier","excipients","ratios","batches","size","pdi","zeta",
           "entrapment","release","formation","tissue","stability","bioavailability")
DRUG_FILES = {"size":"size_nm","pdi":"pdi","zeta":"zeta_mv","entrapment":"ee_pct",
              "release":"observed_release_24h_pct"}
UNITS = {"size":"nm","pdi":"unitless","zeta":"mV","entrapment":"%","release":"%","formation":"score"}
KINDS = {"experimental","comparative study"}


def norm(value):
    return " ".join(str(value or "").lower().split())


def comparable(record, request):
    return bool(record.get("drug") and record.get("route") and
                norm(record["drug"]) == norm(request.get("drug")) and
                norm(record["route"]) == norm(request.get("route")) and
                (not request.get("tissue") or norm(record.get("tissue")) == norm(request["tissue"])) and
                (not request.get("carrier") or norm(record.get("carrier")) == norm(request["carrier"])))


def decide(model, evidence):
    direct = [doc for doc in evidence if doc["applicability"] == "matched_drug_and_route"]
    comparisons = [doc for doc in evidence if doc.get("comparison") is not None]
    if any(doc["comparison"] == "discordant" for doc in comparisons):
        return "conflicting_evidence", "Comparable source measurement differs from the estimate beyond the grouped-CV error screen."
    if model.get("status") == "process_estimate":
        return "model_estimate", ("Sample-level comparison available." if comparisons else
                                  "No matched independent measurement for this candidate. Literature provides context.")
    if direct:
        return "literature_candidate", "A source matches the drug and route. Results apply to the reported experiment."
    if evidence:
        return "background_only", "Retrieved sources can guide experimental design. Candidate-specific results remain unresolved."
    return "insufficient_evidence", "The corpus has no applicable evidence for this output."


class Hybrid:
    def __init__(self, root):
        self.root = root
        self.docs = json.loads((root / "evidence.json").read_text())
        if not self.docs or len({doc["id"] for doc in self.docs}) != len(self.docs):
            raise ValueError("Evidence corpus must contain unique document IDs.")
        self.vectorizer = TfidfVectorizer(ngram_range=(1,2), sublinear_tf=True)
        self.index = self.vectorizer.fit_transform(
            [" ".join([d["title"],d["text"],d.get("drug",""),d.get("route",""),
                       d.get("tissue",""),d.get("carrier",""),*d["topics"]]) for d in self.docs])
        self.process_metrics = json.loads((root / "process_results.json").read_text())
        with (root / "drug_metrics.csv").open(newline="") as handle:
            self.drug_metrics = list(csv.DictReader(handle))

    @cached_property
    def process_rows(self):
        with (self.root / "process_training.csv").open(newline="") as handle:
            return list(csv.DictReader(handle))

    @lru_cache(maxsize=10)
    def artifact(self, name):
        return joblib.load(self.root / "models" / f"{name}.joblib")

    @lru_cache(maxsize=2)
    def error_scale(self, name):
        with (self.root / f"eugster_{name}_grouped_predictions.csv").open(newline="") as handle:
            errors = [abs(float(row["actual"])-float(row["selected_prediction"])) for row in csv.DictReader(handle)]
        return float(np.quantile(errors, .90, method="higher"))

    def retrieve(self, request, target):
        query = " ".join([target,*(norm(request.get(k)) for k in ("drug","carrier","route","tissue"))])
        similarity = (self.index @ self.vectorizer.transform([query]).T).toarray().ravel()
        ranked = []
        family = request.get("model_family","drug")
        for doc,sim in zip(self.docs,similarity):
            if target not in doc["topics"]:
                continue
            match = comparable(doc,request) and doc["kind"] in KINDS
            if doc.get("drug") and request.get("drug") and norm(doc["drug"]) != norm(request["drug"]):
                continue
            if doc.get("route") and request.get("route") and norm(doc["route"]) != norm(request["route"]):
                continue
            if doc.get("tissue") and request.get("tissue") and norm(doc["tissue"]) != norm(request["tissue"]):
                continue
            if doc.get("carrier") and request.get("carrier") and norm(doc["carrier"]) != norm(request["carrier"]):
                continue
            label = "matched_drug_and_route" if match else "background_or_analogue"
            reused = bool(doc.get("training_source") and doc["training_source"] == family)
            ranked.append((match,float(sim),doc["id"],{**doc,"applicability":label,
                "independence":"training_source" if reused else "training_overlap_unverified"}))
        ranked.sort(key=lambda item:(-int(item[0]),-item[1],item[2]))
        return [item[3] for item in ranked[:3]]

    def regression(self, request, target):
        family = request.get("model_family","drug")
        if family == "drug":
            field = DRUG_FILES.get(target)
            if field is None:
                return {"status":"unsupported_endpoint","reason":"No trained estimator for this output."}
            rows = [r for r in self.drug_metrics if r["target"] == field]
            benchmark = [{"grouping":r["grouping"],"mae":float(r["mae"]),
                          "median_mae":float(r["median_mae"]),"n":int(r["n"])} for r in rows]
            return {"status":"withheld","reason":"The screened drug model did not show lower MAE than the median on held-out studies.",
                    "benchmark":benchmark}
        if any(request.get(field) for field in ("drug","route","tissue","desired_release")):
            return {"status":"out_of_scope","reason":"The process cohort cannot support a drug-, route-, tissue-, or release-specific claim."}
        if request.get("carrier","liposome") != "liposome":
            return {"status":"out_of_scope","reason":"The process models cover liposomes."}
        if family == "smart_microfluidics":
            return {"status":"withheld","reason":"The selected size and PDI regressors did not beat the median MAE on the wet-lab holdout."}
        if target not in ("size","pdi","formation"):
            return {"status":"unsupported_endpoint","reason":"This process model covers formation, size and PDI."}
        name = DRUG_FILES.get(target,"formation")
        bundle = self.artifact(f"eugster_{name}")
        candidate = request.get("candidate") or {}
        fields = bundle["inputs"]
        categories = ("primary_lipid","chip")
        missing = [f for f in fields if f not in candidate]
        if missing:
            return {"status":"missing_inputs","missing":missing}
        try:
            values = {f:float(candidate[f]) for f in fields if f not in categories}
        except (ValueError,TypeError):
            return {"status":"invalid_inputs","reason":"Expected numeric process values."}
        if not all(math.isfinite(v) for v in values.values()):
            return {"status":"invalid_inputs","reason":"Process inputs must be finite."}
        if values["cholesterol_pct"]+values["peg_pct"] > 100:
            return {"status":"invalid_inputs","reason":"Cholesterol and PEG percentages exceed 100% combined."}
        subset = [r for r in self.process_rows if r["role"] in ("formation_pass","formation_screen_only")
                  and all(r[f] == candidate[f] for f in categories)]
        if not subset:
            return {"status":"out_of_scope","reason":"This lipid and chip pairing is absent from training."}
        if any(not min(float(r[f]) for r in subset)<=v<=max(float(r[f]) for r in subset)
               for f,v in values.items()):
            return {"status":"out_of_scope","reason":"A process value falls outside the observed range for this lipid and chip."}
        in_settings = any(all(math.isclose(float(r[f]),v,rel_tol=1e-7,abs_tol=1e-7) for f,v in values.items()) for r in subset)
        formation = self.artifact("eugster_formation")["estimator"]
        matrix = np.array([[values.get(f,candidate[f]) for f in fields]],dtype=object)
        score = float(formation.predict_proba(matrix)[0,1])
        if target == "formation":
            return {"status":"process_estimate","value":round(score,4),"unit":"uncalibrated score",
                    "support":"observed settings" if in_settings else "within marginal ranges"}
        if score < .5:
            return {"status":"withheld","reason":"Formation classifier score is below its evaluated decision threshold.",
                    "formation_score":round(score,4)}
        predictor = bundle["estimator"]
        estimate = float(predictor.predict(matrix)[0])
        q = self.error_scale(name)
        return {"status":"process_estimate","value":round(estimate,4),"unit":UNITS[target],
                "support":"observed settings" if in_settings else "within marginal ranges",
                "formation_score":round(score,4),
                "grouped_cv_mae":next(r["grouped_nested_cv"]["selected"]["mae"] for r in self.process_metrics["regression"]
                                      if r["cohort"]=="eugster" and r["target"]==name),
                "grouped_cv_absolute_error_p90":round(q,4),
                "limitation":"Conditional on formation. Grouped CV error describes this cohort; it is not a calibrated prediction interval."}

    def answer(self, request):
        if not isinstance(request,dict):
            raise ValueError("Request must be a JSON object.")
        if request.get("model_family","drug") not in {"drug","eugster","smart_microfluidics"}:
            raise ValueError("Unknown model_family.")
        targets = request.get("targets",list(TARGETS))
        if not isinstance(targets,list) or not targets or any(t not in TARGETS for t in targets):
            raise ValueError("targets must be a nonempty list of supported output names.")
        if request.get("candidate") is not None and not isinstance(request["candidate"],dict):
            raise ValueError("candidate must be a JSON object.")
        for field in ("drug","route","tissue","carrier","assay"):
            if request.get(field) is not None and not isinstance(request[field],str):
                raise ValueError(f"{field} must be text.")
        if request.get("carrier"):
            request = {**request,"carrier":norm(request["carrier"])}
        results = {}
        for t in targets:
            model = self.regression(request,t)
            evidence = self.retrieve(request,t)
            for doc in evidence:
                measurement = doc.get("measurements",{}).get(t)
                if not measurement:
                    continue
                # Comparisons require reviewed matching settings, assay, and units.
                settings_match = bool(doc.get("candidate") and doc["candidate"] == request.get("candidate"))
                assay_match = bool(doc.get("assay") and doc["assay"] == request.get("assay"))
                if (doc["independence"] == "training_overlap_unverified" and doc.get("independently_verified")
                    and settings_match and assay_match and measurement["unit"] == model.get("unit")
                    and "grouped_cv_absolute_error_p90" in model):
                    delta = abs(measurement["value"] - model["value"])
                    doc["comparison"] = ("discordant" if delta > model["grouped_cv_absolute_error_p90"]
                                         else "within_error_screen")
            decision, reason = decide(model,evidence)
            basis = {"model_estimate":"in-domain benchmark support",
                     "literature_candidate":"study-specific evidence",
                     "background_only":"indirect evidence",
                     "conflicting_evidence":"review required",
                     "insufficient_evidence":"insufficient"}[decision]
            results[t] = {"decision":decision,"confidence_basis":basis,"rationale":reason,
                          "model":model,"evidence":evidence}
        return {"request":request,"results":results,
                "method":"Extractive literature retrieval and rule-based adjudication. Evidence relevance and model error are reported separately."}


def render(result):
    sections = {"model_estimate":"Process estimate","literature_candidate":"Literature candidate",
                "conflicting_evidence":"Conflicting evidence","background_only":"Background evidence","insufficient_evidence":"Insufficient evidence"}
    lines = ["# SmartNanoFormulator evidence assessment",""]
    for target,item in result["results"].items():
        lines.append(f"## {target.capitalize()} | {sections[item['decision']]}")
        lines.append(f"- Evidence assessment: {item['confidence_basis']}. {item['rationale']}")
        model = item["model"]
        if model["status"] == "process_estimate":
            lines.append(f"- Model output: **{model['value']} {model['unit']}** ({model['support']}).")
            if "grouped_cv_absolute_error_p90" in model:
                lines.append(f"- Grouped-CV MAE: {model['grouped_cv_mae']:.4g}. The 90th percentile of absolute error was {model['grouped_cv_absolute_error_p90']}. {model['limitation']}")
        elif model.get("reason"):
            lines.append(f"- Model: {model['reason']}")
        elif model.get("missing"):
            lines.append("- Missing candidate inputs: " + ", ".join(model["missing"]))
        for doc in item["evidence"]:
            measured = doc.get("measurements",{}).get(target)
            result_text = (f" Published measurement ({doc['locator']}): {measured['value']} {measured['unit']}."
                           if measured else "")
            lines.append(f"- {doc['text']}{result_text} {doc['limitation']} [{doc['title']}]({doc['url']})")
        if not item["evidence"] and item["decision"] != "model_estimate":
            lines.append("- No applicable source in the current evidence collection.")
        lines.append("")
    return "\n".join(lines)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("request",type=Path)
    p.add_argument("--json",action="store_true",help="Return the model and literature reports alongside the decision.")
    args = p.parse_args()
    try:
        result = Hybrid(Path(__file__).resolve().parent).answer(json.loads(args.request.read_text()))
    except (ValueError,OSError) as error:
        p.error(str(error))
    print(json.dumps(result,indent=2) if args.json else render(result))


if __name__ == "__main__":
    main()
