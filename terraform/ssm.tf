resource "aws_ssm_association" "pis-daily-playbook" {
  name                = "AWS-RunAnsiblePlaybook"
  association_name    = "gs-pis-daily-playbook"
  schedule_expression = "rate(1 day)"

  output_location {
    s3_bucket_name = "${aws_s3_bucket.gs-infrastructure-output.id}"
  }

  parameters {
    playbook    = ""
    playbookurl = "https://raw.githubusercontent.com/daveygit2050/gs-infrastructure/master/ansible/pis-ssm-daily.yml"
    extravars   = "SSM=True"
    check       = "False"
  }

  targets {
    key    = "tag:gs:role"
    values = ["pi"]
  }
}
