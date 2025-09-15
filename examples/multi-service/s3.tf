module "s3_bucket_1" {
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
    filename = "index.js"
  }
}

resource "aws_s3_object" "order_api" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "order-api.zip"
  source = data.archive_file.order_api_zip.output_path
  etag   = data.archive_file.order_api_zip.output_md5
}

# User Service Archive
data "archive_file" "user_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/user-service.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('User Service Event:', JSON.stringify(event, null, 2));

    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            message: 'User Service - Managing user data',
            service: 'user-service',
            timestamp: new Date().toISOString(),
            event: event
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

resource "aws_s3_object" "user_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "user-service.zip"
  source = data.archive_file.user_service_zip.output_path
  etag   = data.archive_file.user_service_zip.output_md5
}

data "archive_file" "products_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/products-service.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Products Service V1 Event:', JSON.stringify(event, null, 2));

    // Simple V1 API - basic product listing
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'X-API-Version': '1.0',
            'X-Source': 'lambda-v1'
        },
        body: JSON.stringify({
            api_version: '1.0',
            service: 'products-v1',
            message: 'Basic Product Catalog Service V1',
            products: [
                { id: 1, name: 'Laptop', price: 999.99, category: 'Electronics' },
                { id: 2, name: 'Book', price: 19.99, category: 'Education' },
                { id: 3, name: 'Headphones', price: 149.99, category: 'Electronics' }
            ],
            timestamp: new Date().toISOString(),
            version_info: {
                lambda_version: '1.0',
                deployment_date: '2024-01-01',
                features: ['Basic Product Listing']
            }
        })
    };

    return response;
};
  EOF
    filename = "index.js"
  }
}

resource "aws_s3_object" "products_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "products-service.zip"
  source = data.archive_file.products_service_zip.output_path
  etag   = data.archive_file.products_service_zip.output_md5
}

data "archive_file" "orders_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/orders-service.zip"

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

resource "aws_s3_object" "orders_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "orders-service.zip"
  source = data.archive_file.orders_service_zip.output_path
  etag   = data.archive_file.orders_service_zip.output_md5
}

data "archive_file" "payments_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/payments-service.zip"

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

resource "aws_s3_object" "payments_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "payments-service.zip"
  source = data.archive_file.payments_service_zip.output_path
  etag   = data.archive_file.payments_service_zip.output_md5
}

data "archive_file" "inventory_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/inventory-service.zip"

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

resource "aws_s3_object" "inventory_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "inventory-service.zip"
  source = data.archive_file.inventory_service_zip.output_path
  etag   = data.archive_file.inventory_service_zip.output_md5
}

data "archive_file" "analytics_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/analytics-service.zip"

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

resource "aws_s3_object" "analytics_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "analytics-service.zip"
  source = data.archive_file.analytics_service_zip.output_path
  etag   = data.archive_file.analytics_service_zip.output_md5
}

data "archive_file" "notfound_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/notfound-service.zip"

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
                '/analytics',
                '/notifications',
                '/health'
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

resource "aws_s3_object" "notfound_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "notfound-service.zip"
  source = data.archive_file.notfound_service_zip.output_path
  etag   = data.archive_file.notfound_service_zip.output_md5
}

data "archive_file" "productsv2_service_zip" {
  type        = "zip"
  output_path = "${path.module}/external/productsv2-service.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Products Service V2 Event:', JSON.stringify(event, null, 2));

    // Enhanced V2 API with more features
    const requestId = event.requestContext?.requestId || 'unknown';
    const userAgent = event.headers?.['user-agent'] || 'unknown';
    const sourceIp = event.requestContext?.http?.sourceIp || 'unknown';

    // V2 Enhanced product catalog with more details
    const products = [
        {
            id: 1,
            name: 'MacBook Pro M3',
            price: 1999.99,
            category: 'Electronics',
            brand: 'Apple',
            inStock: true,
            rating: 4.8,
            features: ['M3 Chip', '16GB RAM', '512GB SSD'],
            description: 'Latest MacBook Pro with M3 chip for professional use'
        },
        {
            id: 2,
            name: 'JavaScript: The Definitive Guide',
            price: 49.99,
            category: 'Education',
            brand: 'O\'Reilly',
            inStock: true,
            rating: 4.9,
            features: ['Hardcover', '1200+ Pages', 'Latest Edition'],
            description: 'Comprehensive guide to JavaScript programming'
        },
        {
            id: 3,
            name: 'Sony WH-1000XM5',
            price: 399.99,
            category: 'Electronics',
            brand: 'Sony',
            inStock: false,
            rating: 4.7,
            features: ['Noise Cancelling', '30hr Battery', 'Hi-Res Audio'],
            description: 'Premium noise-cancelling wireless headphones'
        },
        {
            id: 4,
            name: 'Standing Desk Pro',
            price: 299.99,
            category: 'Furniture',
            brand: 'FlexiSpot',
            inStock: true,
            rating: 4.6,
            features: ['Electric Height Adjustment', 'Memory Presets', 'Cable Management'],
            description: 'Ergonomic electric standing desk for home office'
        }
    ];

    // V2 API Response with enhanced metadata
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'X-API-Version': '2.0',
            'X-Request-ID': requestId,
            'X-Source': 'lambda-v2'
        },
        body: JSON.stringify({
            api_version: '2.0',
            service: 'products-v2',
            message: 'Enhanced Product Catalog Service V2',
            metadata: {
                total_products: products.length,
                in_stock_count: products.filter(p => p.inStock).length,
                categories: [...new Set(products.map(p => p.category))],
                request_id: requestId,
                source_ip: sourceIp,
                user_agent: userAgent,
                execution_time: Date.now()
            },
            products: products,
            pagination: {
                page: 1,
                per_page: products.length,
                total_pages: 1
            },
            timestamp: new Date().toISOString(),
            version_info: {
                lambda_version: '2.0',
                deployment_date: '2024-01-15',
                features: ['Enhanced Product Details', 'Inventory Status', 'Ratings', 'Advanced Filtering']
            }
        })
    };

    return response;
};
  EOF
    filename = "index.js"
  }
}

resource "aws_s3_object" "productsv2_service" {
  bucket = module.s3_bucket_1.bucket_id
  key    = "productsv2-service.zip"
  source = data.archive_file.productsv2_service_zip.output_path
  etag   = data.archive_file.productsv2_service_zip.output_md5
}
