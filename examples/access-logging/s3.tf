module "s3_bucket" {
  source = "tfstack/s3/aws"

  bucket_name       = "lambda-zips"
  bucket_suffix     = local.suffix
  enable_versioning = true

  tags = {
    Environment = "dev"
    VPC         = "apps"
  }
}

data "archive_file" "api_zip" {
  type        = "zip"
  output_path = "${path.module}/external/api.zip"

  source {
    content  = <<EOF
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from VPC Lattice with Access Logging!'
    }
EOF
    filename = "index.py"
  }
}

resource "aws_s3_object" "api" {
  bucket = module.s3_bucket.bucket_id
  key    = "api.zip"
  source = data.archive_file.api_zip.output_path
  etag   = data.archive_file.api_zip.output_md5
}
