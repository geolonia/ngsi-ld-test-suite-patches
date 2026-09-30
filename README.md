# NGSI-LD Test Suite — Geolonia patches

Fixes for bugs we find in the [ETSI NGSI-LD Test Suite](https://forge.etsi.org/rep/cim/ngsi-ld-test-suite).
Each bug has an [issue](https://github.com/geolonia/ngsi-ld-test-suite-patches/issues), and each fix is a
[pull request](https://github.com/geolonia/ngsi-ld-test-suite-patches/pulls).
To get a fix as a patch file, add `.patch` to the pull request URL, for example:

    https://github.com/geolonia/ngsi-ld-test-suite-patches/pull/8.patch

Some suite files use CRLF line endings, so apply a patch with `git am --keep-cr` (or `git apply`).

- This is not a copy of the suite to use. To run the suite, get it from ETSI.
- This repository is not linked to ETSI, and ETSI does not endorse it.
- Our published test results always use the unchanged suite from ETSI, never these fixes.
- Licence: BSD-3-Clause, the same as the suite, so ETSI can take the fixes. `LICENSE` is unchanged.

<details>
<summary>Details for reviewers and AI agents</summary>

## Why this repository exists

We run the suite against NGSI-LD context brokers, including our own (GeonicDB). This finds bugs
in the suite, not only in the brokers. To report a bug to ETSI, you need an ETSI account, or you
send an email to `ngsi-ld@etsi.org`, where the discussion is not public. Here, the report, the
fix and the reasons are public.

If the ETSI maintainers want to take this work into their own project, we would like that too.

## Branches

| Branch | Contents |
|---|---|
| `develop` | An exact copy of the ETSI `develop` branch. A repository rule protects it: only maintainers can update it, and only from ETSI. |
| `fix/<name>` | One fix, based on `develop`, as one commit. Commit messages follow the suite's `CONTRIBUTING.md` (Conventional Commits). |
| `about` | Only this README. It is the default branch, so `develop` can stay an exact copy. |

Each fix is a draft pull request from its `fix/<name>` branch into `develop`. The pull requests
are only for discussion. They are never merged here.

## Why test results never use this fork

We build a broker (GeonicDB) and also the test setup that measures it. If we measured our broker
with a suite that we changed, nobody could trust the results. So the fixes are only here, and
all measurements use a fixed, unchanged version of the suite from ETSI.

</details>
