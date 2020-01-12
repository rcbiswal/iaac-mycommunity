## Terraform project. This project uses remote state to store the details of resources terraform has
## created. All state should be stored in a remote backend (s3) to allow collaboration across users
## More details on Terraform state can be found here: https://www.terraform.io/docs/state/index.html
## More details on Terraform remote state here: https://www.terraform.io/docs/state/remote.html

## IMPORTANT: The remote state configuration in this template requires Terraform v0.11.1.

terraform {
  required_version = "= 0.11.1"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.vpcid}"
}

# Auto Scaling Group
#data "aws_ami" "rcb-ami" {
#  most_recent = true

#  filter {
#    name   = "name"
#    values = ["rcb-server-image"]
# }

#  filter {
#    name   = "virtualization-type"
#   values = ["hvm"]
#  }

#  owners = ["219228595842"]
#}

resource "aws_launch_configuration" "rcb-lc" {
  name          = "rcb-launch-conf"
  image_id      = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  iam_instance_profile = "SSM-ROLE"
  key_name = "${var.ec2-key}"
  security_groups = ["${var.webaccess-sg}"]
  associate_public_ip_address = true
  user_data ="${file("install_apache.sh")}"
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "rcb-asg" {
  name                 = "rcb-as-group"
  availability_zones   = ["us-east-1a","us-east-1b","us-east-1c"]
  launch_configuration = "${aws_launch_configuration.rcb-lc.name}"
  min_size             = 2
  max_size             = 3
  vpc_zone_identifier  = ["${data.aws_subnet_ids.subnets.ids}"]
  target_group_arns    = ["${aws_alb_target_group.tg-group.arn}"]
  #enable-metrics-collection = true
    enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
  lifecycle {
	create_before_destroy = true
	}
  tag {
    key                 = "Name"
    value               = "rcb-webserver"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg_policy" {
  name                      = "asg-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${aws_autoscaling_group.rcb-asg.name}"
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "60"
  }
}

data "aws_sns_topic" "sns_topic" {
  name = "RCB-AutoScaled"
}
resource "aws_autoscaling_notification" "asg_notify" {
  group_names    = ["${aws_autoscaling_group.rcb-asg.name}"]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = "${data.aws_sns_topic.sns_topic.arn}"
}
#