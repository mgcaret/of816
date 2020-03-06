# OF816 Unit tests

This directory contains unit and conformance tests for OF816.  The ```*.fs``` files
contain the tests andtest support files.  Most tests are arranged in the order they
appear in IEEE 1275-94 chapters 5 and 7.

Tests written in ALL CAPS, and ``tester.fs`` were borrowed from the Forth 2012/ANSI Forth
[test suite](https://github.com/gerryjackson/forth2012-test-suite), and are public-domain.

Tests written in mixed case are modified from the same source, and also
public domain.

Tests written in lower case are hereby released to the public domain as an exception
to the licensing terms of OF816 itself.

## Test Execution

The tests are designed to run under the (currently unreleased) GoSXB emulator.  In the
GoSXB platform directory is a crude script to run the tests.

The tests are run in the order described in ``test-manifest.yaml``.

