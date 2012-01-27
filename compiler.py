#! /usr/bin/python

# unix usage: 
#   ./compiler.py list of nontest sources for executable output
# dos usage: 
#   python compiler.py list of nontest sources for executable output 

# prints error messages and list of executables
# writes complete output on "outputforcompiler.txt"

import os, subprocess, re, sys


files = os.listdir(os.getcwd())
functors = filter(lambda x: x[-2:] == 'oz', files)
fileLobes = os.listdir(os.getcwd() + "/lobes")
lobes = filter(lambda x: x[-2:] == 'oz', fileLobes)
executableTests = filter(lambda x: 'Test' in x, functors) + sys.argv[1:]
executablePlays = filter(lambda x: 'PlayGo' in x, functors) + sys.argv[1:]

###############################  compilations ###########################

fout = open('outputforcompiler.txt', 'w')
for f in lobes:
          sp = subprocess.Popen("ozc -c lobes/%s" %f, shell=True, stderr = fout)
          sp.wait()
          # os.system("ozc -c %s" %f)
for f in functors:
        if (not (f in executableTests) and not (f in executablePlays)):
                sp = subprocess.Popen("ozc -c %s" %f, shell=True, stderr = fout)
                sp.wait()
                # os.system("ozc -c %s" %f)
for e in executableTests:
        sp = subprocess.Popen("ozc -x %s" %e, shell=True, stderr = fout)
        sp.wait()
        # os.system("ozc -x %s" %e)
for e in executablePlays:
        sp = subprocess.Popen("ozc -x %s" %e, shell=True, stderr = fout)
        sp.wait()
        # os.system("ozc -x %s" %e)
fout.close()

############################# informative output #########################

fout = open('outputforcompiler.txt', 'r')
message = fout.read()
block = re.compile( r'Mozart Compiler(?:.|\n)+?(?:accepted|rejected)')
segments = block.findall(message)

bad_count = 0
for b in segments:
        if b[-8:] == 'rejected':
                bad_count+=1
                print b
fout.close()

print 'bad compiles: ' + str(bad_count)
if bad_count==0: 
   print '\n   '.join(['compiled for execution'] + executablePlays + executableTests)


# changes to KunWoo's version by JAZ

#    made this script unix executable 
#      (copies checked out from subversion probably need this command
#                    chmod +x compiler.py
#      for this change to work)

#    made it so that
#        <whatever>compiler.py arg1.oz arg2.oz ...
#    will compile listed files as executable  

#    cleaned up output and commented source code
