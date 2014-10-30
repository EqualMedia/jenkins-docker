#!/bin/bash

: ${JENKINS_HOME_S3_BUCKET_NAME:-}

jenkins_home_restore() {
  if [[ -n ${JENKINS_HOME_S3_BUCKET_NAME} ]]; then
    # persist jenkins config backup bucket
    echo "export JENKINS_HOME_S3_BUCKET_NAME=${JENKINS_HOME_S3_BUCKET_NAME}" > /etc/jenkins-bucket-config
    [[ -n ${AWS_SECRET_ACCESS_KEY} ]] && echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /etc/jenkins-bucket-config
    [[ -n ${AWS_ACCESS_KEY_ID} ]] && echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> /etc/jenkins-bucket-config

    aws s3 cp s3://${JENKINS_HOME_S3_BUCKET_NAME}/jenkins_home/jenkins_home.tar.gz /tmp

    if [[ -f /tmp/jenkins_home.tar.gz ]]; then
      cd ${JENKINS_HOME}
      tar -xzf /tmp/jenkins_home.tar.gz
      rm -f /tmp/jenkins_home.tar.gz
    fi
  else
    echo 'Unable to restore existing jenkins configuration. JENKINS_HOME_S3_BUCKET_NAME is unset.'
  fi
}

# Allow to pass in jenkins options after --
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  jenkins_home_restore

  if [[ $? -eq 0 ]]; then
    exec java ${JAVA_OPTS} -jar /usr/lib/jenkins/jenkins.war ${JENKINS_OPTS} "$@"
  fi
fi

# If number of args is more than 1 and no jenkins options are given, start
# given command instead
exec "$@"

