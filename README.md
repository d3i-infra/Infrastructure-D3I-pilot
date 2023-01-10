# Terraform to deploy our cloud infrastructure

Terraform is used to specify our infrastructure as code (IaC). We will use Terraform to deploy the cloud infrastructure of the D3I pilot, all cloud configurations are in the config file. If changes need to be made to the cloud infrastructure, this has to be done using these config files.

Why are we doing it this way?

- We can apply version control to the IaC
- Our infrastructure will be replicable, by us and by others

# How to use Terraform

## Preparation

1. Install `terraform`. 
2. Install `azure cli` (az) (used by terraform to interact with Azure)
3. Run 'az login' to authenticate to the azure cli tool (az) and follow in structions

Look at the tutorials below to get the basics of terraform. 

The --use-device-code option below is only required if you don't have a browser on the system (bastion host)

    az login --use-device-code --tenant xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx

## Terraform initialisation

1. cd setupTerraForm
```
terraform init
```

Although not required you may want to look at / change variables in backend.conf

The above command creates an exclusive storage environment for terraform state.
Destroying resources of the app will not affect the terraform state.

## Deploy the web app

1. Decide if you need to edit the terraform.tfvars file to change variable values.
2. Run the command below

```
cd ..
cd setupd3i
terraform init -backend-config=backend.conf
time terraform apply -auto-approve
```

## Tutorials

- [Video 1](https://www.youtube.com/watch?v=7xngnjfIlK4)
- [Video 2](https://www.youtube.com/watch?v=RTEgE2lcyk4)
- [Blog about managed identities](https://pontifex.dev/posts/terraform-azure-managed-identity/)
- [Link to the ARM templates](https://docs.microsoft.com/en-au/azure/templates/)
- [Link to tips managing secrets in Terraform](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1)

### The sequence of commands are:

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


# Azure components of the d3i-pilot

![Azure components](/resources/Azure_components.svg)




