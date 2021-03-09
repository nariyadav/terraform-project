output "mysql_endpoint" {
    value = aws_db_instance.mysql.endpoint
}

output "elb_dns_name" {
  value = "${aws_elb.elb_ec2.dns_name}"
}
