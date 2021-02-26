### This project uses terraform to manage a AWS instance

1) A VPC, subnet, internet gateway, route table, security group will be created.
2) An EC2 instance with amazon-linux OS will be created and the 'entry-script.sh' will be run. The key-pair for the instance will be id_rsa and id_rsa.pub from your ~/.ssh/ folder.
3) Check the 'terraform.tfvars' file. The file has some parameters specific to the maching in which the terraform command is run.


#### Commands

    - terraform plan
    - terraform apply -auto-approve
    - terraform destroy
    - terraform state list
    - terraform state show '<item>'
