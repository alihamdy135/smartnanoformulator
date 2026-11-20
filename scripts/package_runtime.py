"""Create the compact, deterministic Vercel runtime asset archive."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "engine" / "assets"
OUTPUT = ROOT / "runtime-assets.zip"


def main() -> None:
    required = (
        "evidence.json",
        "process_results.json",
        "process_training.csv",
        "drug_metrics.csv",
        "eugster_size_nm_grouped_predictions.csv",
        "eugster_pdi_grouped_predictions.csv",
        "SHA256SUMS.txt",
        "models/eugster_formation.joblib",
        "models/eugster_size_nm.joblib",
        "models/eugster_pdi.joblib",
    )
    missing = [name for name in required if not (ASSETS / name).is_file()]
    if missing:
        raise SystemExit(f"Missing runtime assets: {', '.join(missing)}")

    with ZipFile(OUTPUT, "w", compression=ZIP_DEFLATED, compresslevel=9) as archive:
        for path in sorted(ASSETS.rglob("*")):
            if path.is_file():
                archive.write(path, path.relative_to(ASSETS).as_posix())
    print(f"Wrote {OUTPUT.relative_to(ROOT)} ({OUTPUT.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
