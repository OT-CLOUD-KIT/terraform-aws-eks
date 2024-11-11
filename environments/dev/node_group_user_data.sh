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
      set -ex
      iptables -I INPUT -p tcp -m tcp --dport 10250 -j ACCEPT
      cd /etc/eks
      sudo chmod +x bootstrap.sh
      /etc/eks/bootstrap.sh OT-microservices
--//