
#!/bin/bash
# delete .terraform
rm -Rf .terraform

# init
terraform init

# plan
terraform plan -out plan.tfplan