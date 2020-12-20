resource "aws_lambda_permission" "parse-csv-s3-trigger-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.parse_csv.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::parse-csv-lambda-bucket"
}

resource "aws_s3_bucket_notification" "parse-csv-trigger" {
  bucket = "parse-csv-lambda-bucket"

  lambda_function {
    lambda_function_arn = aws_lambda_function.parse_csv.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }
}
