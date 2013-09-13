#!/usr/bin/python

import ConfigParser
from optparse import OptionParser

def main():
	parser = OptionParser()
	parser.add_option("-n", "--name", dest="name", help="environment name")
	parser.add_option("-b", "--base", dest="base", help="environment base type")
	parser.add_option("-d", "--dist", dest="dist", help="which dist to use", default='@DIST@')
	parser.add_option("-j", "--jenkins", dest="jenkins", help="base jenkins url", default='@JENKINS_URL@')
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
	distmap_list = {}
	for (job, dists) in config.items('distlist'):
		distmap_list[job] = dict([(i.strip(), 1) for i in dists.split(',')])
	nodist_list = {}
	for (job, value) in config.items('nodist'):
		nodist_list[job] = 1
	nolabel_list = {}
	for (job, value) in config.items('nolabel'):
		nolabel_list[job] = 1
	norepo_list = {}
	for (job, value) in config.items('norepo'):
		norepo_list[job] = 1
	first = True
	for job in l:
		if job in norepo_list:
			continue
		dist = parser.values.dist
		branch = general_list[job]
		if job in distmap_list and dist not in distmap_list[job]:
			continue
		if first == False:
			print
		first = False
		print "[%s]" %(job)
		distpart=''
		if job not in nodist_list:
			distpart="DIST=%s%%2c" %(dist)
		labelpart=''
		if job not in nolabel_list:
			labelpart="label=%s" %(parser.values.base)
		print "name = Jenkins %s" %(job)
		print "baseurl = %s/%s-%s/%s%s/lastSuccessfulBuild/artifact/repo" %(parser.values.jenkins, job, branch, distpart, labelpart)
		print "enabled = 1"
		print "protect = 0"
		print "gpgcheck = 0"
		print "skip_if_unavailable = 1"

if __name__ == '__main__':
	main()
