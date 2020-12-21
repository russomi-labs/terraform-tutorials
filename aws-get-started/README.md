# Introduction to Infrastructure as Code with Terraform

Terraform is the infrastructure as code tool from HashiCorp. It is a tool for building, changing, and managing infrastructure in a safe, repeatable way. Operators and Infrastructure teams can use Terraform to manage environments with a configuration language called the HashiCorp Configuration Language (HCL) for human-readable, automated deployments.

## Workflows

A simple workflow for deployment will follow closely to the steps below. We will go over each of these steps and concepts more in-depth throughout these tutorials, so don't panic if you don't understand the concepts immediately.

1. Scope - Confirm what resources need to be created for a given project.
2. Author - Create the configuration file in HCL based on the scoped parameters
3. Initialize - Run terraform init in the project directory with the configuration files. This will download the correct provider plug-ins for the project.
4. Plan & Apply - Run terraform plan to verify creation process and then terraform apply to create real resources as well as state file that compares future changes in your configuration files to what actually exists in your deployment environment.

``` bash

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform show
terraform state list

```

## Define Input Variables

### From command line

``` bash
terraform apply \
  -var 'region=us-east-1'
```

### From a file

To persist variable values, create a file and assign variables within this file. Create a file named `terraform.tfvars` with the following contents:

``` bash
region = "us-east-1"
```

We don't recommend saving usernames and passwords to version control. You can create a local file with a name like `secret.tfvars` and use `-var-file` flag to load it.

``` bash
terraform apply \
  -var-file="default.tfvars" \
  -var-file="production.tfvars"
```

Reversing the order of the var-file parameters produces different results as expected.

``` bash
terraform apply \
  -var-file="production.tfvars" \
  -var-file="default.tfvars"
```

## Query Data with Output Variables

When building potentially complex infrastructure, Terraform stores hundreds or thousands of attribute values for all your resources. But as a user of Terraform, you may only be interested in a few values of importance, such as a load balancer IP, VPN address, etc.

Outputs are a way to tell Terraform what data is important. This data is outputted when apply is called, and can be queried using the terraform output command.

``` bash

terraform apply \
  -var-file="default.tfvars" \
  -var-file="production.tfvars"

terraform output ip
# 3.226.134.76

```

## Store Remote State

You have now seen how to build, change, and destroy infrastructure from a local machine. This is great for testing and development, but in production environments it is considered a best practice to store state elsewhere than your local machine. The best way to do this is by running Terraform in a remote environment with shared access to state.

Terraform supports team-based workflows with a feature known as remote backends. Remote backends allow Terraform to use a shared storage space for state data, so any member of your team can use Terraform to manage the same infrastructure.

Depending on the features you wish to use, Terraform has multiple remote backend options. HashiCorp recommends using Terraform Cloud.

If you don't have an account, please [sign up here](https://app.terraform.io/signup) for this tutorial. For more information on Terraform Cloud, [view our getting started tutorial](https://learn.hashicorp.com/collections/terraform/cloud-get-started).

``` json

terraform {
  backend "remote" {
    organization = "russomi"

    workspaces {
      name = "Example-Workspace"
    }
  }
}

```

You'll also need a user token to authenticate with Terraform Cloud. You can generate one on the [user settings page](https://app.terraform.io/app/settings/tokens).

Copy the user token to your clipboard, and create a Terraform CLI Configuration file and ~/.terraformrc on other systems.

Paste the user token into that file like so:

``` json
credentials "app.terraform.io" {
  token = "REPLACE_ME"
}
```

Now that you've configured your remote backend, run `terraform init` to setup Terraform. It should ask if you want to migrate your state to Terraform Cloud.

``` bash
terraform init

terraform plan \
  -var-file="default.tfvars"
  -var-file="production.tfvars"
```

## Next Steps

To keep learning by doing, get more familiar with the Terraform configuration language, provision the machines you create, or import existing infrastructure, visit the following tutorials.

[Configuration Language](https://learn.hashicorp.com/collections/terraform/configuration-language) - Get more familiar with variables, outputs, dependencies, meta-arguments, and other language features to write more sophisticated Terraform configurations.

[Modules](https://learn.hashicorp.com/tutorials/terraform/module) - Organize and re-use Terraform configuration with modules.

[Provision](https://learn.hashicorp.com/collections/terraform/provision) - Use Packer or Cloud-init to automatically provision SSH keys and a web server onto a Linux VM created by Terraform in AWS.

[Import](https://learn.hashicorp.com/tutorials/terraform/state-import) - Import existing infrastructure into Terraform.

To read more about available configuration options, explore the [Terraform documentation](https://www.terraform.io/docs/index.html).
