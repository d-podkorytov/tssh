echo --=== Init Keys for TSSH 
echo --= See /etc/esshd
mkdir /etc/esshd
ssh-keygen -t rsa -f /etc/esshd/ssh_host_rsa_key
ls -l /etc/esshd