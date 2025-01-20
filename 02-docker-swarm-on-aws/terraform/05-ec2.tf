


resource "aws_instance" "bastion" {
  ami           = var.defaut_ami # ami-0c55b159cbfafe1f0" # Example AMI ID, replace with a valid one
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name      = "aws_2020" # Replace with your key name

  security_groups = [
    aws_security_group.ssh.id,
    aws_autoscaling_group.docker_swarm_manager_asg.id,
  ]

  tags = {
    Name = "bastion"
  }
}

# create ec2 IAM instance role to access aws ssm
