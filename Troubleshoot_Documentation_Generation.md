# Troubleshoot the generation of the documentation

## Missing setup step description

If a Test Case is built around permutations, you have to use the `Test Setup` (and `Test Teardown`) keywords in order
to properly generate the documentation. If you use `Suite Setup` (and `Suite Teardown`), the generated documentation
will not contain the full description of the setup step (it will not full but it will only contain the generic sentence).
