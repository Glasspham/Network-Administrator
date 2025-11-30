# Hướng Dẫn Deploy Web Lên Ubuntu Server

## Bước 1: Chuẩn Bị Ubuntu Server

### 1.1 Cập nhật hệ thống

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 Cài đặt Node.js và npm

```bash
# Cài Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Kiểm tra version
node --version
npm --version
```

### 1.3 Cài đặt PM2 (Process Manager)

```bash
sudo npm install -g pm2
```

### 1.4 Cài đặt Nginx

```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Bước 2: Upload Code Lên Server

### Cách 1: Sử dụng Git (Khuyến nghị)

```bash
# Trên server
cd /var/www
sudo git clone https://github.com/your-username/network-config-practice.git
sudo chown -R $USER:$USER network-config-practice
cd network-config-practice
```

### Cách 2: Upload file ZIP

```bash
# Trên máy local - nén project thành ZIP
# Upload lên server bằng SCP hoặc SFTP
scp network-config-practice.zip user@your-server-ip:/home/user/

# Trên server
cd /var/www
sudo unzip /home/user/network-config-practice.zip
sudo chown -R $USER:$USER network-config-practice
cd network-config-practice
```

## Bước 3: Cài Đặt Dependencies

```bash
cd /var/www/network-config-practice
npm install
```

## Bước 4: Build Production

```bash
npm run build
```

## Bước 5: Chạy Với PM2

### 5.1 Tạo file ecosystem

```bash
nano ecosystem.config.js
```

Nội dung file:

```javascript
module.exports = {
  apps: [{
    name: 'network-config-app',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/network-config-practice',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
```

### 5.2 Chạy app với PM2

```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Bước 6: Cấu Hình Nginx

### 6.1 Tạo file config Nginx

```bash
sudo nano /etc/nginx/sites-available/network-config
```

Nội dung file:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # Thay bằng domain của bạn hoặc IP

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 6.2 Kích hoạt site

```bash
sudo ln -s /etc/nginx/sites-available/network-config /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Bước 7: Mở Firewall

```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS (nếu cần)
sudo ufw enable
```

## Bước 8: Kiểm Tra

### 8.1 Kiểm tra PM2

```bash
pm2 status
pm2 logs network-config-app
```

### 8.2 Kiểm tra Nginx

```bash
sudo systemctl status nginx
```

### 8.3 Truy cập website

Mở trình duyệt và truy cập: `http://your-server-ip` hoặc `http://your-domain.com`

## Bước 9: Setup SSL (Tùy chọn)

### 9.1 Cài đặt Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 9.2 Tạo SSL certificate

```bash
sudo certbot --nginx -d your-domain.com
```

## Các Lệnh Hữu Ích

### Quản lý PM2

```bash
pm2 restart network-config-app  # Restart app
pm2 stop network-config-app     # Stop app
pm2 delete network-config-app   # Xóa app
pm2 logs network-config-app     # Xem logs
```

### Quản lý Nginx

```bash
sudo systemctl restart nginx    # Restart Nginx
sudo systemctl reload nginx     # Reload config
sudo nginx -t                   # Test config
```

### Update code

```bash
cd /var/www/network-config-practice
git pull origin main           # Pull latest code
npm install                    # Install new dependencies
npm run build                  # Build production
pm2 restart network-config-app # Restart app
```

## Troubleshooting

### Lỗi thường gặp:

1. **Port 3000 đã được sử dụng:**

   ```bash
   sudo lsof -i :3000
   sudo kill -9 <PID>
   ```

2. **Nginx không start:**

   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

3. **PM2 app không chạy:**

   ```bash
   pm2 logs network-config-app
   ```

4. **Không truy cập được website:**
   - Kiểm tra firewall: `sudo ufw status`
   - Kiểm tra Nginx: `sudo systemctl status nginx`
   - Kiểm tra PM2: `pm2 status`

## Thông Tin Server

- **App chạy trên port:** 3000
- **Nginx proxy:** Port 80/443
- **Logs PM2:** `pm2 logs`
- **Logs Nginx:** `/var/log/nginx/`
