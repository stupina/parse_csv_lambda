resource "aws_cloudwatch_event_rule" "every_working_day" {
  name                = "every_working_day"
  description         = "6:00 PM Monday through Friday (UTC+3)"
  schedule_expression = "cron(0 15 ? * MON-FRI *)"
}

resource "aws_lambda_permission" "allow-cloudwatch-to-call-parse-csv" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.parse_csv.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_working_day.arn
}

resource "aws_cloudwatch_event_target" "launch_parse_csv_every_working_day" {
  rule      = aws_cloudwatch_event_rule.every_working_day.name
  target_id = aws_lambda_function.parse_csv.function_name
  arn       = aws_lambda_function.parse_csv.arn
}
