region = "us-east-1"
amis = {
    "us-east-1" = "ami-fff22694"
    "us-east-2" = "not-implemented"
}
instance_type = "t2.micro"
subnet_id = "subnet-024f2caba73e83d2d"
vpc_security_group_ids = ["sg-058bc41dd415655b6"]

password="Production-Secret"
tags = {
    Name = "terraform-example-ec2-instance"
    Environment = "production"
  }
