provider "aws" {
  region = "us-east-1"
}

module "cloudfront_s3_website_with_domain" {
  source                 = "../modules/terraform-aws-cloudfront-s3-website"
  tags                   = var.tags
  domain_name            = "devops630.example.com"
  cloudfront_min_ttl     = 10
  cloudfront_default_ttl = 1400
  cloudfront_max_ttl     = 86400
}


variable "tags" {
  default = {
    owner       = "BroadwayDevops630"
    application = "example-mern-fe"
  }
}


output "cloudfront_domain_name" {
  value = "https://${module.cloudfront_s3_website_with_domain.cloudfront_domain_name}"
}
