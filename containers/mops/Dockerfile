FROM jenkins/jenkins:latest-jdk17
# FROM jenkins/jenkins:lts
# TODO use cloudbees distribution
# ENV JENKINS_UC http://jenkins-updates.cloudbees.com
# ENV JENKINS_INCREMENTALS_REPO_MIRROR https://repo.jenkins-ci.org/incrementals
ENV JAVA_OPTS="\
    -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true \
    -Dhudson.model.UsageStatistics.disabled=true \
    -Djenkins.install.runSetupWizard=false \
    -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Ho_Chi_Minh \
    -Duser.timezone=Asia/Ho_Chi_Minh"

# -Dcom.cloudbees.jenkins.cjp.installmanager.CJPPluginManager.allRequired=true \
# -Xmx8192m \
# -Dhudson.model.Slave.workspaceRoot=/home/jenkins/agent/workspace \
# ENV JENKINS_OPTS="--handlerCountMax=300 --webroot=/var/cache/jenkins/war"
# ENV CASC_JENKINS_CONFIG="/usr/share/jenkins/casc_configs/jenkins.yaml"
# ENV PLUGINS_FORCE_UPGRADE=true
# ENV TRY_UPGRADE_IF_NO_MARKER=true

COPY casc.d /var/jenkins_home/casc.d
# COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
# RUN /usr/bin/jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
# RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
RUN /usr/bin/jenkins-plugin-cli --plugin-file /var/jenkins_home/casc.d/plugins.txt