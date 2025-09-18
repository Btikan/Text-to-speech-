# Lambda function (expects local zip at path given in variable)
resource "aws_lambda_function" "tts" {
  filename         = var.lambda_zip_path
  function_name    = "tts-synth-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda_package.zip")

  environment {
    variables = {
      AUDIO_BUCKET = aws_s3_bucket.audio.id
      REGION       = var.region
    }
  }
}
