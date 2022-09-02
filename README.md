# infrastructure



## Getting started

First of all you need to create IAM user for terraform. Then set up AWS CLI credentials and create profile called ``coingate``

Requirements:
1. AWS CLI installed
2. Terraform v1.2.8 or compatible


## Build infrastructure

1. Run ``terraform init`` in etc/prod/init directory
2. Run ``terraform apply`` in etc/prod/init directory
3. Run ``terraform init`` in etc/prod directory
4. Run ``terraform apply`` in etc/prod directory

### Done! Now you have infrastructure for CoinGate test task



## Original task: 

Deploy a publicly available application to the ECS on GitHub push trigger.
The application must provide two endpoints:
- One endpoint prints an encrypted "Hello, World!" string using AES with a secret value pulled from AWS Secret Manager.
- The second is the protected (authentication, IP whitelist, etc. Your choice.) endpoint which updates the secret value used to encrypt the "Hello, World!" string in AWS Secret Manager. All changes must be logged in S3 with the old secret value, IP and user agent of whom the change was made.
- Use any programming language you want.
- Infrastructure must be described with Terraform.
- The deployment must be zero downtime.
- Use load balancer.
