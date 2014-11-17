import os,sys

fcc_path=os.environ.get("FCCBASE")
if fcc_path==None:
  sys.exit(1)
print fcc_path
sys.exit(0)
