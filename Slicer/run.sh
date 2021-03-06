#!/usr/bin/env python

import subprocess, shutil, os, re

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--coverage", help="open html coverage report", action='store_true')
parser.add_argument("--view", help="open 5AxLerViewer", action='store_true')
args = parser.parse_args()

#set up
os.chdir("./build/CMakeFiles/_CuraEngine.dir/src/")
subprocess.call("rm *.gcda", shell=True)
subprocess.call("rm *.gcov", shell=True)
subprocess.call("rm *.gcno", shell=True)

os.chdir("./5axis/")
subprocess.call("rm *.gcda", shell=True)
subprocess.call("rm *.gcov", shell=True)
subprocess.call("rm *.gcno", shell=True)


os.chdir("../../../../..")

#run tests
#subprocess.call('./build/CuraEngine slice -v -j ./5axistests/fdmprinter.def.json -o "test.gcode" -e0 -l "./5axistests/simple.STL"', shell=True)
#subprocess.call('./build/CuraEngine slice -v -j ./5axistests/fdmprinter.def.json -o "test.gcode" -e0 -l "./5axistests/radial_overhang.STL"', shell=True)
subprocess.call('./build/CuraEngine decompose -v -j ./5axistests/fdmprinter.def.json -o "test.gcode" -e0 -l "./5axistests/simple.STL"', shell=True)

for filename in os.listdir('./output/subvolumes'):
    if(filename != ".DS_Store"):
        s= "admesh --fill-holes --normal-directions --normal-values  --write-binary-stl=./output/subvolumes/"
        s+=filename
        s+= " ./output/subvolumes/"
        s+=filename
        subprocess.call(s, shell=True)


subprocess.call('./build/CuraEngine slice -v -j ./5axistests/fdmprinter.def.json -o "test.gcode" -e0 -l "./output/subvolumes/output_decomp_1.STL"', shell=True)


if args.coverage:
	#generate HMTL coverage file
    os.chdir("./build/CMakeFiles/_CuraEngine.dir/src/5axis")
    subprocess.call("lcov --directory . --capture -o cov.info", shell=True)
    subprocess.call("genhtml cov.info -o output", shell=True)
    subprocess.call("open ./output/index.html", shell=True)
    os.chdir("../../../../..")

if args.view:
    str = ""
    for f in os.listdir("."):
        if re.match("output_decomp_", f):
            str += "../../Slicer/" + f + " "
    subprocess.call('ls', shell=True)
    os.chdir("../Viewer/build")
    subprocess.call('./5AxLerViewer ' + str, shell=True)
    os.chdir("../../Slicer")

