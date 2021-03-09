resource "aws_subnet" "pub_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.1.0.0/24"
}

resource "aws_subnet" "db_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.5.0.0/24"
}