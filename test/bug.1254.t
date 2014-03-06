#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
################################################################################
##
## Copyright 2006 - 2014, Paul Beckingham, Federico Hernandez.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included
## in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##
## http://www.opensource.org/licenses/mit-license.php
##
################################################################################

import sys
import os
import signal
from glob import glob
# Ensure python finds the local simpletap and basetest modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import BaseTestCase


class BaseTestBug1254(BaseTestCase):
    @classmethod
    def prepare(cls):
        with open("bug.rc", 'w') as fh:
            fh.write("data.location=.\n"
                     "confirmation=no\n")

    def tearDown(self):
        """Needed after each test or setUp will cause duplicated data at start
        of the next test.
        """
        for file in glob("*.data"):
            os.remove(file)

    @classmethod
    def cleanup(cls):
        os.remove("bug.rc")


class TestBug1254(BaseTestBug1254):
    def test_no_segmentation_fault_calc_negative_multiplication(self):
        """calc can multiply zero and negative numbers
        """
        args = ["rc:bug.rc", "calc", "0*-1"]

        self.run_command(args)

    def test_calc_positive_multiplication(self):
        """calc can multiply negative zero and positive
        """

        args = ["rc:bug.rc", "calc", "0*1"]

        self.run_command(args)

    def run_command(self, args):
        code, out, err = self.callTask(args)

        # We shouldn't get a segmentation fault
        # (negative exit code == 128 - real_exit_code)
        expected = -signal.SIGSEGV
        self.assertNotEqual(expected, code, "Task segfaulted")

        # Instead we expect a clean exit
        expected = 0
        self.assertEqual(expected, code,
                         "Exit code was non-zero ({0})".format(code))


if __name__ == "__main__":
    from simpletap import TAPTestRunner
    import unittest
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4
