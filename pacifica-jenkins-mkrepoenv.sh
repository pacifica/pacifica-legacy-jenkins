#!/bin/bash
set -x
DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "x${JENKINS_JAR}" = "x" ]
then
	JENKINS_JAR=/tmp/jenkins-cli.jar
fi
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
if [ ! -f ${JENKINS_JAR} ]
then
	curl -o ${JENKINS_JAR} ${JENKINS_URL}/jnlpJars/jenkins-cli.jar
fi
if [ "x${JENKINS_REPOENV}" == "x" ]
then
	JENKINS_REPOENV="main"
fi
if [ "x${JENKINS_DISTS}" == "x" ]
then
	JENKINS_DISTS="epel-5-x86_64 epel-6-x86_64 fedora-18-x86_64"
fi

mkdir -p generated/envs
mkdir -p generated/jobs
mkdir -p generated/mock
pushd $DIR/envs
for DIST in ${JENKINS_DISTS};
do
	./repoenvgen.py -n ${JENKINS_REPOENV} -b pacifica -j "${JENKINS_URL}/jobs" -d $DIST > ../generated/envs/pacifica-$DIST-${JENKINS_REPOENV}.repo
	sed -e "/@REPOS@/r ../generated/envs/pacifica-$DIST-${JENKINS_REPOENV}.repo" -e "/@REPOS@/d" ../mock/$DIST.cfg.in | sed "s/@NAME@/pacifica-$DIST-${JENKINS_REPOENV}/g" > ../generated/mock/pacifica-$DIST-${JENKINS_REPOENV}.cfg
done
popd

