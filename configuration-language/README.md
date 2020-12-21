# Write Terraform Configuration

Learn [Terraform configuration](https://learn.hashicorp.com/collections/terraform/configuration-language) language by example. Write configurations to manage multiple pieces of infrastructure and iterate over structured data. Deploy and manage related infrastructure by referring to resources in other configurations.

## Define Infrastructure with Terraform Resources

Terraform uses [resources](https://www.terraform.io/docs/configuration/resources.html) to manage infrastructure, such as virtual networks, compute instances, or higher-level components such as DNS records. Resource blocks represent one or more infrastructure objects in your Terraform configuration.

In this tutorial, you will create an EC2 instance that runs a PHP web application, and then use the [Terraform Registry](https://registry.terraform.io/) to create a security group to make the app publicly accessible.

## Prerequisites

This tutorial assumes you are familiar with the standard Terraform workflow. If you are unfamiliar with Terraform, complete the Get Started tutorials first.

For this tutorial, you will need:

- an AWS account
- a GitHub account

## Set up and explore your Terraform workspace

Clone the Learn Terraform Resources git repository.

``` BASH
git clone https://github.com/hashicorp/learn-terraform-resources.git
```

Navigate to the repo directory in your terminal.

``` BASH
cd learn-terraform-resources
```

There are three files in this directory.

- `init-script.sh` contains the provisioning script to install dependencies and start a sample PHP application
- `terraform.tf` contains the `terraform block` defines `required_providers`.

`main.tf` contains the configuration for an EC2 instance.

By exploring the resources in main.tf, you will learn how to define resources using arguments and attributes.

Open `main.tf` and notice the two resources blocks: `random_pet.name` and `aws_instance.web` .

## Explore the random pet name resource

The random pet name resource block defines a `random_pet` resource named `name` to generate a random pet name. You will use the name that the `random_pet` resource generates to create a unique name for your EC2 instance.

 `resource "random_pet" "name" {}`

- Resource blocks declare a resource type and name.
- The type and name combine into a resource identifier (ID) in the format `resource_type.resource_name`, in this case `random_pet.name`.
- The resource's ID must be unique because Terraform uses it to refer to the resource. When Terraform displays information about this resource in its output it will use the resource ID.

Resource types always start with the provider name followed by an underscore. The `random_pet` resource type belongs to the `random` provider.

The Terraform Registry houses the documentation for Terraform providers and their associated resources. Open the [random_pet documentation page](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) and notice that it is nested under the documentation for the random provider. The page contains a description of the random_pet resource, an example usage, argument reference, and attribute reference.

Resources have arguments, attributes and meta-arguments.

- [Arguments](https://www.terraform.io/docs/configuration/resources.html#resource-arguments) configure a particular resource; because of this, many arguments are resource-specific. Arguments can be `required` or `optional`. Terraform will give an error and not apply the configuration at all if a required argument is missing.

- [Attributes](https://www.terraform.io/docs/configuration/resources.html#accessing-resource-attributes) are values exposed by a particular resource. References to resource attributes takes the format `resource_type.resource_name.attribute_name`. Unlike arguments which specify an infrastructure object's configuration, a resource's attributes are often assigned to them by the underlying cloud provider or API.

- [Meta-arguments](https://www.terraform.io/docs/configuration/resources.html#meta-arguments) change a resource type's behavior, and are not resource-specific. For example,     `count` and `for_each` to create multiple resources.

The `random_pet` resource has four optional arguments and one attribute. Because there are no required arguments, the `random_pet.name` resource can be empty.

## Explore the EC2 instance resource

The `aws_instance.web` resource block defines an `aws_instance` resource named `web` to create an AWS EC2 instance.

``` terraform
resource "aws_instance" "web" {
  ami                    = "ami-a0cfeed8"
  instance_type          = "t2.micro"
  user_data              = file("init-script.sh")

  tags = {
    Name = random_pet.name.id
  }
}
```

The arguments inside the aws_instance.web resource block specify what type of resource to create.

- The `ami` and `instance_type` arguments tell the AWS provider to create an EC2 `t2.micro` instance using an `ami-a0cfeed8` image.
- The `user_data` argument uses the [file()](https://www.terraform.io/docs/configuration/functions/file.html) function to return the contents of init-script.sh. To learn more about how to use functions and dynamic expressions in your configuration, refer to the [Perform Dynamic Operations with Functions](https://learn.hashicorp.com/tutorials/terraform/functions?in=terraform/configuration-language) and [Create Dynamic Expressions](https://learn.hashicorp.com/tutorials/terraform/expressions?in=terraform/configuration-language) tutorials.
- The `tags` argument specifies this EC2 instance's name. Notice how the argument references the `random_pet.name`'s ID attribute (`random_pet.name.id`) to give the EC2 instance a unique name. This makes the EC2 instance resource implicitly dependent on the random pet resource; Terraform can't create the instance until it has a name for it. To learn more about Terraform dependencies, refer to the [Create Resource Dependencies](https://learn.hashicorp.com/tutorials/terraform/dependencies?in=terraform/configuration-language) tutorial.

These are only a subset of the available `aws_instances` arguments. Refer to the [aws_instance documentation page](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#argument-reference) for a complete list.

## Initialize and apply Terraform configuration

In your terminal, initialize the directory.

``` terraform
terraform init
```

Apply your configuration. The plan should show two resources being created. Remember to confirm your apply with a `yes` .

``` terraform
terraform apply
```

The `domain-name` output should display your newly created EC2 instance upon completion.

If you try to go to the URL, it won't resolve because there is no security group attached to the VM exposing port `80` . In the next section, you will create a new security group and add it to your EC2 instance.

## Add security group to instance

In order to access the EC2 instance's web server, you need a security group configured to allow ingress traffic on port `80` and all egress traffic.

Open the [AWS Provider documentation page](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). Search for `security_group` and select the `aws_security_group` resource.

Add a new `aws_security_group` resource named `web-sg` to `main.tf` that allows ingress traffic on port 80 and all egress traffic.

Use the [aws_security_group documentation page](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) to define your security group. On this page you will find an example usage, argument reference and attributes reference for the `aws_security_group` resource type.

If done correctly, your security group resource should be similar to the following.

``` terraform
resource "aws_security_group" "web-sg" {
  name = "${random_pet.name.id}-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Then, update your `aws_instance.web` resource to use this security group. The `vpc_security_group_ids` argument requires a list of security group IDs. You can verify this by looking at the [aws_instance Argument Reference section](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#vpc_security_group_ids).

Add the `vpc_security_group_ids` argument to the `aws_instance.web` resource as a list by placing the `aws_security_group.web-sg.id` attribute inside square brackets.

``` terraform
resource "aws_instance" "web" {
  ami                    = "ami-a0cfeed8"
  instance_type          = "t2.micro"
  user_data              = file("init-script.sh")

+ vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = {
    Name = random_pet.name.id
  }
}
```

Save your changes.

Next, apply your configuration. Remember to confirm your apply with a `yes` .

``` terraform
terraform apply
```

Verify that your EC2 instance is now publicly accessible.

``` BASH
terraform output application-url

curl $(terraform output domain-name)
```

## Clean up your infrastructure

Now that you have verified that the EC2 instance is publicly available, run `terraform destroy` to destroy the resources. Remember to respond to the confirmation prompt with `yes` .

``` terraform
terraform destroy
```
