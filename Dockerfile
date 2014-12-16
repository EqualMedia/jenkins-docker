FROM fedora:20

RUN yum update -y -q; yum clean all
RUN yum --enablerepo updates-testing install -y -q python-pip java-headless dejavu-sans-fonts git wget docker-io parallel; yum clean all; pip install awscli

ENV JENKINS_VERSION 1.588
RUN yum install -y -q http://pkg.jenkins-ci.org/redhat/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm

ENV JENKINS_HOME /var/lib/jenkins

ADD jenkins.sh /srv/jenkins/jenkins.sh
ADD jenkins_backup.sh /srv/jenkins/jenkins_backup.sh

EXPOSE 8080
VOLUME /var/lib/jenkins
WORKDIR /var/lib/jenkins

ENTRYPOINT ["/srv/jenkins/jenkins.sh"]
