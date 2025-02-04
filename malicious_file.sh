#!/bin/bash
# This script installs Apache 2.4.23 (vulnerable version) and configures it insecurely.
# Run only in a controlled lab environment.

set -e

echo "Installing build dependencies..."
apt-get update
apt-get install -y build-essential libpcre3 libpcre3-dev libapr1 libapr1-dev libssl-dev wget curl

echo "Downloading Apache 2.4.23..."
wget https://archive.apache.org/dist/httpd/httpd-2.4.23.tar.gz

echo "Extracting Apache tarball..."
tar -xzvf httpd-2.4.23.tar.gz
cd httpd-2.4.23

echo "Configuring, compiling, and installing Apache..."
./configure --enable-so --enable-ssl --with-mpm=event
make
make install

cd ..

echo "Starting Apache..."
/usr/local/apache2/bin/apachectl start

echo "Appending insecure CGI configuration..."
cp /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/httpd.conf.bak
cat << 'EOF' >> /usr/local/apache2/conf/httpd.conf

# --- Insecure CGI configuration for lab vulnerability simulation ---
<Directory "/usr/local/apache2/cgi-bin">
    Options +ExecCGI
    AddHandler cgi-script .cgi .pl
    # Insecure: No proper access restrictions
</Directory>
EOF

echo "Restarting Apache..."
/usr/local/apache2/bin/apachectl restart

echo "Creating a test CGI script..."
cat << 'EOF' > /usr/local/apache2/cgi-bin/test.cgi
#!/bin/bash
echo "Content-type: text/plain"
echo ""
echo "Vulnerable Apache CGI is active!"
EOF
chmod +x /usr/local/apache2/cgi-bin/test.cgi

echo "Testing the CGI script..."
curl http://localhost/cgi-bin/test.cgi

echo "Attempting path traversal test (if allowed)..."
curl "http://localhost/cgi-bin/..%2F..%2Fetc%2Fpasswd" || echo "Test blocked."

echo "Setup complete. Remember: This environment is intentionally vulnerable and for lab use only."