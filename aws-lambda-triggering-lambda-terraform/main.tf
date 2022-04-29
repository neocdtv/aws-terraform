provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 1.1.0"
}

data "archive_file" "callee_zip" {
    type          = "zip"
    source_dir = "lambda/callee"
    output_path   = "callee_lambda.zip"
}

resource "aws_lambda_function" "callee_lambda" {
  filename         = "callee_lambda.zip"
  function_name    = "callee_lambda"
  role             = "${aws_iam_role.callee_and_caller_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.callee_zip.output_base64sha256}"
  runtime          = "nodejs14.x"
}

data "archive_file" "caller_zip" {
    type          = "zip"
    source_dir = "lambda/caller"
    output_path   = "caller_lambda.zip"
}

resource "aws_lambda_function" "caller_lambda" {
  filename         = "caller_lambda.zip"
  function_name    = "caller_lambda"
  role             = "${aws_iam_role.callee_and_caller_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.caller_zip.output_base64sha256}"
  runtime          = "nodejs14.x"
}

resource "aws_iam_role" "callee_and_caller_role" {
  name = "callee_and_caller_role"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", 
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole", 
    "arn:aws:iam::aws:policy/AWSLambdaExecute"]
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_at_utc" {
  name                = "run_at_utc"
  //schedule_expression = "cron(0 4 * * ? *)"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "trigger_at_utc" {
  rule      = aws_cloudwatch_event_rule.run_at_utc.name
  target_id = "lambda"
  arn       = aws_lambda_function.caller_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.caller_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.run_at_utc.arn
}

output "caller_lambda_arn" {
  value = aws_lambda_function.caller_lambda.arn
}

output "callee_lambda_arn" {
  value = aws_lambda_function.callee_lambda.arn
}