FROM jenkins/jenkins

USER root

RUN apt update && \
    apt install -y python3-pip && \
    pip3 install ansible --upgrade

USER jenkins

