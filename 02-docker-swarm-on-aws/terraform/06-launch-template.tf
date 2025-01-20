resource "aws_launch_template" "docker_swarm_manager" {
  name          = "docker-swarm-managers"
  image_id      = var.defaut_ami

  instance_type = "t2.micro"
  key_name      = "aws_2020" # Replace with your key name

  vpc_security_group_ids = [
    aws_security_group.http.id,
    aws_security_group.docker_swarm.id,
    aws_security_group.manager_ssh.id,
    aws_security_group.efs.id,
  ]



  user_data = base64encode(<<-EOF
              #!/bin/bash
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              FIRST_MANAGER_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=docker-swarm-manager" --query "Reservations[*].Instances[0].InstanceId" --output text)
              if [ "$INSTANCE_ID" == "$FIRST_MANAGER_ID" ]; then
                docker swarm init --advertise-addr $(curl http://169.254.169.254/latest/meta-data/local-ipv4)
                MANAGER_JOIN_TOKEN=$(docker swarm join-token manager -q)
                WORKER_JOIN_TOKEN=$(docker swarm join-token worker -q)
                aws ssm put-parameter --name "MANAGER_JOIN_TOKEN" --value "$MANAGER_JOIN_TOKEN" --type "String" --overwrite
                aws ssm put-parameter --name "WORKER_JOIN_TOKEN" --value "$WORKER_JOIN_TOKEN" --type "String" --overwrite
              else
                MANAGER_JOIN_TOKEN=$(aws ssm get-parameter --name "MANAGER_JOIN_TOKEN" --query "Parameter.Value" --output text)
                docker swarm join --token $MANAGER_JOIN_TOKEN $(curl http://169.254.169.254/latest/meta-data/local-ipv4):2377
              fi

              # Mount EFS
              yum update -y
              yum install -y amazon-efs-utils
              mkdir -p /mnt/efs
              mount -t efs ${aws_efs_file_system.efs.id}:/ /mnt/efs
              EOF
  )
}

resource "aws_launch_template" "docker_swarm_worker" {
  name          = "docker-swarm-workers"
 image_id      = var.defaut_ami # ami-0c55b159cbfafe1f0" # Example AMI ID, replace with a valid one
  instance_type = "t2.micro"
  key_name      = "aws_2020" # Replace with your key name

  vpc_security_group_ids = [
    aws_security_group.http.id,
    aws_security_group.docker_swarm.id,
    aws_security_group.efs.id,
  ]



  user_data = base64encode(<<-EOF
              #!/bin/bash
              WORKER_JOIN_TOKEN=$(aws ssm get-parameter --name "WORKER_JOIN_TOKEN" --query "Parameter.Value" --output text)
              docker swarm join --token $WORKER_JOIN_TOKEN $(curl http://169.254.169.254/latest/meta-data/local-ipv4):2377
              EOF
  )
}