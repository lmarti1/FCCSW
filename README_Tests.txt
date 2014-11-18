Brief instructions on how to add and run tests.

The testing is based on the integrated testing functionality of CMake: CTest.

- Run existing tests:
    In your build directory ($FCCSW/build.*), display available tests:
ctest -N
    Run with:
ctest
    or to send the results to the Dashboard (http://cdash.cern.ch/index.php?project=FCC):
ctest -D Experimental

- Add test:
    Have a look at Example in $FCCSW/Reconstruction/
    1.) If not done so, add them in the CMakeLists.txt:
        gaudi_add_test(QMTest QMTEST)
        QMTest is a testing module with extended functionality.
    2.) The QMTest itself is expected to be in $FCCSW/PACKAGE/tests/qmtest/
        Tests in package.qms (all small letters) will be executed automatically if the QMTest module is added.
        Example test is in reconstruction_example.qmt

    For additional information, option and features of QMTest see: 
    https://twiki.cern.ch/twiki/bin/view/Gaudi/GaudiTestingInfrastructure
