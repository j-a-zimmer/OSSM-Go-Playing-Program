#! /usr/bin/python

import subprocess, os

os.system('python compiler.py')

allfiles = os.listdir(os.getcwd())

oztestfiles = [x for x in allfiles if ('.' not in x) and x[:4] == 'Test']

for test in oztestfiles:
	print 'running program %s' % test
	try:
		subprocess.check_call('./%s' % test)
		print '%s has succeeded' % test
	except subprocess.CalledProcessError:
		print '%s has failed' % test

