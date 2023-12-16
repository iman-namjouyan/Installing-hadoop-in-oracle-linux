#!/bin/bash
#----------------------------(Comments)
# This script preapre hadoop cluster install.
# Note: Before run this script install "sshpass" tools.
# Example: dnf install sshpass -y
#----------------------------(Declare Functions)
SET_HOSTNAME(){
hostnamectl set-hostname k8s-worker01 --static
hostnamectl set-hostname k8s-worker02 --static
hostnamectl set-hostname k8s-worker03 --static
}

CREATE_SSHKEYGEN(){
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
}

COPY_KEYS(){
sshpass -p "123456" ssh-copy-id -o StrictHostKeyChecking=no localhost
sshpass -p "123456" ssh-copy-id -o StrictHostKeyChecking=no k8s-worker01
sshpass -p "123456" ssh-copy-id -o StrictHostKeyChecking=no k8s-worker02
sshpass -p "123456" ssh-copy-id -o StrictHostKeyChecking=no k8s-worker03
}

EDIT_HOSTFILE(){
cat <<EOF>> /etc/hosts
10.0.85.214    k8s-worker01
10.0.85.216    k8s-worker02
10.0.85.217    k8s-worker03
}

CREATE_USER(){
useradd hadoop
}

INSTALL_JDK(){
dnf install -y java-latest-openjdk java-latest-openjdk-devel
}

GET_HADOOP_SOURCE(){
cd /opt
curl -O http://10.0.49.40/software/hadoop/hadoop-3.2.4.tar.gz
tar xzfv hadoop-*.gz
rm -rf hadoop-*.gz
mv hadoop* hadoop
chown -R hadoop:hadoop hadoop
}

SET_JAVA_PATHS(){
echo "JAVA_HOME=$(which java)" >> /etc/environment
source /etc/environment
cp /etc/bashrc{,.bak}

cat <<EOF>>/etc/bashrc
export HADOOP_HOME=\$HOME/hadoop
export PATH=\${PATH}:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin
EOF

cat <<EOF>>/etc/profile
PATH=\$HOME/hadoop/bin:\$HOME/hadoop/sbin:\$PATH
EOF

export JAVA_INSTALL_DIR=$(update-alternatives --display java|grep "link currently points"|awk {'print $5'}|sed 's/bin\/java//')
# Note: On this case we installed jre rpm file.
sed -i "/# export JAVA_HOME=/ a export JAVA_HOME=$JAVA_INSTALL_DIR" /opt/hadoop/etc/hadoop/hadoop-env.sh


}



