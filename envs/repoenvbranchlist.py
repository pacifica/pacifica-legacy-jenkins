#!/usr/bin/python

import ConfigParser
from optparse import OptionParser

def main():
	parser = OptionParser()
	parser.add_option("-n", "--name", dest="name", help="environment name")
	parser.add_option("-b", "--base", dest="base", help="environment base type")
	parser.add_option("-j", "--job", dest="job", help="job to list branch for")
	parser.add_option('-a', '--all', dest='alljobs', default=False, action='store_true', help="List all jobs")
	parser.add_option('-c', '--changed', dest='changed', default=False, action='store_true', help="List changed branches")
	(options, args) = parser.parse_args()
	config = ConfigParser.SafeConfigParser()
	config.read("%s/general.ini" %(parser.values.base))
	config.read("%s/%s.ini" %(parser.values.base, parser.values.name))
	general_list = {}
	for (key, value) in config.items('branch'):
		if value == '':
			value = 'master'
		general_list[key] = value
	l = general_list.keys()
	l.sort()
	nodist_list = {}
	for (job, value) in config.items('nodist'):
		nodist_list[job] = 1
	first = True
	for job in l:
		if parser.values.changed:
			if nodist_list.get(job):
				continue
			if general_list[job] != 'master':
				print "%s=%s" %(job, general_list[job])
			continue
		if parser.values.alljobs:
			if nodist_list.get(job):
				print job
				continue
			print "%s=%s" %(job, general_list[job])
			continue
		if job != parser.values.job:
			continue
		if nodist_list.get(job):
			print
			continue
		branch = general_list[job]
		print "%s" %(branch)

if __name__ == '__main__':
	main()
