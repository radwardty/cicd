# aws s3 rm s3://saju-front-prod --recursive
# terraform destroy 를 하기전에 S3 버킷 내용이 삭제되어야 한다.
# s3 버킷 생성시 AWS를 이용하는 모든 사용자들의 s3 버킷 이름과 중복해서 사용할 수 없습니다.

# S3 버킷
resource "aws_s3_bucket" "s3-bucket" {
  bucket = var.bucket

  tags = {
    Name    = "saju-front-${var.service_type}-00"
    Service = "saju-${var.service_type}"
  }
}

# 정적 웹 호스팅 설정 (website {})
resource "aws_s3_bucket_website_configuration" "s3-website-config" {
  bucket = aws_s3_bucket.s3-bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

# ACL 설정 관련 리소스 생성
resource "aws_s3_bucket_acl" "acl" {
  bucket     = aws_s3_bucket.s3-bucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.oc]
}
resource "aws_s3_bucket_ownership_controls" "oc" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 모든 퍼블릭 액세스 차단 해제
resource "aws_s3_bucket_public_access_block" "ab" {
  bucket                  = aws_s3_bucket.s3-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 정책 편집기에 쓴 내용
data "aws_iam_policy_document" "allow-get-object" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3-bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# 정책 편집기 내용과 버킷을 매핑
resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket     = aws_s3_bucket.s3-bucket.id
  policy     = data.aws_iam_policy_document.allow-get-object.json
  depends_on = [aws_s3_bucket_public_access_block.ab]
}

# S3 정적 웹 호스팅 엔드포인트
# output "s3_endpoing" {
#    value = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
# }
