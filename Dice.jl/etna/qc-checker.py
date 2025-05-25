import os
import sys

qc_path = os.environ['OPAM_SWITCH_PREFIX'] + '/lib/coq/user-contrib/QuickChick'

try:
    mode = sys.argv[1]
except:
    mode = None

with open(f"{qc_path}/Test.v") as file:
    contents = file.read()
    if "let compFun maxSuccess maxSize n d := computeSize' a n d in" in contents:
        print("This is updated QuickChick")
        if mode == "use_old_qc":
            raise Exception("Must use old QuickChick version, this is the new version.")
    elif "let compFun maxSuccess maxSize n d := maxSize in" in contents:
        print("This is the old QuickChick")
        if mode == "use_new_qc":
            raise Exception("Must use new QuickChick version, this is the old version.")
    else:
        raise Exception("QuickChick version is not recognized")