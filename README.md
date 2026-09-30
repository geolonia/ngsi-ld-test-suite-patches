# NGSI-LD Test Suite — Geolonia patches

Fixes for bugs we find in the [ETSI NGSI-LD Test Suite](https://forge.etsi.org/rep/cim/ngsi-ld-test-suite).
Each bug has a public issue here, and each fix a pull request that the suite's maintainers can take as a patch.

This is not a copy of the suite to use, and it is not linked to or endorsed by ETSI.
To run the suite, get it from the link above.

## Why

We run the suite against NGSI-LD context brokers, including our own (GeonicDB). This finds bugs
in the suite as well as in brokers. Reporting upstream needs an ETSI account, or an email to
`ngsi-ld@etsi.org`, which keeps the discussion private. Here the report, the fix and the
reasoning are public.

If the maintainers would rather take this work into their own project, so would we.

## Branches and pull requests

| Branch | Contents |
|---|---|
| `develop` | An exact copy of upstream `develop`. A repository rule protects it: only maintainers can update it, and only to catch up with upstream. |
| `fix/<name>` | One fix, starting from `develop`. |
| `about` | Only this README, so `develop` stays an exact copy. |

Each fix is open as a draft pull request into `develop`, so it can be discussed. These pull
requests are never merged here. To get a fix as a patch file, add `.patch` to its pull request
URL, for example:

    https://github.com/geolonia/ngsi-ld-test-suite-patches/pull/8.patch

## We don't score brokers with this fork

Our published results always use an unchanged upstream version of the suite, never these fixes.
We build a broker ourselves, so we must not grade it with a suite we have edited.

## Licence

The test suite belongs to ETSI and is licensed BSD-3-Clause. `LICENSE` is unchanged.
Our fixes use the same licence, so upstream can take them as they are.
