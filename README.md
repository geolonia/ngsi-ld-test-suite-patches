# NGSI-LD Test Suite — Geolonia patches

Fixes for bugs we find in the [ETSI NGSI-LD Test Suite](https://forge.etsi.org/rep/cim/ngsi-ld-test-suite).
Each bug has a public issue here, and each fix has its own branch that the suite's maintainers can take.

This is not a copy of the suite to use, and it is not linked to or endorsed by ETSI.
To run the suite, get it from the link above.

## Why

We run the suite against NGSI-LD context brokers, including our own (GeonicDB). This finds bugs
in the suite as well as in brokers. Reporting upstream needs an ETSI account, or an email to
`ngsi-ld@etsi.org`, which keeps the discussion private. Here the report, the fix and the
reasoning are public.

If the maintainers would rather take this work into their own project, so would we.

## Branches

| Branch | Contents |
|---|---|
| `develop` | An exact copy of upstream `develop`. We never change it. |
| `fix/<name>` | One fix, starting from `develop`. |
| `about` | Only this README, so `develop` stays an exact copy. |

To get a fix as a patch file:

    git format-patch develop..fix/<name>

## We don't score brokers with this fork

Our published results always use an unchanged upstream version of the suite, never these fixes.
We build a broker ourselves, so we must not grade it with a suite we have edited.

## Licence

The test suite belongs to ETSI and is licensed BSD-3-Clause. `LICENSE` is unchanged.
Our fixes use the same licence, so upstream can take them as they are.
