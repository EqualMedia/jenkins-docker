#!/bin/bash

: ${JENKINS_HOME_S3_BUCKET_NAME:-}

jenkins_home_sync() {
  if [[ -n ${JENKINS_HOME_S3_BUCKET_NAME} ]]; then
    aws s3 sync \
      --delete \
      --exclude 'war/*' \
      --exclude 'userContent/*' \
      s3://${JENKINS_HOME_S3_BUCKET_NAME}/jenkins_home/ ${JENKINS_HOME}
  else
    echo 'Unable to sync existing jenkins configuration. JENKINS_HOME_S3_BUCKET_NAME is unset.'
  fi
}

# Allow to pass in jenkins options after --
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  jenkins_home_sync

  if [[ $? -eq 0 ]]; then
    exec java ${JAVA_OPTS} -jar /usr/lib/jenkins/jenkins.war ${JENKINS_OPTS} "$@"
  fi
fi

# If number of args is more than 1 and no jenkins options are given, start
# given command instead
exec "$@"

