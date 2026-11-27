"""NanoPredict Lab API around the supplied SmartNanoFormulator engine."""

from __future__ import annotations

import logging
import hashlib
import math
import os
import zipfile
from pathlib import Path
from threading import Lock
from time import perf_counter
from typing import Annotated, Any, Literal
from uuid import uuid4

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, BeforeValidator, ConfigDict, Field, model_validator

from engine.hybrid import Hybrid


API_VERSION = "0.1.0"
MODEL_RELEASE = os.getenv("NANOPREDICT_MODEL_RELEASE", "hybrid-2026-11-14")
CORPUS_RELEASE = os.getenv("NANOPREDICT_CORPUS_RELEASE", "curated-evidence-2026-11-27")
ASSET_ROOT = Path(__file__).resolve().parent / "engine" / "assets"
ASSET_BUNDLE = Path(__file__).resolve().parent / "runtime-assets.zip"
ASSET_BUNDLE_ROOT = Path("/tmp/smartnanoformulator-assets")
logger = logging.getLogger("smartnanoformulator.api")


def _json_number(value: Any) -> int | float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError("Input must be a JSON number.")
    if not math.isfinite(value):
        raise ValueError("Input must be finite.")
    return value


JsonNumber = Annotated[float, BeforeValidator(_json_number), Field(allow_inf_nan=False)]
PositiveNumber = Annotated[JsonNumber, Field(gt=0)]
Percentage = Annotated[JsonNumber, Field(ge=0, le=100)]
NonNegativeNumber = Annotated[JsonNumber, Field(ge=0)]

FormulationTarget = Literal[
    "carrier", "excipients", "ratios", "size", "pdi",
    "entrapment", "release", "tissue", "stability", "bioavailability",
]
ProcessTarget = Literal["size", "pdi", "formation"]


class StrictInput(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class DesiredRelease(StrictInput):
    hours: PositiveNumber
    percent: Percentage


class Descriptors(StrictInput):
    mw_da: PositiveNumber | None = None
    logp: JsonNumber | None = None
    pka: JsonNumber | None = None
    solubility_mg_ml: NonNegativeNumber | None = None
    solubility_conditions: str | None = Field(default=None, max_length=200)
    stability_notes: str | None = Field(default=None, max_length=500)


class FormulationRequest(StrictInput):
    drug: str = Field(min_length=1, max_length=160)
    drug_form: str | None = Field(default=None, max_length=160)
    route: str = Field(min_length=1, max_length=100)
    tissue: str = Field(min_length=1, max_length=100)
    carrier: Literal["liposome", "niosome", "transfersome", "ethosome", "phytosome"] | None = None
    assay: str | None = Field(default=None, max_length=200)
    targets: list[FormulationTarget] = Field(min_length=1)
    desired_release: DesiredRelease | None = None
    descriptors: Descriptors | None = None

    @model_validator(mode="after")
    def targets_are_unique(self) -> "FormulationRequest":
        if len(self.targets) != len(set(self.targets)):
            raise ValueError("targets must not contain duplicates.")
        return self


class ProcessCandidate(StrictInput):
    primary_lipid: str = Field(min_length=1, max_length=80)
    chip: str = Field(min_length=1, max_length=80)
    cholesterol_pct: Percentage
    peg_pct: Percentage
    tfr_ml_min: PositiveNumber
    aqueous_to_organic_frr: PositiveNumber

    @model_validator(mode="after")
    def composition_is_possible(self) -> "ProcessCandidate":
        if self.cholesterol_pct + self.peg_pct > 100:
            raise ValueError("cholesterol_pct plus peg_pct must not exceed 100.")
        return self


class ProcessRequest(StrictInput):
    assay: str | None = Field(default=None, max_length=200)
    targets: list[ProcessTarget] = Field(min_length=1)
    candidate: ProcessCandidate

    @model_validator(mode="after")
    def targets_are_unique(self) -> "ProcessRequest":
        if len(self.targets) != len(set(self.targets)):
            raise ValueError("targets must not contain duplicates.")
        return self


class ErrorField(BaseModel):
    path: str
    message: str


class ErrorResponse(BaseModel):
    request_id: str
    code: Literal["INVALID_REQUEST", "ENGINE_UNAVAILABLE"]
    message: str
    fields: list[ErrorField] | None = None


class HealthResponse(BaseModel):
    status: Literal["ready"]
    api_version: str
    model_release: str
    corpus_release: str


class ModelReport(BaseModel):
    model_config = ConfigDict(extra="allow")
    status: Literal[
        "process_estimate", "withheld", "unsupported_endpoint", "out_of_scope",
        "missing_inputs", "invalid_inputs",
    ]
    value: JsonNumber | None = None
    unit: str | None = None
    reason: str | None = None


class EvidenceReport(BaseModel):
    model_config = ConfigDict(extra="allow")
    id: str
    title: str
    url: str
    kind: str
    applicability: Literal["matched_drug_and_route", "background_or_analogue"]
    independence: Literal["training_source", "training_overlap_unverified"]
    text: str
    limitation: str


class EndpointReport(BaseModel):
    decision: Literal[
        "model_estimate", "literature_candidate", "background_only",
        "insufficient_evidence", "conflicting_evidence",
    ]
    confidence_basis: str
    rationale: str
    model: ModelReport
    evidence: list[EvidenceReport]


class AssessmentResponse(BaseModel):
    request_id: str
    api_version: str
    model_release: str
    corpus_release: str
    request: dict[str, Any]
    results: dict[str, EndpointReport]
    method: str


_engine: Hybrid | None = None
_engine_lock = Lock()


class EngineUnavailable(RuntimeError):
    pass


def _runtime_asset_root() -> Path:
    required = (
        "evidence.json", "process_results.json", "process_training.csv",
        "drug_metrics.csv", "eugster_size_nm_grouped_predictions.csv",
        "eugster_pdi_grouped_predictions.csv", "SHA256SUMS.txt",
    )
    if all((ASSET_ROOT / name).is_file() for name in required):
        return ASSET_ROOT
    if not ASSET_BUNDLE.is_file():
        raise FileNotFoundError("The runtime asset bundle is missing.")
    if not all((ASSET_BUNDLE_ROOT / name).is_file() for name in required):
        ASSET_BUNDLE_ROOT.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(ASSET_BUNDLE) as bundle:
            for member in bundle.infolist():
                member_path = Path(member.filename)
                if member_path.is_absolute() or ".." in member_path.parts:
                    raise ValueError("The runtime asset bundle contains an invalid path.")
            bundle.extractall(ASSET_BUNDLE_ROOT)
    return ASSET_BUNDLE_ROOT


def ready_engine() -> Hybrid:
    """Load and check required assets once per warm function process."""
    global _engine
    if _engine is None:
        with _engine_lock:
            if _engine is None:
                try:
                    asset_root = _runtime_asset_root()
                    required = (
                        "evidence.json", "process_results.json", "process_training.csv",
                        "drug_metrics.csv", "eugster_size_nm_grouped_predictions.csv",
                        "eugster_pdi_grouped_predictions.csv",
                    )
                    missing = [name for name in required if not (asset_root / name).is_file()]
                    if missing:
                        raise FileNotFoundError(f"Missing runtime assets: {', '.join(missing)}")
                    manifest = asset_root / "SHA256SUMS.txt"
                    for line in manifest.read_text().splitlines():
                        expected, relative = line.split(maxsplit=1)
                        relative = relative.lstrip("* ")
                        asset_path = (asset_root / relative).resolve()
                        if asset_root.resolve() not in asset_path.parents:
                            raise ValueError("Asset manifest contains an invalid path.")
                        actual = hashlib.sha256(asset_path.read_bytes()).hexdigest()
                        if actual != expected:
                            raise ValueError(f"Runtime asset checksum mismatch: {relative}")
                    candidate_engine = Hybrid(asset_root)
                    for name in ("eugster_formation", "eugster_size_nm", "eugster_pdi"):
                        candidate_engine.artifact(name)
                    if not candidate_engine.process_rows:
                        raise ValueError("The Eugster process cohort is empty.")
                    _engine = candidate_engine
                except Exception as error:
                    logger.exception("NanoPredict Lab inference engine failed readiness check")
                    raise EngineUnavailable("Required model or evidence assets are unavailable.") from error
    return _engine


def _request_id(request: Request) -> str:
    return getattr(request.state, "request_id", str(uuid4()))


def _assessment(request_id: str, engine_request: dict[str, Any]) -> dict[str, Any]:
    try:
        answer = ready_engine().answer(engine_request)
    except EngineUnavailable:
        raise
    except Exception as error:
        logger.exception("NanoPredict Lab inference failed", extra={"request_id": request_id})
        raise EngineUnavailable("The assessment could not be completed because the inference engine failed.") from error
    return {
        "request_id": request_id,
        "api_version": API_VERSION,
        "model_release": MODEL_RELEASE,
        "corpus_release": CORPUS_RELEASE,
        "request": answer["request"],
        "results": answer["results"],
        "method": answer["method"],
    }


app = FastAPI(
    title="NanoPredict Lab API",
    version=API_VERSION,
    description=(
        "Research prototype for evidence screening and Eugster-scope microfluidic liposome "
        "assessment. Numerical drug-loaded estimates remain withheld."
    ),
    docs_url="/docs",
    openapi_url="/openapi.json",
)

origins = [
    origin.strip()
    for origin in os.getenv(
        "NANOPREDICT_ALLOWED_ORIGINS",
        "http://localhost:5000,http://127.0.0.1:5000,http://localhost:3000",
    ).split(",")
    if origin.strip()
]
origin_regex = os.getenv(
    "NANOPREDICT_ALLOWED_ORIGIN_REGEX",
    r"https://[a-z0-9-]+\.(?:web\.app|firebaseapp\.com)",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_origin_regex=origin_regex,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type", "X-Request-ID"],
    expose_headers=["X-Request-ID"],
    max_age=86400,
)


@app.middleware("http")
async def add_request_metadata(request: Request, call_next):
    request_id = str(uuid4())
    request.state.request_id = request_id
    started = perf_counter()
    response = await call_next(request)
    elapsed_ms = round((perf_counter() - started) * 1000, 2)
    response.headers["X-Request-ID"] = request_id
    logger.info(
        "request completed",
        extra={
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "duration_ms": elapsed_ms,
        },
    )
    return response


@app.exception_handler(RequestValidationError)
async def request_validation_error(request: Request, exc: RequestValidationError):
    fields = []
    for error in exc.errors():
        location = [str(part) for part in error.get("loc", ()) if part not in ("body", "query", "path")]
        fields.append({"path": ".".join(location), "message": error.get("msg", "Invalid value.")})
    body = {
        "request_id": _request_id(request),
        "code": "INVALID_REQUEST",
        "message": "Request validation failed.",
        "fields": fields,
    }
    return JSONResponse(status_code=422, content=body)


@app.exception_handler(EngineUnavailable)
async def engine_unavailable_error(request: Request, exc: EngineUnavailable):
    body = {
        "request_id": _request_id(request),
        "code": "ENGINE_UNAVAILABLE",
        "message": str(exc),
    }
    return JSONResponse(status_code=503, content=body)


@app.get("/healthz", response_model=HealthResponse, responses={503: {"model": ErrorResponse}})
def healthz():
    ready_engine()
    return {
        "status": "ready",
        "api_version": API_VERSION,
        "model_release": MODEL_RELEASE,
        "corpus_release": CORPUS_RELEASE,
    }


@app.post(
    "/v1/formulation-assessments",
    response_model=AssessmentResponse,
    response_model_exclude_none=True,
    responses={422: {"model": ErrorResponse}, 503: {"model": ErrorResponse}},
)
def assess_formulation(payload: FormulationRequest, request: Request):
    source = payload.model_dump(exclude_none=True)
    return _assessment(_request_id(request), source)


@app.post(
    "/v1/process-assessments",
    response_model=AssessmentResponse,
    response_model_exclude_none=True,
    responses={422: {"model": ErrorResponse}, 503: {"model": ErrorResponse}},
)
def assess_process(payload: ProcessRequest, request: Request):
    source = payload.model_dump(exclude_none=True)
    engine_request = {
        **source,
        "carrier": "liposome",
        "model_family": "eugster",
    }
    return _assessment(_request_id(request), engine_request)
