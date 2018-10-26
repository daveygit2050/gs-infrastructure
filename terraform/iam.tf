resource "aws_iam_role" "events-service-role" {
  name               = "gs-infra-events"
  assume_role_policy = "${file("files/events-role-trust-policy.json")}"
}

resource "aws_iam_role_policy" "events-service-policy" {
  name   = "gs-infra-events"
  role   = "${aws_iam_role.events-service-role.name}"
  policy = "${file("files/events-role-access-policy.json")}"
}
