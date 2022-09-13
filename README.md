# Terraform to deploy our cloud infrastructure

Terraform is used to deploy the cloud infrastructure of the D3I pilot, all cloud configurations are in the config file.


# Secure the terraform.tfstate file 

If you want to apply changes to the cloud infrastructure terraform needs to know the current state.
If you want to work accross multiple instances or with multiple devs, they all need to be able to access this statefile.
The statefile also contains sensitive information, and therefore needs to be locked away.
The solution is to store this statefile in blobstorage to do this: 

1. Create a resource group 
2. Create Storage account + container
3. Configure `main.tf`

# Generate secrets and keys

Generate keys for data encryption:

```
openssl genrsa -out privatekey.pem 2048
openssl rsa -in privatekey.pem -out publickey.pem -pubout -outform PEM
```

Add all nessesary secrets and keys to pass

```
pass generate /terraformtest/postgres_username 10
pass generate /terraformtest/postgres_password 30
pass insert --multiline /terraformtest/data_encryption_public_rsa_key
```

Use terraform plan, apply, destroy with the correct environmental variables set, by using the provided scripts, `./plan.sh`, `./apply.sh` and `./destroy.sh`.


# Tutorials

[https://www.youtube.com/watch?v=7xngnjfIlK4](Video 1)
[https://www.youtube.com/watch?v=RTEgE2lcyk4](Video 2)
[https://pontifex.dev/posts/terraform-azure-managed-identity/](Blog about managed identities)
[https://docs.microsoft.com/en-au/azure/templates/](Link to the ARM templates)
[https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1](Link to tips managing secrets in Terraform)


## The sequence of commands are:

```
terraform init          # Initialize
terraform fmt           # Formats your config files neatly
terraform validate      # Validates your configs
terraform plan          # Checks the tfstate file, what changes need to be apply
terraform apply         # Applies the changes
terraform destroy       # Destroys all resources
```

## Notes
On linux a working nameserver needs to be set in /etc/resolv.conf
Even if you do not use /etc/resolv.conf config yourself, terraform needs it


