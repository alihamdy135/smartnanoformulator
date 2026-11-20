# Research baseline and artifacts

## Supplied abstract

Selecting a nanovesicle carrier and optimizing excipient ratios for a given drug requires balancing formulation quality with delivery and release objectives. Published formulation data are uneven across carrier types and outcomes, limiting the use of a single predictive model. SmartNanoFormulator was developed as a hybrid platform that combines machine-learning predictions with retrieval-augmented generation (RAG) to support formulation design. The proposed workflow takes drug physicochemical properties, administration route, target tissue, and a desired release profile as design inputs and aims to recommend carrier types, excipients, ratios, and candidate batches.

A catalogue of 2,641 formulation records spanning liposomes, niosomes, transfersomes, ethosomes, and phytosomes was assembled. Separate models were fitted to available data for vesicle formation, particle size, polydispersity index (PDI), zeta potential, entrapment efficiency, and 24-hour release. The prototype assessed each requested output using model validation results, similarity to the training conditions, and the applicability of evidence retrieved from books, guidance documents, and research articles. When predictive support was insufficient, it returned a cited literature candidate where available or withheld the numerical estimate.

In grouped cross-validation on 928 screened microfluidic liposome runs, particle-size mean absolute error (MAE) decreased from 46.35 to 17.42 nm and PDI MAE decreased from 0.0518 to 0.0376 relative to median baselines. Drug-loaded models matched or underperformed the median baseline across all endpoints in study-held-out evaluation. In a topical celecoxib example, the prototype retrieved a published Tween 20 ethosome as a candidate and withheld an unsupported 24-hour release prediction.

These findings support the use of the prototype for microfluidic liposome benchmarking and evidence-based formulation screening. Prospective head-to-head experiments are needed to establish whether the hybrid approach improves carrier selection and excipient-ratio recommendations for unseen drugs.

## Catalogue and evaluation

| Catalogue detail | Verified result |
| --- | --- |
| Sources | 1,380 Eugster microfluidics, 785 LipoDB-BBB, 315 Smart Microfluidics, 138 Yanes IVR, 23 primary literature |
| Carriers | 2,550 liposomes, 40 niosomes, 23 transfersomes, 18 ethosomes, 10 phytosomes |
| Cohorts | 685 screened drug-loaded candidate records and 1,695 process runs. Each endpoint has its own eligible rows. |
| Observed endpoints | Size 2,273, PDI 2,012, zeta potential 380, entrapment 285, 24 h release 27 |
| Descriptor recovery | MW 161→251, LogP 151→232, pKa 23→54, numeric solubility 16→25, explicit numeric 24 h release 6→27 |
| Completeness | Zero records cover every historical feature in the full proposal. Verify recovered values and standardize assay and drug-form metadata before public research deposit. |

| Model and evaluation | N | MAE | Median baseline MAE |
| --- | ---: | ---: | ---: |
| Eugster size, grouped CV | 928 | 17.42 nm | 46.35 nm |
| Eugster PDI, grouped CV | 928 | 0.0376 | 0.0518 |
| Smart Microfluidics size, wet-lab holdout | 12 | 255.63 nm | 188.13 nm |
| Smart Microfluidics PDI, wet-lab holdout | 12 | 0.1949 | 0.1569 |
| Drug size, study-held-out | 416 | 85.07 nm | 85.07 nm |
| Drug PDI, study-held-out | 253 | 0.1121 | 0.1073 |
| Drug zeta, study-held-out | 284 | 15.70 mV | 15.70 mV |
| Drug entrapment, study-held-out | 282 | 19.40 pp | 19.08 pp |
| Drug 24 h release, study-held-out | 27 | 16.58 pp | 14.16 pp |

Formation-screen classification over 1,380 Eugster runs reports ROC AUC 0.938, balanced accuracy 0.847 and F1 0.909. Its label was derived from observed population, size and PDI. Those outcome measurements were excluded from the classifier inputs. Size and PDI estimates are conditional on a passing formation score. The process benchmark groups settings alongside its source-defined scope. The study-held-out and normalized-drug-held-out drug evaluations answer separate questions and can leave salts or synonyms in different groups. Model imputers were fitted within folds. Experimental outcome labels were left missing where unobserved. Positional ratios were excluded from drug-model fitting because ingredient order varies. Historical grouped-CV errors and support grades do not quantify uncertainty for an individual new batch.

## Original export register

| Local copy in Reference_Artifacts | Role | Original record |
| --- | --- | --- |
| SmartNanoFormulator_hybrid.zip | Inference source, ten fitted artifacts, corpus, metrics and golden fixtures | [Original](https://chatgpt.com/library?file_id=libfile_d2b4840f29608191bc048fca22a41469&account_id=personal) |
| SmartNanoFormulator_reproducibility.zip | Clean CSVs, source notes, model files, hashes and training/preprocessing scripts | [Original](https://chatgpt.com/library?file_id=libfile_0fc7547d97ec8191a9f51cbef6076823&account_id=personal) |
| SmartNanoFormulator_full_dataset.xlsx | Final 2,641-record workbook and audited model coverage | [Original](https://chatgpt.com/library?file_id=libfile_da364eaf5d5c8191b849f04d083ca069&account_id=personal) |
| SmartNanoFormulator_research_summary_workflow.pdf | Research summary with results and arbitration example | [Original](https://chatgpt.com/library?file_id=libfile_eea9e641405c8191b94e2c6c4431d1e1&account_id=personal) |
| SmartNanoFormulator_workflow_bw.pdf | Earlier standalone two-page workflow | [Original](https://chatgpt.com/library?file_id=libfile_568a989e07ec8191abccf4e8d9c87991&account_id=personal) |
| SmartNanoFormulator_research.xlsx | Historical upstream workbook required by training commands | [Original](https://chatgpt.com/library?file_id=libfile_8d04593940c08191a6e9e04860d1f341&account_id=personal) |
| SmartNanoFormulator_models.zip | Earlier process-model benchmark package | [Original](https://chatgpt.com/library?file_id=libfile_34c03887fc188191a37c63c1909fc89a&account_id=personal) |
| SmartNanoFormulator_2641.xlsx | Previous merged 2,641-record workbook | [Original](https://chatgpt.com/library?file_id=libfile_83c066da488c8191a78d1212446bfa5d&account_id=personal) |
| SmartNanoFormulator_expanded.xlsx | Earlier expansion-stage workbook | [Original](https://chatgpt.com/library?file_id=libfile_26cd953a574c8191b621e43dac729c46&account_id=personal) |
| SmartNanoFormulator.xlsx | Earlier pilot workbook | [Original](https://chatgpt.com/library?file_id=libfile_184e06030c68819180dfcf2739cceb21&account_id=personal) |
| SmartNanoFormulator_dataset.zip | Earlier pilot CSV tables and dataset readme | [Original](https://chatgpt.com/library?file_id=libfile_114b4d1509088191b2690971c9ebd011&account_id=personal) |
| SmartNanoFormulator_pilot.csv | Pilot formulation data | [Original](https://chatgpt.com/library?file_id=libfile_f88f2f7006cc8191b975d5a659577b77&account_id=personal) |
| SmartNanoFormulator_research_summary.pdf | Earlier standalone research summary | Original local project export |

The local workflow PDFs differ in byte size from the corresponding Library records. The handoff uses the original local copies and links the Library versions above.

## Source references

- [Eugster et al., microfluidic liposome process data](https://doi.org/10.1016/j.jconrel.2024.10.065)
- [Lavagna et al., Smart Microfluidics data](https://doi.org/10.1016/j.dib.2026.112667)
- [LipoDB-BBB, v1.0, CC BY 4.0](https://doi.org/10.5281/zenodo.19677556)
- [Yanes et al., release study](https://doi.org/10.1016/j.ijpx.2025.100393)
- [Bragagni et al., celecoxib Example, Table 2, Batch F](https://doi.org/10.3109/10717544.2012.724472)
