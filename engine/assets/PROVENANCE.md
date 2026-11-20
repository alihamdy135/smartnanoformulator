# Runtime asset provenance

- Source archive: `DOC/Reference_Artifacts/SmartNanoFormulator_hybrid.zip`
- Source archive SHA-256: `5ae7d3ecd04f66ddfb58f518db409466b65b8d65b5fc772d03e4bc69cc13f8dd`
- `hybrid.py` is copied unchanged from that archive.
- `SHA256SUMS.txt` covers each copied corpus, model, metric, process-range, and grouped-error asset. The API checks these hashes before loading the model stack.
- The API loads only the Eugster formation, size, and PDI artifacts. Drug-loaded and Smart Microfluidics artifacts remain available in the original archive and reproducibility package but are not needed by the public routes.
