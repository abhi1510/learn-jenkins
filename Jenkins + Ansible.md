## Install Ansible Docker + Jenkins

https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip

- Create a Dockerfile for building a jenkins container with ansible installed

```shell
mkdir jenkins-ansible
cd jenkins-ansible
vi Dockerfile
```

- The contents of Dockerfile should be

```shell
FROM jenkins/jenkins

USER root

RUN apt update && \
    apt install -y python3-pip && \
    pip3 install ansible --upgrade

USER jenkins
```

- Update the docker-compose.yml to instruct building jenkins image with the context as

```shell
jenkins:
    container_name: jenkins
    image: jenkins/ansible
    build:
      context: jenkins-ansible
    ports:
      - "8080:8080"
    volumes:
      - "$PWD/jenkins_home:/var/jenkins_home"
    networks:
      - net
```

- Build image and run containers

```shell
docker-compose build
docker-compose up -d
```

## Make the ssh keys permanent on the Jenkins container

`Serving files between containers and hosts`
The files between the host and containers can be shared using the concept of volumes. When we have defined 
```shell
volumes:
      - "$PWD/jenkins_home:/var/jenkins_home"
```
a folder is there called jenkins_home mapped to /var/jenkins_home inside the jenkins container. Any changes in any one of the folder will be reflected in both the places.
So now let's create a folder inside host's jenkins_home as below
```shell
mkdir jenkins_home/ansible
cp centos7/remote-key jenkins_home/ansible
```

## Create a simple Ansible Inventory

https://docs.ansible.com/ansible/2.3/intro_inventory.html

- An inventory in ansible is a core concepts and it is where we define all the hosts. So lets create an inventorty as

```shell
cd jenkins-ansible 
cp ../centos7/remote-key .
vi hosts
 ```
 
 - Define the hosts as

```shell
[all:vars]

ansible_connection = ssh

[test]
test1 ansible_host=remote-host ansible_user=remote_user ansible_private_key_file=/var/jenkins_home/ansible/remote-key
```

- Copy the hosts file to the jenkins container ansible folder as

```shell
cp jenkins-ansible/hosts jenkins_home/ansible 
```

- Test the connection

```shell
docker exec it jenkins bash
cd $HOME
cd ansible
ansible -i hosts -m ping test1
```

## Create your first Ansible Playbook

https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html

- A playbook in ansibel is like a script which defines all the things that ansible should do.
- Create a playbook and bring it inside jenkins folder ansible:

```shell
cd jenkins-ansible 
vi play.yml
```
- play.yml contents

```shell
- hosts: test1
  tasks:
    - shell: echo Hello Ansible > /tmp/ansible-file
```

- Copy the play inside the jenkins container ansible folder and check it

```shell
cp jenkins-ansible/play.yml jenkins_home/ansible/
docker exec -it jenkins bash
cd $HOME
cd ansible
ls
```

- Run the playbook and check the file in remote-host container

```shell
ansible-playbook -i hosts play.yml
docker exec -it remote-host bash
cat /tmp/ansible-file
```

## Integrate Ansible and Jenkins (Ansible Plugin)

- Manage jenkins > Manage plugins
- Look for Ansible plugin and install it
 
## Execute Playbooks from a Jenkins Job

- Create a job "ansible-test" as a free style project
- Go to Build section in configure job
- Choose "Invoke Ansible Playbook"
- Playbook path - /var/jenkins_home/ansible/play.yml
- Inventory select "File or host list" - /var/jenkins_home/ansible/hosts
- Save and Build

## Add parameters to Ansible and Jenkins

```shell
- hosts: test1
  tasks:
    - debug:
        msg: "{{ MSG }}"
```

- Configure jenkins job ansible-test
- Under General, check "This project is Paramterised"
- Add String Parameter with Name as "ANSIBLE_MSG" and value as Hello Ansible
- Under Build > Invoke Ansible Playbook > Advanced
- Add Extra Variables, Key as MSG and value as $ANSIBLE_MSG
- Save and Build with Parameters

## Colorize Playbooks output

- Manage jenkins > Manage plugins
- Look for "AnsiColor" plugin and install it
- Configure jenkins job ansible-test
- Under Build Environment, Color "ANSI Console Output"
- Under Build > Invoke Ansible Playbook > Advanced
- Check "Colorized stdout"
- Save and Build with Parameters

## Create the DB that will hold all the users

```shell
docker exec -it db bash
mysql -u root -p
Enter password: 1234
mysql> show databases;
mysql> create database people;
mysql> use people;
mysql> create table register(id int(3), fname varchar(50), lname varchar(50), age int(3));
mysql> show tables;
mysql> desc register;
 ```
 
## Create a Bash Script to feed your DB
 
- A file with 50 random names called people.txt 
- Create a shell cript file called import.sh

```shell
#!/bin/bash

counter=0

while [ $counter -lt 50 ]; do
    let counter=counter+1

    fname=$(nl people.txt | grep -w $counter | awk '{print $2}' | awk -F ',' '{print $1}')
    lname=$(nl people.txt | grep -w $counter | awk '{print $2}' | awk -F ',' '{print $2}')
    age=$(shuf -i 20-25 -n 1)

    mysql -u root -p1234 people -e "insert into register values ($counter, '$fname', '$lname', $age)"
    echo "$counter, $fname, $lname, $age inserted!"

done
```

- Copy the files inside db container and import records

```shell
chmod +x jenkins-ansible/import.sh 
docker cp jenkins-ansible/people.txt db:/tmp/
docker cp jenkins-ansible/import.sh db:/tmp
docker exec -it db bash
cd /tmp
./import.sh
```

## Build a Docker Nginx Web Server + PHP
 
 - For building the image refer jenkins-ansible/web folder in code repo
 - Update docker-compose as:

```shell
web:
    container_name: web
    image: ansible-web
    build:
      context: jenkins-ansible/web
    ports:
      - "80:80"
    networks:
      - net
```
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
