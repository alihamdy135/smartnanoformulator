# SmartNanoFormulator

SmartNanoFormulator is a research prototype with a FastAPI service and a Flutter Web client. The backend wraps the supplied `Hybrid(root).answer(request)` engine. It reports the model and literature branches separately and retains the engine's field-by-field decision rules.

- [Production Flutter app](https://smartnanoformulator.web.app)
- [GitHub source](https://github.com/alihamdy135/smartnanoformulator)
- [Production API documentation](https://smartnanoformulator-api-alihatab.vercel.app/docs)

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
  --dart-define=NANOPREDICT_API_BASE_URL=https://smartnanoformulator-api-alihatab.vercel.app
cd ..
```

Firebase Hosting serves `frontend/build/web` using the configuration in `firebase.json`. Deploy to the `smartnanoformulator` project from the repository root using the pinned Firebase CLI:

```bash
npm ci --prefix tools/firebase-cli
./tools/firebase-cli/node_modules/.bin/firebase login
./tools/firebase-cli/node_modules/.bin/firebase projects:list
./tools/firebase-cli/node_modules/.bin/firebase deploy --only hosting --project smartnanoformulator
```

Sign in with a Google account that has Firebase Hosting deploy access to this project. If the CLI prints a sign-in URL, complete authorization in your browser and enter the one-time code in your own terminal when prompted.

### Automatic deployments from GitHub

`.github/workflows/firebase-hosting.yml` builds Flutter and deploys the live Firebase Hosting channel with the same pinned Firebase CLI when frontend or Hosting configuration changes reach `main`. It uses the Actions variable `NANOPREDICT_API_BASE_URL` when set and defaults to the production Vercel API.

The workflow uses [Google Cloud Workload Identity Federation](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines) to obtain short-lived credentials. The identity provider accepts only this repository’s Firebase Hosting workflow on `main`. The dedicated deployer has Firebase Hosting Admin and API Keys Viewer roles on the Firebase project. Configure these GitHub Actions repository variables when moving the project:

- `FIREBASE_PROJECT_ID`: Firebase project ID (`smartnanoformulator`).
- `FIREBASE_WORKLOAD_IDENTITY_PROVIDER`: full resource name of the GitHub OIDC provider, including the numeric Google Cloud project ID.
- `FIREBASE_DEPLOY_SERVICE_ACCOUNT`: email address of the dedicated Hosting deployer.

Run the workflow from the Actions tab on `main` to verify a new identity configuration.

The `alihatab/smartnanoformulator-api` Vercel project uses the GitHub repository root for FastAPI builds. Pushes to the production branch, `main`, trigger backend builds. The Flutter workflow defaults to `smartnanoformulator-api-alihatab.vercel.app`.

## Configuration names

- Backend: `NANOPREDICT_ALLOWED_ORIGINS`, `NANOPREDICT_ALLOWED_ORIGIN_REGEX`, `NANOPREDICT_MODEL_RELEASE`, `NANOPREDICT_CORPUS_RELEASE`.
- Flutter build-time: `NANOPREDICT_API_BASE_URL`.
- GitHub Actions: `FIREBASE_PROJECT_ID`, `FIREBASE_WORKLOAD_IDENTITY_PROVIDER`, and `FIREBASE_DEPLOY_SERVICE_ACCOUNT` (repository variables).
- Backend Firebase Authentication is not enabled in this release.
