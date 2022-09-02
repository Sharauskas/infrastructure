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
