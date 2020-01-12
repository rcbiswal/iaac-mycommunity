## Terraform project. This project uses remote state to store the details of resources terraform has
## created. All state should be stored in a remote backend (s3) to allow collaboration across users
## More details on Terraform state can be found here: https://www.terraform.io/docs/state/index.html
## More details on Terraform remote state here: https://www.terraform.io/docs/state/remote.html

## IMPORTANT: The remote state configuration in this template requires Terraform v0.11.1.

terraform {
  required_version = "= 0.11.1"
}

# Application Loadbalancer items
resource "aws_alb" "alb" {
  name            = "rcb-alb"
  internal		  = false
  load_balancer_type = "application"
  security_groups = ["${var.elb-webaccess-port80}"]
  subnets         = ["${data.aws_subnet_ids.subnets.ids}"]
  tags {
    Name = "rcb-alb"
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tg-group.arn}"
    type             = "forward"
  }
}
#