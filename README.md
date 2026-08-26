# NGSI-LD Test Suite — Geolonia patches

A working fork of the [ETSI NGSI-LD Test Suite](https://forge.etsi.org/rep/cim/ngsi-ld-test-suite),
used to track defects we find in the suite, develop fixes for them in the open, and hand the
upstream maintainers a link to a patch.

**This is not a distribution of the test suite, and not affiliated with or endorsed by ETSI.**
If you want the test suite, get it from upstream:

    https://forge.etsi.org/rep/cim/ngsi-ld-test-suite

## Why this exists

We run the suite continuously against four NGSI-LD Context Brokers, which turns up bugs in the
suite as well as in brokers. Reporting them was the awkward part:

* The upstream tracker on forge.etsi.org is readable by anyone but needs an ETSI Online account
  to write to, and their contribution flow expects a branch inside the project.
* The address upstream publishes for outside reports is `ngsi-ld@etsi.org`, which works but puts
  the discussion in private mail.

Neither gives us somewhere public to keep the reasoning, the patch, and the history of what we
changed and why. This repository is that place. Every finding gets an issue, every fix gets a
branch off pristine `develop`, and upstream gets a link they can `git fetch` or a patch they can
`git am` — whichever they prefer.

If the maintainers would rather host this work themselves, we would rather that too. An account
on forge and this repository goes read-only.

## How it is laid out

| Branch | What it is |
|---|---|
| `develop` | Pristine mirror of upstream `develop`. Fast-forward only. Never edited. |
| `about` | This page. An orphan branch, so the mirror stays byte-identical to upstream. |
| `fix/*` | One branch per defect, based on pristine `develop`, following upstream's `CONTRIBUTING.md`. |

Because `develop` is untouched, a patch we offer is exactly our own commits and nothing else:

    git format-patch develop..fix/<branch>

## One rule we hold ourselves to

**We never measure a broker against this fork.** Our published conformance figures are scored
against a pinned upstream revision, and only ever that. A vendor that edits the test suite and
then reports its own score against the edited suite is marking its own homework, and we build
both a broker and the testbed that scores it — so the line has to be bright. Fixes live here;
measurements come from upstream.

Our measurements, and the reasoning behind every figure, are in
[geolonia/geonicdb-compliance](https://github.com/geolonia/geonicdb-compliance).

## Licence

The test suite is ETSI's, licensed BSD-3-Clause, and `LICENSE` is retained unchanged on every
branch that carries suite code. Our own commits are offered under the same terms so upstream can
take them without friction.

ETSI's name appears here only to say factually where the code comes from, never to endorse or
promote anything of ours.
