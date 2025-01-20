resource "aws_autoscaling_group" "docker_swarm_leader_asg" {
   launch_template {
    id      = aws_launch_template.docker_swarm_manager.id
    version = "$Latest"
  }
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.private[0].id]

  tag {
    key                 = "Name"
    value               = "docker-swarm-manager"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "leader"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "docker_swarm_manager_asg" {
   launch_template {
    id      = aws_launch_template.docker_swarm_manager.id
    version = "$Latest"
  }
  min_size             = 0
  max_size             = 2
  desired_capacity     = 0
  vpc_zone_identifier  = slice([for subnet in aws_subnet.private: subnet.id], 1, var.number_of_azs - 1)

  tag {
    key                 = "Name"
    value               = "docker-swarm-manager"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "docker_swarm_worker_asg" {
   launch_template {
    id      = aws_launch_template.docker_swarm_worker.id
    version = "$Latest"
  }
  min_size             = 2
  max_size             = 6
  desired_capacity     = 3
  vpc_zone_identifier  = slice([for subnet in aws_subnet.private: subnet.id], 1, var.number_of_azs - 1)

  tag {
    key                 = "Name"
    value               = "docker-swarm-worker"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_manager_asg.name
  
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_manager_asg.name
}

resource "aws_autoscaling_policy" "worker_scale_up" {
  name                   = "worker-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_worker_asg.name
}

resource "aws_autoscaling_policy" "worker_scale_down" {
  name                   = "worker-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_worker_asg.name
}
