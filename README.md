# SmartNanoFormulator

SmartNanoFormulator is a research prototype with a FastAPI service and a Flutter Web client. The backend wraps the supplied `Hybrid(root).answer(request)` engine. It reports the model and literature branches separately and retains the engine's field-by-field decision rules.

## Scientific scope

- Drug-loaded numerical predictions remain withheld. The topical celecoxib flow shows the published Tween 20 ethosome, Batch F, and its observed 54.4% entrapment. A 65% release at 24 hours is shown as a user target; the release estimate stays unresolved.
- Numerical formation, size, and PDI results are served only for the Eugster microfluidic liposome cohort. Formation is an uncalibrated score. Grouped cross-validation MAE and 90th-percentile absolute error are historical cohort benchmarks, not individual-batch intervals.
- Cross-carrier ranking, ratio optimization, quantitative tissue targeting, stability, and bioavailability predictions remain future research.

## Source and runtime assets

`DOC/Reference_Artifacts/SmartNanoFormulator_hybrid.zip` is the inference source archive. Its copied checksum is recorded in `DOC/SOURCE_SHA256SUMS.txt`. `engine/hybrid.py` is copied unchanged from that archive. `engine/assets/` contains the evidence corpus, metrics, process cohort, grouped error data, and the three fitted Eugster artifacts loaded by the public API. Drug-loaded and Smart Microfluidics estimators are retained in the source archive and reproducibility package but are not loaded by these routes.

## Local setup

Use Python 3.14 and the pinned packages in `requirements.txt`.

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
uvicorn app:app --reload
```

The API is documented at `http://127.0.0.1:8000/docs`; its OpenAPI JSON is at `/openapi.json`. Run acceptance checks with `python -m unittest discover -s tests -v`.

In another terminal:

```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 5000 \
  --dart-define=NANOPREDICT_API_BASE_URL=http://127.0.0.1:8000
```

## Deployment

Deploy the root FastAPI project to Vercel. `NANOPREDICT_ALLOWED_ORIGINS` accepts comma-separated exact origins; by default, the API also accepts the standard `*.web.app` and `*.firebaseapp.com` Firebase Hosting origins. Override that pattern with `NANOPREDICT_ALLOWED_ORIGIN_REGEX` if needed. Optional release labels are `NANOPREDICT_MODEL_RELEASE` and `NANOPREDICT_CORPUS_RELEASE`.

Before a Vercel deploy, regenerate the runtime bundle with `python scripts/package_runtime.py`. It contains only the checksummed inference assets used by the live API.
The Vercel resolver excludes XGBoost's optional Linux NCCL dependency: the selected PDI estimator runs CPU inference only, and the API does not use XGBoost distributed collectives or GPU operations.

Build Flutter Web with the HTTPS API origin:

```bash
cd frontend
flutter build web --release \
  --pwa-strategy=none --no-web-resources-cdn \
  --dart-define=NANOPREDICT_API_BASE_URL=https://YOUR-API.vercel.app
cd ..
```

Firebase Hosting configuration is in `firebase.json`. A project-local Firebase CLI is pinned in `tools/firebase-cli` so a global install is not required. Log in with the Google account that owns the Hosting project, select the project, then deploy:

```bash
cd tools/firebase-cli
export XDG_CONFIG_HOME=/tmp/smartnano-firebase/config
export XDG_CACHE_HOME=/tmp/smartnano-firebase/cache
./node_modules/.bin/firebase login
./node_modules/.bin/firebase projects:list
cd ../..
./tools/firebase-cli/node_modules/.bin/firebase use --add
./tools/firebase-cli/node_modules/.bin/firebase deploy --only hosting
```

Sign in using the Google account that has access to the Firebase project. If the CLI prints a sign-in URL, open it and follow the CLI instructions to finish authorization in your terminal.

The CLI account state is kept outside the repository under `/tmp/smartnano-firebase`; use a writable, private config directory if you need credentials to persist across machine restarts. `firebase use --add` writes the selected project alias to `.firebaserc`, which is intentionally created only after the owner selects a project. At the original handoff, no Firebase project ID or authorized local account was present.

### Automatic deployments from GitHub

`.github/workflows/firebase-hosting.yml` builds Flutter and deploys the live Firebase Hosting channel when frontend or Hosting configuration changes reach `main`. It uses the Actions variable `NANOPREDICT_API_BASE_URL` when set and defaults to the current Vercel API URL. Configure the Actions variable `FIREBASE_PROJECT_ID` and the Actions secret `FIREBASE_SERVICE_ACCOUNT` in the GitHub repository settings. Store the Hosting service account JSON in that secret. After configuring credentials, run the workflow from the Actions tab on `main` for the initial release.

For automatic Vercel backend deployments, connect the pushed GitHub repository to the Vercel project with the repository root as its root directory. The existing `vercel.json` and Python requirements configure the FastAPI deployment. Confirm that Vercel's production domain remains `smartnanoformulator-api-alihatab.vercel.app` before changing the API URL used by the Flutter workflow.

## Configuration names

- Backend: `NANOPREDICT_ALLOWED_ORIGINS`, `NANOPREDICT_ALLOWED_ORIGIN_REGEX`, `NANOPREDICT_MODEL_RELEASE`, `NANOPREDICT_CORPUS_RELEASE`.
- Flutter build-time: `NANOPREDICT_API_BASE_URL`.
- `FIREBASE_PROJECT_ID` and `NANOPREDICT_AUTH_REQUIRED` are reserved for a future Firebase Authentication integration; authentication is not enabled by this release contract.
