############################################
# Providers
############################################

# AWS provider for app resources (S3, Route53, etc.) in us-east-2
provider "aws" {
  region = "us-east-2"
}

# AWS provider for ACM lookup in us-east-1 (CloudFront cert must be in us-east-1)
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

# Azure provider
provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

############################################
# Variables (ACM cert ARN you provided)
############################################

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1 for CloudFront"
  default     = "arn:aws:acm:us-east-1:286605288068:certificate/670598c4-aaf7-4560-b4c7-d5a4d1a87e42"
}

############################################
# AZURE: Static Website Storage + Uploads
############################################

resource "azurerm_resource_group" "rg" {
  name     = "rg-static-website"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccount345383"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = "website/index.html"
}

resource "azurerm_storage_blob" "styles_css" {
  name                   = "styles.css"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/css"
  source                 = "website/styles.css"
}

resource "azurerm_storage_blob" "scripts_js" {
  name                   = "script.js"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "application/javascript"
  source                 = "website/script.js"
}

resource "azurerm_storage_blob" "assets" {
  for_each = fileset("website/assets", "**/*")

  name                   = "assets/${each.value}"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"

  content_type = lookup(
    {
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
      "jpeg" = "image/jpeg"
      "gif"  = "image/gif"
      "svg"  = "image/svg+xml"
      "webp" = "image/webp"
      "ico"  = "image/x-icon"
      "js"   = "application/javascript"
      "css"  = "text/css"
      "html" = "text/html"
    },
    element(split(".", each.value), length(split(".", each.value)) - 1),
    "application/octet-stream"
  )

  source = "website/assets/${each.value}"
}

############################################
# AWS: S3 Bucket + Website Config + Uploads
############################################

# IMPORTANT: Remove deprecated website{} block from bucket resource.
resource "aws_s3_bucket" "weather_app" {
  bucket = "weather-tracker-app-bucket-345383"

  lifecycle {
    prevent_destroy = true
  }
}

# Website configuration (replaces deprecated bucket.website)
resource "aws_s3_bucket_website_configuration" "weather_site" {
  bucket = aws_s3_bucket.weather_app.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.weather_app.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "website_index" {
  bucket       = aws_s3_bucket.weather_app.id
  key          = "index.html"
  source       = "website/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "website_style" {
  bucket       = aws_s3_bucket.weather_app.id
  key          = "styles.css"
  source       = "website/styles.css"
  content_type = "text/css"
}

resource "aws_s3_object" "website_script" {
  bucket       = aws_s3_bucket.weather_app.id
  key          = "script.js"
  source       = "website/script.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "website_assets" {
  for_each = fileset("website/assets", "*")
  bucket   = aws_s3_bucket.weather_app.id
  key      = "assets/${each.value}"
  source   = "website/assets/${each.value}"
}

# Keep your current public-read bucket policy (works, but not most secure)
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.weather_app.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.weather_app.id}/*"
      }
    ]
  })
}

############################################
# Route53: ACM Validation (keep as-is)
############################################

resource "aws_route53_record" "acm_validation_root" {
  zone_id = "Z05740612NGWN4QZMS069"
  name    = "_a694449ead5f7e3f1b3e81fd36447c05.weather-tracker.space"
  type    = "CNAME"
  ttl     = 300
  records = ["_ab0da9a23609891fc9bc4c74433ad095.jkddzztszm.acm-validations.aws"]
}

resource "aws_route53_record" "acm_validation_www" {
  zone_id = "Z05740612NGWN4QZMS069"
  name    = "_3ad5058da8d0f5c50f22a7d3cebe36be.www.weather-tracker.space"
  type    = "CNAME"
  ttl     = 300
  records = ["_d59c60e2a14c7024695dba62b73f7361.jkddzztszm.acm-validations.aws"]
}

############################################
# CloudFront (HTTPS)
############################################

# CloudFront uses your S3 bucket as origin (regional domain, NOT website endpoint)
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = [
    "weather-tracker.space",
    "www.weather-tracker.space"
  ]

  origin {
    domain_name = aws_s3_bucket.weather_app.bucket_regional_domain_name
    origin_id   = "s3-weather-origin"
  }

  default_cache_behavior {
    target_origin_id       = "s3-weather-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

############################################
# Route53: Root + WWW => CloudFront (HTTPS works)
############################################

resource "aws_route53_record" "root" {
  zone_id = "Z05740612NGWN4QZMS069"
  name    = "weather-tracker.space"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "Z05740612NGWN4QZMS069"
  name    = "www.weather-tracker.space"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

############################################
# Route53 Health Checks (optional)
############################################

resource "aws_route53_health_check" "aws_health_check" {
  type              = "HTTP"
  fqdn              = "weather-tracker-app-bucket-345383.s3-website-us-east-2.amazonaws.com"
  port              = 80
  request_interval  = 30
  failure_threshold = 3
}

resource "aws_route53_health_check" "azure_health_check" {
  type              = "HTTPS"
  fqdn              = "mystorageaccount345383.z6.web.core.windows.net"
  port              = 443
  request_interval  = 30
  failure_threshold = 3
}
