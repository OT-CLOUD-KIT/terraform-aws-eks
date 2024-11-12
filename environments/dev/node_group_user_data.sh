Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0
	
--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"
	
#cloud-config
cloud-init directives
	
--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
      set -o xtrace
      sudo service docker start  
      sudo chmod 666 /var/run/docker.sock
      /etc/eks/bootstrap.sh OT-microservices
      iptables -I INPUT -p tcp -m tcp --dport 10250 -j ACCEPT 
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
--//