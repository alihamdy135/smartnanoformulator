# Start here

Paste the following into the new NanoPredict chat with this DOC folder available.

> Build SmartNanoFormulator using the handoff in DOC. Read README.md, the three numbered specifications, the workflow PDF and spec/openapi.yaml. Verify the copied archives against SOURCE_SHA256SUMS.txt. Unpack the hybrid ZIP into a clean working directory and run its smoke test before touching code. Use Hybrid(root).answer(request) as the behavior reference for a FastAPI backend on Vercel. Build a Flutter Web frontend on Firebase Hosting with a formulation evidence flow and a separate microfluidic process form. Preserve model scope, source provenance, abstention, and the fixture behavior described in the docs. Complete local parity tests and preview deployments first. Use the project credentials and hosting targets provided for the build. Report the commit, test results, release versions and deployed URLs once verified.

## Build order

1. Verify the original archives, inspect dependencies and reproduce `examples/*_result.json` with the packaged smoke test.
2. Wrap the current engine behind the versioned OpenAPI contract. Add strict boundary validation and snapshot tests for the release routes and citation fields.
3. Build the Flutter input, result and citation screens against the same contract using test fixtures. Connect the preview to the live API.
4. Validate a Vercel build with actual runtime dependencies and assets, measure cold and warm inference and verify Firebase-hosted browser behavior. Promote matched preview builds after acceptance.
5. Leave new drug-loaded numerical prediction, inverse design, and clinical or tissue-targeting claims behind prospective evaluation.

## Decisions to settle during implementation

- Identify the existing Vercel and Firebase projects or create the intended environments during the authorized build. Firebase Hosting serves Flutter Web. Native Android or iOS distribution would be a different release target.
- FastAPI, a synchronous versioned API and a stateless first release are proposed defaults. Firebase Authentication is optional, to be chosen if the deployed audience requires it.
- Do the first build with the supplied extractive corpus and deterministic arbitration. A larger knowledge base, managed retrieval and an LLM are follow-up choices.
