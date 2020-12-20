data "archive_file" "lambdazip" {
  type        = "zip"
  output_path = "lambda_function.zip"

  source_dir = "../lambda/"
}

resource "aws_lambda_function" "parse_csv" {
  filename      = "lambda_function.zip"
  function_name = "parse_csv"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("lambda_function.zip")

  layers = [
    "arn:aws:lambda:us-east-1:156515539745:layer:SQLAlchemy:1",
    "arn:aws:lambda:us-east-1:156515539745:layer:pandas_with_pyarrow:1"
  ]

  runtime = "python3.8"

  timeout = 900

  environment {
    variables = {
      max_pop_size = 
      min_pop_size = 
      db_host      = 
      db_port      = 
      db_username  = 
      db_password  = 
      db_name      = 
      bucket       = 
      key          = 
    }
  }

}
