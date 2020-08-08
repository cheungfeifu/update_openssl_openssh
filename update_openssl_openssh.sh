#!/bin/bash

#升级openssl和openssh

yum install  -y gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel  pam-devel

yum install  -y pam* zlib*

cd /data

wget https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2r.tar.gz	

wget  https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/openssh-8.0p1.tar.gz


tar xfz openssl-1.0.2r.tar.gz

openssl version

mv /usr/bin/openssl /usr/bin/openssl_bak

mv /usr/include/openssl /usr/include/openssl_bak

cd /data/openssl-1.0.2r/

./config shared && make && make install

echo $?


ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl

echo "/usr/local/ssl/lib" >> /etc/ld.so.conf

/sbin/ldconfig

echo "openssl update success"


#开始升级openssh

cd /data

tar xfz openssh-8.0p1.tar.gz

cd openssh-8.0p1

chown -R root.root /data/openssh-8.0p1

rm -rf /etc/ssh/*

./configure --prefix=/usr/ --sysconfdir=/etc/ssh  --with-openssl-includes=/usr/local/ssl/include --with-ssl-dir=/usr/local/ssl   --with-zlib   --with-md5-passwords   --with-pam  && make && make install

echo $?


sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

sed -i 's/#UseDNS no/UseDNS no/g' /etc/ssh/sshd_config

echo "AllowUsers root" >> /etc/ssh/sshd_config

echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com,aes256-cbc" >> /etc/ssh/sshd_config

cp -a contrib/redhat/sshd.init /etc/init.d/sshd

cp -a contrib/redhat/sshd.pam /etc/pam.d/sshd.pam

chmod +x /etc/init.d/sshd

chkconfig --add sshd


systemctl enable sshd

mv  /usr/lib/systemd/system/sshd.service  /data/

chkconfig sshd on

systemctl restart sshd


ssh -V

echo "openssh update success"




















