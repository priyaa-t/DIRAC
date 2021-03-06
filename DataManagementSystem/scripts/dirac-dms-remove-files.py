#!/usr/bin/env python
########################################################################
# $HeadURL$
########################################################################
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
__RCSID__ = "$Id$"

from DIRAC.Core.Base import Script

Script.setUsageMessage("""
Remove the given file or a list of files from the File Catalog and from the storage

Usage:
   %s <LFN | fileContainingLFNs>
""" % Script.scriptName)

Script.parseCommandLine()

import sys
import os
import DIRAC
from DIRAC import gLogger

args = Script.getPositionalArgs()
lfns = []
for inputFileName in args:
  if os.path.exists(inputFileName):
    inputFile = open(inputFileName, 'r')
    string = inputFile.read()
    inputFile.close()
    lfns.extend([lfn.strip() for lfn in string.splitlines()])
  else:
    lfns.append(inputFileName)

from DIRAC.Core.Utilities.List import breakListIntoChunks
from DIRAC.DataManagementSystem.Client.DataManager import DataManager
dm = DataManager()

errorReasons = {}
successfullyRemoved = 0
for lfnList in breakListIntoChunks(lfns, 100):
  res = dm.removeFile(lfnList)
  if not res['OK']:
    gLogger.error("Failed to remove data", res['Message'])
    DIRAC.exit(-2)
  for lfn, r in res['Value']['Failed'].items():
    reason = str(r)
    if reason not in errorReasons.keys():
      errorReasons[reason] = []
    errorReasons[reason].append(lfn)
  successfullyRemoved += len(res['Value']['Successful'].keys())

for reason, lfns in errorReasons.items():
  gLogger.notice("Failed to remove %d files with error: %s" % (len(lfns), reason))
if successfullyRemoved > 0:
  gLogger.notice("Successfully removed %d files" % successfullyRemoved)
DIRAC.exit(0)
