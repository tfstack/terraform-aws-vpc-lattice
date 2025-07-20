############################################
# Lambda Function
############################################

# Lambda function code for Products Service
data "archive_file" "products_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/products_lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Products Service Event:', JSON.stringify(event, null, 2));

    // Simple solution: always return products data since VPC Lattice routes to us
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            service: 'products',
            message: 'Product catalog service',
            products: [
                { id: 1, name: 'Laptop', price: 999.99, category: 'Electronics' },
                { id: 2, name: 'Book', price: 19.99, category: 'Education' },
                { id: 3, name: 'Headphones', price: 149.99, category: 'Electronics' }
            ],
            timestamp: new Date().toISOString()
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# Lambda function code for Orders Service
data "archive_file" "orders_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/orders_lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Orders Service Event:', JSON.stringify(event, null, 2));

    // Simple solution: always return orders data since VPC Lattice routes to us
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            service: 'orders',
            message: 'Order management service',
            orders: [
                { id: 'ORD-001', customerId: 'CUST-123', total: 1199.98, status: 'processing' },
                { id: 'ORD-002', customerId: 'CUST-456', total: 169.98, status: 'shipped' },
                { id: 'ORD-003', customerId: 'CUST-789', total: 299.97, status: 'delivered' }
            ],
            timestamp: new Date().toISOString()
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# Lambda function code for Payments Service
data "archive_file" "payments_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/payments_lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Payments Service Event:', JSON.stringify(event, null, 2));

    // Simple solution: always return payments data since VPC Lattice routes to us
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            service: 'payments',
            message: 'Payment processing service',
            payments: [
                { id: 'PAY-001', orderId: 'ORD-001', amount: 1199.98, status: 'completed', method: 'credit_card' },
                { id: 'PAY-002', orderId: 'ORD-002', amount: 169.98, status: 'pending', method: 'paypal' },
                { id: 'PAY-003', orderId: 'ORD-003', amount: 299.97, status: 'failed', method: 'credit_card' }
            ],
            timestamp: new Date().toISOString()
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# Lambda function code for Inventory Service
data "archive_file" "inventory_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/inventory_lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Inventory Service Event:', JSON.stringify(event, null, 2));

    // Simple solution: always return inventory data since VPC Lattice routes to us
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            service: 'inventory',
            message: 'Inventory management service',
            inventory: [
                { productId: 1, name: 'Laptop', quantity: 25, reserved: 5, available: 20 },
                { productId: 2, name: 'Book', quantity: 100, reserved: 10, available: 90 },
                { productId: 3, name: 'Headphones', quantity: 50, reserved: 8, available: 42 }
            ],
            timestamp: new Date().toISOString()
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# Lambda function code for Analytics Service
data "archive_file" "analytics_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/analytics_lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Analytics Service Event:', JSON.stringify(event, null, 2));

    // Simple solution: always return analytics data since VPC Lattice routes to us
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            service: 'analytics',
            message: 'Business intelligence service',
            metrics: {
                totalOrders: 1250,
                totalRevenue: 125000.50,
                averageOrderValue: 100.00,
                topProducts: [
                    { productId: 1, name: 'Laptop', sales: 150, revenue: 149998.50 },
                    { productId: 3, name: 'Headphones', sales: 200, revenue: 29998.00 },
                    { productId: 2, name: 'Book', sales: 500, revenue: 9995.00 }
                ],
                conversionRate: 3.2,
                customerSatisfaction: 4.7
            },
            timestamp: new Date().toISOString()
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# Lambda function code for 404 Not Found Service
data "archive_file" "notfound_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/notfound_lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Not Found Service Event:', JSON.stringify(event, null, 2));

    const path = event.requestContext?.http?.path || event.path || event.rawPath || '/';

    const response = {
        statusCode: 404,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            error: 'Not Found',
            message: 'The requested endpoint does not exist',
            path: path,
            availableEndpoints: [
                '/products',
                '/orders',
                '/payments',
                '/inventory',
                '/analytics'
            ],
            timestamp: new Date().toISOString()
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution" {
  name = "${local.name_1}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags_2
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



# Lambda function for Products Service
resource "aws_lambda_function" "products_handler" {
  filename      = data.archive_file.products_lambda_zip.output_path
  function_name = "${local.name_1}-products"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "products-service"
      SERVICE_TYPE = "catalog"
    }
  }

  tags = merge(local.tags_2, {
    Service = "products"
    Domain  = "catalog"
  })
}

# Lambda function for Orders Service
resource "aws_lambda_function" "orders_handler" {
  filename      = data.archive_file.orders_lambda_zip.output_path
  function_name = "${local.name_1}-orders"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "orders-service"
      SERVICE_TYPE = "business"
    }
  }

  tags = merge(local.tags_2, {
    Service = "orders"
    Domain  = "business"
  })
}

# Lambda function for Payments Service
resource "aws_lambda_function" "payments_handler" {
  filename      = data.archive_file.payments_lambda_zip.output_path
  function_name = "${local.name_1}-payments"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "payments-service"
      SERVICE_TYPE = "financial"
    }
  }

  tags = merge(local.tags_2, {
    Service = "payments"
    Domain  = "financial"
  })
}

# Lambda function for Inventory Service
resource "aws_lambda_function" "inventory_handler" {
  filename      = data.archive_file.inventory_lambda_zip.output_path
  function_name = "${local.name_1}-inventory"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "inventory-service"
      SERVICE_TYPE = "business"
    }
  }

  tags = merge(local.tags_2, {
    Service = "inventory"
    Domain  = "business"
  })
}

# Lambda function for Analytics Service
resource "aws_lambda_function" "analytics_handler" {
  filename      = data.archive_file.analytics_lambda_zip.output_path
  function_name = "${local.name_1}-analytics"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "analytics-service"
      SERVICE_TYPE = "reporting"
    }
  }

  tags = merge(local.tags_2, {
    Service = "analytics"
    Domain  = "reporting"
  })
}

# Lambda function for Not Found Service
resource "aws_lambda_function" "notfound_handler" {
  filename      = data.archive_file.notfound_lambda_zip.output_path
  function_name = "${local.name_1}-notfound"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "notfound-service"
      SERVICE_TYPE = "error"
    }
  }

  tags = merge(local.tags_2, {
    Service = "notfound"
    Domain  = "error"
  })
}
