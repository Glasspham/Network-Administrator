#!/bin/bash

echo "========================================="
echo "Deploy Coffee Shop to Ubuntu Server"
echo "========================================="

# Stop services on port 80 if any
echo "Checking port 80..."
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl stop apache2 2>/dev/null || true

# Convert line endings for shell scripts
echo "Converting line endings..."
dos2unix restore-db.sh 2>/dev/null || sed -i 's/\r$//' restore-db.sh

# Set permissions
echo "Setting permissions..."
sudo chown -R $USER:$USER .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod +x restore-db.sh
chmod +x deploy-ubuntu.sh

# Stop and remove old containers
echo "Stopping old containers..."
docker compose down -v

# Build and start
echo "Building and starting containers..."
docker compose up -d --build

# Wait for services
echo "Waiting for services to start..."
sleep 5

# Check status
echo ""
echo "========================================="
echo "Container Status:"
echo "========================================="
docker compose ps

echo ""
echo "========================================="
echo "Checking logs..."
echo "========================================="
docker compose logs --tail=10

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo "Access application at: http://www.devopp.edu.vn"
echo "Or by IP: http://$(hostname -I | awk '{print $1}')"
