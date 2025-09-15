############################################
# Jumphost
############################################

module "ec2_client" {
  source = "tfstack/jumphost/aws"

  name      = "${local.base_name_1}-ec2-client"
  subnet_id = module.vpc_1.private_subnet_ids[0]
  vpc_id    = module.vpc_1.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_client_sg.id]
  allowed_cidr_blocks    = ["${trimspace(data.http.my_public_ip.response_body)}/32"]
  assign_eip             = false

  user_data_extra = <<-EOT
    hostname ${local.base_name_1}-ec2-client
    yum install -y mtr nc jq
  EOT

  tags = local.tags_1
}

############################################
# Web Server
############################################

module "ec2_web_server" {
  source = "tfstack/ec2-server/aws"

  name = "${local.base_name_1}-web-server"

  vpc_id                 = module.vpc_1.vpc_id
  subnet_id              = module.vpc_1.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  instance_type    = "t3.small"
  assign_public_ip = true

  enable_ssm = true

  user_data = <<-EOT
  #!/bin/bash
  set -euo pipefail
  hostname ${local.base_name_1}-web-server

  # Update base OS
  if command -v dnf >/dev/null 2>&1; then
    dnf -y update
  else
    yum -y update
  fi

  # Install Apache + OpenSSL + tools
  if command -v dnf >/dev/null 2>&1; then
    dnf -y install httpd mod_ssl openssl curl jq
  else
    yum -y install httpd mod_ssl openssl curl jq
  fi

  # Remove any legacy PHP first (if present)
  if rpm -qa | grep -qi '^php'; then
    (dnf -y remove 'php*' || yum -y remove 'php*') || true
  fi

  # Install PHP 8.2
  if command -v amazon-linux-extras >/dev/null 2>&1; then
    # Amazon Linux 2
    amazon-linux-extras enable php8.2
    yum clean metadata -y
    yum -y install php php-cli php-common php-json
  else
    # Amazon Linux 2023 (dnf, PHP 8.2 available in AppStream)
    dnf -y install php php-cli php-common php-json
  fi

  # Create SSL directories
  mkdir -p /etc/ssl/private /etc/ssl/certs

  # Generate self-signed SSL certificate (demo)
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/apache-selfsigned.key \
      -out /etc/ssl/certs/apache-selfsigned.crt \
      -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

  # Configure Apache for HTTPS
  cat > /etc/httpd/conf.d/ssl.conf << 'SSL_EOF'
  Listen 443 https
  SSLRandomSeed startup builtin
  SSLRandomSeed connect builtin
  SSLCipherSuite ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384
  SSLProtocol all -SSLv3
  SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
  SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

  <VirtualHost _default_:443>
      DocumentRoot /var/www/html
      ServerName localhost
      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
  </VirtualHost>
  SSL_EOF

  systemctl enable httpd
  systemctl restart httpd

  mkdir -p /var/www/html

  # --- Favicon (SVG) ---
  cat > /var/www/html/favicon.svg << 'FAV_EOF'
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
    <rect width="64" height="64" rx="12" fill="#0073bb"/>
    <text x="50%" y="52%" dominant-baseline="middle" text-anchor="middle" font-size="40" fill="#ffffff">🔗</text>
  </svg>
  FAV_EOF

  # Create simple working web page (adds <link rel="icon">)
  cat > /var/www/html/index.html << 'HTML_EOF'
  <!DOCTYPE html>
  <html>
  <head>
      <meta charset="utf-8"/>
      <title>VPC Lattice Microservices Demo</title>
      <link rel="icon" type="image/svg+xml" href="favicon.svg">
      <link rel="shortcut icon" href="favicon.svg" type="image/svg+xml">
      <style>
          body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
          .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
          .buttons { margin: 20px 0; }
          .btn { padding: 10px 20px; margin: 5px; background: #007cba; color: white; border: none; border-radius: 4px; cursor: pointer; }
          .btn:hover { background: #005a87; }
          .result { margin: 20px 0; padding: 15px; background: #f9f9f9; border-radius: 4px; min-height: 200px; }
          table { width: 100%; border-collapse: collapse; margin-top: 10px; }
          th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
          th { background-color: #f2f2f2; }
          .error { color: red; }
          pre { background: #f0f0f0; padding: 10px; border: 1px solid #ccc; overflow-x: auto; white-space: pre-wrap; }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>🔗 VPC Lattice Microservices Demo</h1>
          <p>Test microservices through AWS VPC Lattice</p>

          <div class="buttons">
              <button class="btn" onclick="loadData('products')" style="background: #28a745;">Products (Weighted)</button>
              <button class="btn" onclick="loadData('orders')" style="background: #007cba;">Orders (Path-based)</button>
              <button class="btn" onclick="loadData('payments')" style="background: #007cba;">Payments (Path-based)</button>
              <button class="btn" onclick="loadData('inventory')" style="background: #007cba;">Inventory (Path-based)</button>
              <button class="btn" onclick="loadData('notifications')" style="background: #6f42c1;">Notifications (EC2)</button>
              <button class="btn" onclick="loadData('health')" style="background: #20c997; border: 2px solid #17a2b8; font-weight: bold;">🏥 Health (IP Target)</button>
              <button class="btn" onclick="loadData('analytics')" style="background: #ff6b35;">Analytics (Container)</button>
              <button class="btn" onclick="showDebug()" style="background: #dc3545;">Debug Info</button>
          </div>

          <div style="margin: 20px 0; padding: 15px; background: #e9ecef; border-radius: 4px;">
              <h4>VPC Lattice Demo Features:</h4>
              <ul>
                  <li><strong>Products (Green):</strong> Weighted routing - 50/50 split between v1 and v2 Lambda functions</li>
                  <li><strong>Other APIs (Blue):</strong> Path-based routing - direct routing to specific Lambda services</li>
                  <li><strong>Notifications (Purple):</strong> EC2 routing - nginx service running on EC2 instance</li>
                  <li><strong>Health (Teal):</strong> <span style="color: #20c997; font-weight: bold;">IP Target routing</span> - Direct IP address targeting with nginx on EC2</li>
                  <li><strong>Analytics (Orange):</strong> Container routing - ECS Fargate container with advanced analytics</li>
              </ul>
          </div>

          <div class="result" id="result">Click a button to load API data...</div>
      </div>

      <script>
          function loadData(endpoint) {
              document.getElementById('result').innerHTML = 'Loading ' + endpoint + '...';

              fetch('api.php?endpoint=' + endpoint)
                  .then(response => response.text())
                  .then(text => {
                      try {
                          let data = JSON.parse(text);
                          let html = '<h3>' + endpoint.toUpperCase() + ' API Response</h3>';
                          html += '<table><tr><th>Key</th><th>Value</th></tr>';
                          for (let key in data) {
                              html += '<tr><td>' + key + '</td><td>' + JSON.stringify(data[key]) + '</td></tr>';
                          }
                          html += '</table>';
                          document.getElementById('result').innerHTML = html;
                      } catch (e) {
                          document.getElementById('result').innerHTML = '<div class="error">JSON Parse Error: ' + e.message + '<br><br>Raw Response:<br><pre>' + text + '</pre></div>';
                      }
                  })
                  .catch(error => {
                      document.getElementById('result').innerHTML = '<div class="error">Fetch Error: ' + error.message + '</div>';
                  });
          }

          function showDebug() {
              document.getElementById('result').innerHTML = 'Loading debug info...';
              fetch('debug.php')
                  .then(response => response.text())
                  .then(text => {
                      document.getElementById('result').innerHTML = '<pre>' + text + '</pre>';
                  })
                  .catch(error => {
                      document.getElementById('result').innerHTML = '<div class="error">Debug Error: ' + error.message + '</div>';
                  });
          }
      </script>
  </body>
  </html>
  HTML_EOF

  # Create API proxy that routes to different VPC Lattice services
  cat > /var/www/html/api.php << 'API_EOF'
  <?php
  header('Content-Type: application/json');

  $endpoint = $_GET['endpoint'] ?? 'products';
  $endpoint = preg_replace('/[^a-z0-9_-]/i', '', $endpoint);

  // Route products to dedicated products service (weighted routing demo)
  if ($endpoint === 'products') {
      $url = 'http://products.example.local/';
      $service_type = 'Products Service (Weighted Routing)';
  } else {
      // Route other endpoints to main API service (path-based routing demo)
      $url = 'http://api.example.local/' . $endpoint;
      $service_type = 'API Service (Path-based Routing)';
  }

  $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL, $url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_TIMEOUT, 10);
  curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
  curl_setopt($ch, CURLOPT_HTTPHEADER, array('Accept: application/json'));

  $response  = curl_exec($ch);
  $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
  $err       = curl_error($ch);
  curl_close($ch);

  if ($response !== false && $http_code == 200 && strlen($response) > 0) {
      // Add service type info to response for demo purposes
      $data = json_decode($response, true);
      if ($data) {
          $data['_demo_info'] = array(
              'service_type' => $service_type,
              'target_url' => $url,
              'routing_method' => $endpoint === 'products' ? 'Weighted (50/50)' : 'Path-based'
          );
          echo json_encode($data, JSON_PRETTY_PRINT);
      } else {
          echo $response;
      }
  } else {
      echo json_encode(array(
          'error' => 'API call failed',
          'http_code' => $http_code,
          'curl_err' => $err,
          'target_url' => $url,
          'service_type' => $service_type
      ));
  }
  ?>
  API_EOF

  # Create debug file
  cat > /var/www/html/debug.php << 'DEBUG_EOF'
  <?php
  header('Content-Type: text/plain');

  echo "=== VPC Lattice Debug Info ===\n\n";

  // Test basic connectivity
  echo "1. Testing DNS resolution:\n";
  $api_ip = gethostbyname('api.example.local');
  $products_ip = gethostbyname('products.example.local');
  echo "   api.example.local resolves to: $api_ip\n";
  echo "   products.example.local resolves to: $products_ip\n\n";

  // Test products service (weighted routing)
  echo "2. Testing Products Service (Weighted Routing):\n";
  $products_url = 'http://products.example.local/';
  echo "   URL: $products_url\n";
  echo "   Expected: 50/50 split between v1 and v2\n\n";

  $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL, $products_url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_TIMEOUT, 10);
  curl_setopt($ch, CURLOPT_VERBOSE, true);
  $verbose = fopen('php://temp', 'w+');
  curl_setopt($ch, CURLOPT_STDERR, $verbose);

  $response = curl_exec($ch);
  $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
  $error = curl_error($ch);
  $info = curl_getinfo($ch);

  rewind($verbose);
  $verbose_log = stream_get_contents($verbose);
  fclose($verbose);
  curl_close($ch);

  echo "   HTTP Code: $http_code\n";
  echo "   CURL Error: " . ($error ?: 'None') . "\n";
  echo "   Response Length: " . strlen($response) . "\n";
  echo "   Response: " . substr($response, 0, 500) . "\n\n";

  // Test API service (path-based routing)
  echo "3. Testing API Service (Path-based Routing):\n";
  $api_url = 'http://api.example.local/orders';
  echo "   URL: $api_url\n";
  echo "   Expected: Direct routing to orders service\n\n";

  $ch2 = curl_init();
  curl_setopt($ch2, CURLOPT_URL, $api_url);
  curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch2, CURLOPT_TIMEOUT, 10);

  $response2 = curl_exec($ch2);
  $http_code2 = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
  $error2 = curl_error($ch2);
  curl_close($ch2);

  echo "   HTTP Code: $http_code2\n";
  echo "   CURL Error: " . ($error2 ?: 'None') . "\n";
  echo "   Response Length: " . strlen($response2) . "\n";
  echo "   Response: " . substr($response2, 0, 500) . "\n\n";

  echo "4. CURL Verbose Log (Products):\n";
  echo $verbose_log . "\n\n";

  echo "5. Server Info:\n";
  echo "   PHP Version: " . phpversion() . "\n";
  echo "   Server: " . $_SERVER['SERVER_SOFTWARE'] . "\n";
  echo "   Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "\n";

  // List files
  echo "\n5. Files in /var/www/html:\n";
  $files = scandir('/var/www/html');
  foreach($files as $file) {
      if ($file !== '.' && $file !== '..') {
          echo "   $file\n";
      }
  }
  ?>
  DEBUG_EOF

  sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
  chown -R apache:apache /var/www/html
  chmod -R 755 /var/www/html
  chmod 644 /var/www/html/.htaccess || true
  systemctl restart httpd
EOT

  # Resource tagging
  instance_tags = local.tags_1
}

############################################
# Notification Service
############################################

module "ec2_notifications_service" {
  source = "tfstack/ec2-server/aws"

  name      = "${local.base_name_3}-notifications-service"
  subnet_id = module.vpc_3.private_subnet_ids[1]
  vpc_id    = module.vpc_3.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.notifications_service_sg.id]

  instance_type    = "t3.micro"
  assign_public_ip = false
  enable_ssm       = true

  user_data = <<-EOT
#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting notifications service setup..."

# Update system
if command -v dnf >/dev/null 2>&1; then
  dnf -y update
else
  yum -y update
fi

# Install nginx using amazon-linux-extras
amazon-linux-extras install nginx1 -y

# Configure nginx
cat > /etc/nginx/conf.d/default.conf << 'NGINX'
server {
    listen 80;
    location / {
        add_header Content-Type application/json;
        return 200 '{"api_version":"1.0","service":"notifications-service","message":"Notifications Service (EC2)","notifications":[{"id":"N001","type":"email","status":"sent","recipient":"john@example.com","subject":"Order Confirmation"},{"id":"N002","type":"sms","status":"pending","recipient":"+1234567890","message":"Payment processed"},{"id":"N003","type":"push","status":"delivered","recipient":"user123","title":"New product available"}],"_demo_info":{"service_type":"Notifications Service (EC2)","target_url":"http://api.example.local/notifications","routing_method":"Path-based"}}';
    }
    location /health {
        add_header Content-Type application/json;
        return 200 '{"status":"healthy","service":"notifications-service"}';
    }
}
NGINX

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

echo "Notifications service setup completed successfully!"
EOT

  instance_tags = {
    Service = "notifications"
    Domain  = "communication"
  }
}

############################################
# Health Service
############################################

module "ec2_health_service" {
  source = "tfstack/ec2-server/aws"

  name      = "${local.base_name_3}-ec2-health-service"
  subnet_id = module.vpc_3.private_subnet_ids[2]
  vpc_id    = module.vpc_3.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.ec2_health_service_sg.id]

  instance_type    = "t3.micro"
  assign_public_ip = false
  enable_ssm       = true

  user_data = <<-EOT
#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting health service setup..."

# Update system
if command -v dnf >/dev/null 2>&1; then
  dnf -y update
else
  yum -y update
fi

# Install nginx using amazon-linux-extras
amazon-linux-extras install nginx1 -y

# Configure nginx
cat > /etc/nginx/conf.d/default.conf << 'NGINX'
server {
    listen 80;
    location /health {
        add_header Content-Type application/json;
        return 200 '{"status":"healthy","service":"health-service","timestamp":"2024-01-15T10:30:00Z"}';
    }
    location / {
        add_header Content-Type application/json;
        return 200 '{"api_version":"1.0","service":"health-service","message":"Health Service (EC2)","health":[{"id":"H001","type":"cpu","status":"healthy","value":"85%"},{"id":"H002","type":"memory","status":"healthy","value":"45%"},{"id":"H003","type":"disk","status":"healthy","value":"75%"}],"_demo_info":{"service_type":"Health Service (EC2)","target_url":"http://api.example.local/health","routing_method":"Path-based"}}';
    }
}
NGINX

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

echo "Health service setup completed successfully!"
EOT

  instance_tags = {
    Service = "health"
    Domain  = "health"
  }
}
