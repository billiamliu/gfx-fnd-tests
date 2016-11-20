#!/usr/bin/env python

from __future__ import print_function

import os
import subprocess
import sys
import tempfile

CLEAN_UP_TMPFILES = True

def diff_pnms(left_file, right_file):
    #print(left_file, right_file)
    def tokenize(pnm_file):
        def decommentify_line(line):
            return line.split("#")[0]
        lines = pnm_file.readlines()
        lines_no_comments = map(decommentify_line, lines)
        tokens = "".join(lines_no_comments).split()
        magic_num = tokens[0]
        res_x = int(tokens[1], 10)
        res_y = int(tokens[2], 10)
        if magic_num == 'P1':
          depth = 1
          raster = tokens[3:]
          raster = ''.join(raster)
        else:
          depth = tokens[3]
          raster = tokens[4:]
        model = {'type': magic_num, 'dimension': (res_x, res_y, depth), 'raster': raster}
        return model
    return tokenize(left_file) == tokenize(right_file)

def diff_json_loosely(left_file, right_file):
    import json
    import math
    left_obj = json.load(left_file)
    right_obj = json.load(right_file)
    def equal_with_float_looseness(left, right):
        tolerance = 0.001
        tl, tr = type(left), type(right)
        if tl != tr: return False
        if tl is float: return left - tolerance < right < left + tolerance
        if tl is list:
            return all(equal_with_float_looseness(*pair) for pair in zip(left, right))
        if tl is dict:
            if set(left.keys()) != set(right.keys()) : return False
            return all(equal_with_float_looseness(right[k], left[k]) for k in left)
        return True
    return equal_with_float_looseness(left_obj, right_obj)

def run_argline(argline, tmp_fh, tmp_fn, testee, target_test):
    # TODO: respect PROG whether it's on-the-PATH or it's relative-path
    argline = argline.split()
    # set up CWD
    old_cwd = os.getcwd()
    os.chdir(target_test)
    # fix up argline using TMP
    argline2 = [tmp_fn if word == 'TMP' else word for word in argline]
    # fix up argline using PROG
    argline3 = [testee if word == 'PROG' else word for word in argline2]
    # run it
    subprocess.call(argline3)
    # repair CWD
    os.chdir(old_cwd)

def run_and_compare_arglines(arglines, testee, target_test, clean_up_tmpfiles=CLEAN_UP_TMPFILES, differ=diff_pnms):
    tmpfiles = []
    try:
        for argline in arglines:
            tmp_fh, tmp_fn = tempfile.mkstemp()
            #print("tempfile", tmp_fn)
            tmpfiles.append((tmp_fh, tmp_fn))
            run_argline(argline, tmp_fh, tmp_fn, testee, target_test)
        correctnesses = []
        for outfile_fh, outfile_fn in tmpfiles[1:]:
            with open(tmpfiles[0][1]) as truth:
              with open(outfile_fn) as candidate:
                correctnesses.append(differ(truth, candidate))
        return len(correctnesses) - sum(correctnesses, 0)    # exit value is the number of mismatches
    finally:
        if clean_up_tmpfiles:
            for tmpfile in tmpfiles:
                os.remove(tmpfile[1])

