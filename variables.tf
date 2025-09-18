variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "site_bucket_name" {
  description = "S3 bucket name for the website (must be globally unique)"
  type = string 
  default = "project-bismark2505"
}

variable "audio_bucket_name" {
  description = "S3 bucket name for generated audio (must be globally unique)"
  type = string 
  default = "bismark250564"
}

variable "lambda_zip_path" {
 description = "Path to the Lambda deployment zip file"
 default     = "/infrastructure/lambda_package.zip"
 }
