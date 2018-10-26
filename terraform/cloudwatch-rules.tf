resource "aws_cloudwatch_event_rule" "pis-ssm-daily" {
  name                = "pis-ssm-daily"
  description         = "Run the pis-ssm-daily playbook on all pis"
  schedule_expression = "rate(1 days)"
}

resource "aws_cloudwatch_event_target" "pis-ssm-daily" {
  arn      = "arn:aws:ssm:eu-west-1::document/AWS-RunAnsiblePlaybook"
  input    = "${file("files/pis-ssm-daily-input.json")}"
  rule     = "${aws_cloudwatch_event_rule.pis-ssm-daily.name}"
  role_arn = "${aws_iam_role.events-service-role.arn}"

  run_command_targets {
    key    = "tag:gs:role"
    values = ["pi"]
  }
}
