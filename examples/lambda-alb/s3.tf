module "s3_bucket" {
  source = "tfstack/s3/aws"

  bucket_name       = "lambda-zips"
  bucket_suffix     = local.suffix
  enable_versioning = true

  tags = {
    Environment = "dev"
    VPC         = "app-1"
  }
}

# Order API Archive
data "archive_file" "order_api_zip" {
  type        = "zip"
  output_path = "${path.module}/external/order-api.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Order API Event:', JSON.stringify(event, null, 2));

    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            message: 'Order API - Processing order request',
            service: 'order-api',
            timestamp: new Date().toISOString(),
            event: event
        })
    };

    return response;
};
EOF
    filename = "order-api.js"
  }
}

resource "aws_s3_object" "order_api" {
  bucket = module.s3_bucket.bucket_id
  key    = "order-api.zip"
  source = data.archive_file.order_api_zip.output_path
  etag   = data.archive_file.order_api_zip.output_md5
}
