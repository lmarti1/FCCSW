## Configuration file for the Dashboard of the tests
set(CTEST_PROJECT_NAME "FCC")
set(CTEST_NIGHTLY_START_TIME "02:00:00 UTC")

set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "cdash.cern.ch")
set(CTEST_DROP_LOCATION "/submit.php?project=FCC")
set(CTEST_DROP_SITE_CDASH TRUE)
