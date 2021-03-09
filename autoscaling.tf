data "aws_availability_zones" "all" {}

## Creating Launch Configuration
resource "aws_launch_configuration" "ec2_launch_config" {
    image_id               = "ami-0baa9603114401cc4"
    instance_type          = "t2.micro"
    security_groups        = [aws_security_group.ec2_sg.id]
    key_name               = "${var.key_name}"
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    lifecycle {
      create_before_destroy = true
    }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "ec2_asg" {
    launch_configuration = "${aws_launch_configuration.ec2_launch_config.id}"
	availability_zones = "${data.aws_availability_zones.all.names}"
	desired_capacity = 2
    min_size = 1
    max_size = 2
    load_balancers = [aws_elb.elb_ec2.id]
    health_check_type = "ELB"
    tag {
      key = "Name"
      value = "terraform-ec2-asg"
      propagate_at_launch = true
	}
}


### Creating ELB
resource "aws_elb" "elb_ec2" {
    name = "terraform-ec2-asg"
    security_groups = [aws_security_group.elb_sg.id]
	subnets = ["${aws_subnet.pub_subnet.id}"]
	##availability_zones = "${data.aws_availability_zones.all.names}"
    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      interval = 30
      target = "HTTP:8080/"
    }
    listener {
      lb_port = 80
      lb_protocol = "http"
      instance_port = "8080"
      instance_protocol = "http"
    }
}