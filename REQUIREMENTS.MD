EKS module stuff
  * option to enable/disbale private link
  * different subnets for different worker group
  * launch template for each worker group
  * security group different for each worker group (not on priority as of now )
  * option to enable/disable envelop encryption
  * kms encryption option to encryption root ebs and other secondary ebs  in worker group
  * OIDC support ( Need to create our odic for eks, not on priority as of now )
  * EKS master on pre defined subnets (This is important , ask @bhupender singh for those subnets)
  * Enable support for Fargate profile
  * Enable support for Self Managed WorkerGroup 
  // Node group doen't provide option to choose custom AMI as of now thus support of self Managed workergroup is importatant
