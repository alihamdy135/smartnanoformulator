# Product and evidence specification

## User flows

| Flow | Inputs | Result and finish condition |
| --- | --- | --- |
| Formulation evidence | Drug name and form, route, target tissue, optional carrier and endpoints, release target in hours and percent, and optional physicochemical descriptors | A result for each endpoint, with its decision, rationale and source details. A published carrier, excipient, ratio or batch appears only when the underlying evidence supports that field. |
| Microfluidic process | Liposome process settings for the Eugster model, including primary lipid, chip, cholesterol %, PEG %, total flow in mL/min and aqueous-to-organic flow ratio | Formation screen score and eligible benchmark-based size and PDI estimates, with scope and historical error. |
| Citation review | Select a source card from a result | Title, DOI or URL, source type, locator, batch, applicable experimental conditions, measurement and unit where supplied, and source limitation. |
| Correct and resubmit | Edit an invalid field, missing process setting or unsupported combination | Preserve form entries, identify fields to change and submit again. Unsupported outputs remain visible as their own result state. |

The formulation form should accept MW (Da), LogP, pKa, solubility (mg/mL with conditions if known), stability notes and drug form as optional design metadata. The prototype does not use these fields as retrieval filters or to generate drug-loaded numerical estimates. Label their present role in the UI. Store release targets separately from measurements. If ratio data enter the next release, use named ingredients, an explicit mass/molar/volumetric basis, and the review status for any unit conversion. Display missing ratios as unresolved.

## Runtime behavior to preserve

- The hybrid release uses `Hybrid(root).answer(request)` and runs wholly from local assets. It builds a TF-IDF index over nine curated evidence cards in `evidence.json`. The evidence comes from studies, an open book chapter, pharmacopeial material and regulatory guidance. The starter path has no external LLM or API dependency.
- Retrieval runs per endpoint. It requires a matching topic, filters explicit drug/route/tissue/carrier mismatches, prefers matching experimental or comparative studies, then sorts by TF-IDF and stable document ID. It returns up to three cards per endpoint. Text similarity controls ranking and carries no calibrated confidence.
- The process path checks lipid/chip pairing, required input fields, finite numbers, combined composition and observed ranges for that pairing. It identifies exact observed settings or settings within marginal ranges. Drug, route, tissue or a release target makes the process request out of scope. Size and PDI require formation score ≥0.5. Present formation as an uncalibrated score, size in nm and PDI as dimensionless.
- Drug-loaded estimators and Smart Microfluidics artifacts remain available for benchmark reproduction. Their available validation does not support release of their numerical predictions in this prototype.
- Meaningful conflict review requires a separately reviewed independent measurement, no known training reuse, matching settings and assay, and identical units. The current check flags a disagreement if the absolute difference exceeds the 90th percentile of grouped-CV absolute error. The starter corpus has no independently verified matching measurement for this route. The packaged smoke test simulates the arbitration outcome. The deployment test should exercise the full comparison using a synthetic, clearly labeled fixture.

| Decision | User-facing result |
| --- | --- |
| `model_estimate` | In-scope process estimate, units, support, cohort and historical MAE where applicable. |
| `literature_candidate` | Published candidate with citation and conditions. Measurements remain observations of the study batch. A citation can support a qualitative candidate when the requested numeric endpoint is absent. |
| `background_only` | Relevant context, with the requested candidate-specific field unresolved. |
| `insufficient_evidence` | An explicit unresolved field with the reason and any missing input named by the engine. |
| `conflicting_evidence` | Review state with separate model and study values, comparable conditions and rationale. |

Current precedence is discordant comparable evidence, supported process estimate, directly matched literature, background, then abstention. Each response preserves the original branch reports as `model` and `evidence`. Show why each endpoint took its route. Preserve the underlying `confidence_basis` as evidence support language. Keep prediction, study measurement, and user target visually distinct.

## Reference scenarios

| Bundled fixture | Expected behavior |
| --- | --- |
| `examples/process.json` | DMPC/ZZ example reports size 461.4 nm, PDI 0.1425 and formation score 1.0. Exact expected output and scope appear in `process_result.json`. |
| `examples/celecoxib.json` | Topical skin, desired 65% at 24 h. Carrier, excipients and entrapment resolve to cited literature for Tween 20 ethosome, Batch F. Entrapment of 54.4% is observed in the cited batch. The release endpoint is `background_only` and has no predicted value. |
| `examples/gap.json` | Intranasal quercetin for brain delivery with a phytosome yields `insufficient_evidence` for ratios, release and tissue. Exclude evidence for oral quercetin. |

## Scope for future research

Cross-carrier optimization, ranked generated batches, quantitative tissue delivery, stability and bioavailability estimates require new data and validation. Evaluate the hybrid prospectively on unseen drug/route tasks. Compare against nearest cited formulations and a prespecified fixed-carrier baseline with the same experimental budget. Measure top-k attainment of prespecified quality and release criteria, citation correctness, appropriate abstention and coverage. Verify any new source's training overlap, drug form, release assay and redistribution rights before public inclusion.
