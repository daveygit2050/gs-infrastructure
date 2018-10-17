resource "aws_iam_role" "ssm-service-role" {
  name               = "ssm-service-role"
  assume_role_policy = "${file("files/ssm-role-trust-policy.json")}"
}

resource "aws_iam_policy_attachment" "ssm-service-policy" {
  name       = "ssm-service-policy"
  roles      = ["${aws_iam_role.ssm-service-role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
