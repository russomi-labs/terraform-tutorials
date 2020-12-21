// Note: The file can be named anything, since Terraform loads all files in the directory ending in .tf.

variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "password" {
  default = "NO-VALUE-PROVIDED"
}

variable "vpc_security_group_ids" {
  default = []
}

variable "subnet_id" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "amis" {
  type = map
}

variable "tags" {
  type = map
}




