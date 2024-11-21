# Troubleshoot the generation of the documentation

## Missing setup step description

If a Test Case is built around permutations, you have to use the `Test Setup` (and `Test Teardown`) keywords in order
to properly generate the documentation. If you use `Suite Setup` (and `Suite Teardown`), the generated documentation
will not contain the full description of the setup step (it will not fail, but it will only contain the generic sentence).

## SyntaxWarning: invalid escape sequence '\s'

When generating the documentation, such a warning may be displayed: 

```shell
/some/path/ngsi-ld-test-suite/doc/analysis/requests.py:463: SyntaxWarning: invalid escape sequence '\s'
  regex = '(\s{4})*\s{4}\.{3}\s{4}(.*)'
```

It usually means you are calling a keyword without using named arguments (note that this does not happen for all the
keywords).