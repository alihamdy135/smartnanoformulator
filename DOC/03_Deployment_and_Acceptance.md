# Deployment and acceptance specification

## Component responsibilities

| Component | Proposed implementation |
| --- | --- |
| Flutter Web on Firebase Hosting | Research and process forms, validation feedback, endpoint state cards, citation panels and API connection. Build using `flutter build web` and serve `build/web`. Configure a rewrite to `/index.html` if using path-based client navigation. |
| FastAPI on Vercel | Validate JSON, route through the engine, enforce API versions, add health checks, and return typed results and errors. Pin Python 3.14 initially, matching the archive. |
| Research runtime | Bundle the reviewed joblib artifacts used by inference, the nine-card corpus, process metrics, drug metrics, process training range data and grouped error CSVs. Keep the full training releases in the research artifacts. |
| Optional Firebase Authentication | If approved for pilot access, the client sends a Firebase ID token and the API verifies it for the intended Firebase project. No auth is required by the proposed OpenAPI default. |
| Persistence | Stateless first release. Persisting user inputs or saving result history requires a separate product decision. |

Vercel officially supports FastAPI and Python 3.14. Validate the actual package solution on the preview builder. The standard Python function bundle limit is 500 MB uncompressed in the official Python runtime documentation. Compare the full dependency footprint, not just model sizes, against the project limits. Keep the compact request and response well within Vercel's documented 4.5 MB non-streaming payload limit. Validate installed Linux wheels, versions and native dependencies in the deployment environment. Keep Flutter Web assets on Firebase Hosting and model assets server-side.

## Backend behavior

- Unzip the hybrid release into its own directory. Its archived dependencies are `numpy==2.5.4`, `scipy==1.18.1`, `scikit-learn==1.9.1`, `xgboost==3.2.0`, `joblib==1.6.0`, and `openpyxl==3.1.5`. Document any carefully tested changes to these pins. Load only trusted artifacts with verified hashes.
- Reuse one engine per warm worker and load models once as needed. Resolve assets from the installed engine directory. Training and evidence review happen outside the request path.
- For a verified deployment, record API, model release and corpus release IDs in metadata and logs. Include a request ID and timing, without logging raw formulation inputs by default. Separate development, preview and production frontend origins and API URLs.
- Validate model family, target names, duplicate targets, input shape, finite numbers and percentages at the HTTP boundary. Reject unknown top-level fields. Treat a valid request with unsupported scientific evidence as a normal result. Use an explicit degraded-service error if required model assets or corpus cannot load.
- Keep a strict CORS allowlist for actual Firebase preview and production origins. Keep service credentials in backend configuration. The compiled Flutter Web bundle can contain the public API origin and public Firebase web configuration.
- Measure build bundle size, cold/warm latency, memory and error rates with both workflows. A synchronous preview is the proposed starting point. If it exceeds the measured project limits, evaluate packaging and loading changes before deciding on hosted inference separation.

## Configuration names

| Proposed setting | Location |
| --- | --- |
| `NANOPREDICT_API_BASE_URL` | Flutter compile-time setting for the Vercel HTTPS URL |
| `NANOPREDICT_ALLOWED_ORIGINS` | Vercel environment, one allowlist for each environment |
| `NANOPREDICT_MODEL_RELEASE`, `NANOPREDICT_CORPUS_RELEASE` | Vercel release metadata |
| `FIREBASE_PROJECT_ID` | Firebase project selection and separately in backend if token validation is enabled |
| `NANOPREDICT_AUTH_REQUIRED` | Vercel feature setting if Firebase Auth is implemented |

## Implementation and release checks

| Check | Pass condition |
| --- | --- |
| Archive integrity | Local hashes match; verify the reproducibility archive's internal manifest after unpacking. |
| CLI reference | `python check_hybrid.py` passes. Capture new outputs in an isolated copy and compare the three shipped results. |
| API parity | Both routes match the expected fixture decisions, measurements, numeric units and relevant citations. Return HTTP 422 for malformed requests. |
| Boundaries | Unknown targets, duplicate targets, nonfinite values, impossible composition and unsupported lipid/chip pairing are covered. Test a below-threshold formation case and withhold size/PDI. |
| Scientific provenance | Celecoxib 54.4% remains a Batch F observation, with the 24 h target shown independently and no predicted release. An oral source is absent in the intranasal fixture. |
| Conflicting evidence | A clearly simulated independent matched measurement flags review. A mismatched assay, unit or training-source record does not flag it. |
| Browser | Firebase preview loads and works after refresh and deep links, output cards render each status, citation links work and correct Vercel CORS policy applies. |
| Environments | Preview serves real selected artifacts, reports version IDs and passes backend and browser smoke tests. Capture resource measurements and rollback references before promotion. |

For research reproduction use the commands shipped in the reproducibility archive. Its `preprocess.py` and `train_process.py` expect the upstream `SmartNanoFormulator_research.xlsx`. Keep that separate from the final cleaned workbook.

## Official references

- [Vercel FastAPI integration](https://vercel.com/docs/frameworks/backend/fastapi)
- [Vercel Python runtime and bundle configuration](https://vercel.com/docs/functions/runtimes/python)
- [Vercel Functions limits](https://vercel.com/docs/functions/limitations)
- [Flutter Web build and release](https://docs.flutter.dev/deployment/web)
- [Firebase Hosting deployment](https://firebase.google.com/docs/hosting/quickstart)
- [Firebase Hosting rewrites](https://firebase.google.com/docs/hosting/full-config)
- [Firebase ID token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens)
