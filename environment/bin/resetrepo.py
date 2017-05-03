#!/usr/bin/env python
# resetrepo [.repo]

import errno
import filecmp
import glob
import os
import random
import re
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
import time
import traceback

def main(orig_args):
  cmd, opt, args = _ParseArguments(orig_args)

if __name__ == '__main__':
  main(sys.argv[1:])
