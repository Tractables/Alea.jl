max_int_version = '(*|toggle|*)Axiom num_tests : nat. Extract Constant num_tests => "max_int".'
small_int_version = '(*|toggle|*)Axiom num_tests : nat. Extract Constant num_tests => "100000".'

# Look at all that has .v output, change max_int_version with small_int_version
import glob
import sys

try:
    mode = sys.argv[1]
except:
    mode = None

for file in filter(lambda name: name.endswith("Fuzzer.v"), glob.iglob(pathname="**", recursive=True)):
    with open(file, "r") as fuzzerfile:
        lines = fuzzerfile.read().splitlines()
    
    with open(file, "w") as fuzzerfile:
        for line in lines:
            if line == max_int_version and mode != "to_max":
                print("Max int version found")
                fuzzerfile.write(small_int_version + "\n")
            elif line == small_int_version and mode != "to_small":
                print("Small int version found")
                fuzzerfile.write(max_int_version + "\n")
            else:
                fuzzerfile.write(line + "\n")