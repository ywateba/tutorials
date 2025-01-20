resource "aws_lb" "swarm_lb" {
  name               = "docker-swarm-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id] # all public subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "swarm_tg" {
  name     = "swarm-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id



  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "swarm_listener" {
  load_balancer_arn = aws_lb.swarm_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.swarm_tg.arn
  }
}

# resource "aws_lb_target_group_attachment" "swarm_tg_attachment" {
#   count            = length(aws_instance.worker.*.id) + length(aws_instance.manager.*.id)
#   target_group_arn = aws_lb_target_group.swarm_tg.arn
#   target_id        = element(concat(aws_instance.worker.*.id, aws_instance.manager.*.id), count.index)
#   port             = 80
# }

resource "aws_autoscaling_attachment" "workers_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_worker_asg.name
  lb_target_group_arn    = aws_lb_target_group.swarm_tg.arn
}

resource "aws_autoscaling_attachment" "managers_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_manager_asg.name
  lb_target_group_arn    = aws_lb_target_group.swarm_tg.arn
}

resource "aws_autoscaling_attachment" "leader_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.docker_swarm_leader_asg.name
  lb_target_group_arn    = aws_lb_target_group.swarm_tg.arn
}