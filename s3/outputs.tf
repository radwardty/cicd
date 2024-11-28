output "s3_endpoint" {
    value = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
  
}