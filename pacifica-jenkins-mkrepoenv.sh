#!/bin/bash
set -x
DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "x${JENKINS_URL}" = "x" ]
then
	JENKINS_URL=http://127.0.0.1:8080
fi
if [ "x${JENKINS_CONFIG_PREFIX}" = "x" ]
then
	JENKINS_CONFIG_PREFIX="$DIR/jobs"
fi
JENKINS_OPTIONS=""
if [ "x${JENKINS_USERNAME}" != "x" ]
then
	JENKINS_OPTIONS="${JENKINS_OPTIONS} --username ${JENKINS_USERNAME}"
fi
if [ "x${JENKINS_PASSWD_FILE}" != "x" ]
then
	JENKINS_OPTIONS="${JENKINS_OPTIONS} --password-file ${JENKINS_PASSWD_FILE}"
fi
if [ "x${JENKINS_REPOENV}" == "x" ]
then
	JENKINS_REPOENV="main"
fi
if [ "x${JENKINS_DISTS}" == "x" ]
then
	JENKINS_DISTS="epel-5-x86_64 epel-6-x86_64 fedora-18-x86_64"
fi
if [ "x${JENKINS_JOBS}" == "x" ]
then
	pushd envs
	JENKINS_JOBS=`./repoenvbranchlist.py -b pacifica -n ${JENKINS_REPOENV} -a | sed 's/=.*//' | tr '\n' ' '`
	popd
fi

mkdir -p generated/envs
mkdir -p generated/jobs
mkdir -p generated/mock
mkdir -p generated/views
mkdir -p generated/tmp
rm -rf generated/tmp/viewchunk.$$
pushd $DIR/envs
for DIST in ${JENKINS_DISTS};
do
	./repoenvgen.py -n ${JENKINS_REPOENV} -b pacifica -j "${JENKINS_URL}/job" -d $DIST > ../generated/envs/pacifica-$DIST-${JENKINS_REPOENV}.repo
	sed -e "/@REPOS@/r ../generated/envs/pacifica-$DIST-${JENKINS_REPOENV}.repo" -e "/@REPOS@/d" ../mock/$DIST.cfg.in | sed "s/@NAME@/pacifica-$DIST-${JENKINS_REPOENV}/g" > ../generated/mock/pacifica-$DIST-${JENKINS_REPOENV}.cfg
done
for jobname in ${JENKINS_JOBS};
do
	branch=`./repoenvbranchlist.py -n ${JENKINS_REPOENV} -b pacifica -j $jobname`
	bprefix=''
	if [ "x$branch" != "x" ]
	then
		bprefix="-"
	fi
	echo "<string>$jobname$bprefix$branch</string>" >> ../generated/tmp/viewchunk.$$
	sed "s/@BRANCH@/$branch/g;s/@REPOENV@/${JENKINS_REPOENV}/g" ../jobtmpls/$jobname-config.xml.in > ../generated/jobs/$jobname$bprefix$branch-config.xml
done
popd
sed -e "/@JOBS@/r generated/tmp/viewchunk.$$" -e "/@JOBS@/d" viewtmpls/pacifica.xml.in | sed "s/@NAME@/pacifica-${JENKINS_REPOENV}/g" > generated/views/pacifica-$JENKINS_REPOENV.xml

