-- Suites are loaded in order. Data fixture results are registered first so a
-- load-time data regression is reported before longer runtime tests run.
return {
    "__tenebris-prime-funit__.tests.suites.data_fixtures",
    "__tenebris-prime-funit__.tests.suites.bioluminescent",
}
