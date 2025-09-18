output "website_url" {
  value = aws_s3_bucket.site.website_endpoint
}

output "audio_bucket" {
  value = aws_s3_bucket.audio.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
