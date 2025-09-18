# S3 bucket for hosting the static website
resource "aws_s3_bucket" "site" {
  bucket = "project-bismark2505"
  # No 'acl' line here.
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Make objects readable (simple tutorial policy). Use CloudFront + OAI for production.
data "aws_iam_policy_document" "site_public" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    principals { 
        type = "AWS" 
        identifiers = ["*"] 
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "site_public" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_public.json
}

# S3 bucket for generated audio
resource "aws_s3_bucket" "audio" {
  bucket = var.audio_bucket_name

  # Remove the 'acl' and 'object_ownership' lines from here.
  # acl = "private" 
  # object_ownership = "BucketOwnerEnforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-old-audio"
    enabled = true
    expiration {
      days = 7
    }
  }

  tags = {
    Name = "tts-audio-bucket"
  }
}

# This is the dedicated resource to manage S3 bucket ownership controls.
resource "aws_s3_bucket_ownership_controls" "audio" {
  bucket = aws_s3_bucket.audio.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
