# ☕ Coffee Shop - Hướng dẫn triển khai đầy đủ với Docker và DNS

## 📋 Mục lục

- [☕ Coffee Shop - Hướng dẫn triển khai đầy đủ với Docker và DNS](#-coffee-shop---hướng-dẫn-triển-khai-đầy-đủ-với-docker-và-dns)
  - [📋 Mục lục](#-mục-lục)
  - [🎯 Tổng quan dự án](#-tổng-quan-dự-án)
    - [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
    - [Domain](#domain)
- [Laptop 2 (WEB SERVER)](#laptop-2-web-server)
  - [📤 Upload lên Ubuntu Server](#-upload-lên-ubuntu-server)
    - [Bước 1: Nén project (Từ Windows PowerShell)](#bước-1-nén-project-từ-windows-powershell)
    - [Bước 2: Upload lên Ubuntu](#bước-2-upload-lên-ubuntu)
  - [⚙️ Cấu hình](#️-cấu-hình)
    - [Bước 1: SSH vào Ubuntu Server](#bước-1-ssh-vào-ubuntu-server)
    - [Bước 2: Giải nén và chuẩn bị (Nếu chọn nén folder)](#bước-2-giải-nén-và-chuẩn-bị-nếu-chọn-nén-folder)
    - [Bước 3: Cấp lại permissions](#bước-3-cấp-lại-permissions)
    - [Bước 4: Cài đặt Docker (nếu chưa có)](#bước-4-cài-đặt-docker-nếu-chưa-có)
  - [🐳 Chạy Docker](#-chạy-docker)
    - [Bước 1: Dừng services chiếm port 80](#bước-1-dừng-services-chiếm-port-80)
    - [Bước 2: Chạy deploy script](#bước-2-chạy-deploy-script)
    - [Bước 3: Kiểm tra containers](#bước-3-kiểm-tra-containers)
    - [Bước 4: Kiểm tra database](#bước-4-kiểm-tra-database)
  - [🌐 Cấu hình DNS Server](#-cấu-hình-dns-server)
    - [Bước 1: Cài đặt bind9](#bước-1-cài-đặt-bind9)
    - [Bước 2: Cấu hình zone file](#bước-2-cấu-hình-zone-file)
      - [Sửa named.conf.local](#sửa-namedconflocal)
      - [Tạo folder zones và file trong zone](#tạo-folder-zones-và-file-trong-zone)
    - [Bước 3: Cấu hình named.conf.options](#bước-3-cấu-hình-namedconfoptions)
    - [Bước 4: Kiểm tra cấu hình và restart](#bước-4-kiểm-tra-cấu-hình-và-restart)
    - [Bước 5: Test DNS](#bước-5-test-dns)
- [Laptop 1 (Router + VM con)](#laptop-1-router--vm-con)
  - [🔀 Cấu hình Ubuntu Router (cho VM network nội bộ)](#-cấu-hình-ubuntu-router-cho-vm-network-nội-bộ)
    - [Kiến trúc Router](#kiến-trúc-router)
    - [Bước 1: Tạo card mạng cho Ubuntu Server(Router)](#bước-1-tạo-card-mạng-cho-ubuntu-serverrouter)
    - [Bước 2: Cấu hình IP cho Ubuntu Server(Router)](#bước-2-cấu-hình-ip-cho-ubuntu-serverrouter)
    - [Bước 3: Bật IP Forwarding (cho phép routing)](#bước-3-bật-ip-forwarding-cho-phép-routing)
    - [Bước 4: Cấu hình NAT (để VM clients ra Internet)](#bước-4-cấu-hình-nat-để-vm-clients-ra-internet)
      - [Option A: Dùng nftables (khuyến nghị cho Ubuntu mới)](#option-a-dùng-nftables-khuyến-nghị-cho-ubuntu-mới)
      - [Option B: Dùng iptables (cách truyền thống)](#option-b-dùng-iptables-cách-truyền-thống)
    - [Bước 5: Cài đặt và cấu hình DHCP + DNS (dnsmasq)](#bước-5-cài-đặt-và-cấu-hình-dhcp--dns-dnsmasq)
    - [Bước 6: Cấu hình Firewall (nếu có ufw)](#bước-6-cấu-hình-firewall-nếu-có-ufw)
    - [Bước 7: Kiểm tra Router hoạt động](#bước-7-kiểm-tra-router-hoạt-động)
  - [💻Cấu hình các VM Clients](#cấu-hình-các-vm-clients)
    - [💻Với Ubuntu Client](#với-ubuntu-client)
    - [💻Với Windows Client](#với-windows-client)
  - [✅ Kiểm tra và Test](#-kiểm-tra-và-test)
    - [Test: Từ Ubuntu Server (Web Server)](#test-từ-ubuntu-server-web-server)
    - [Test: Từ các VM con](#test-từ-các-vm-con)
      - [Trên Ubuntu VM](#trên-ubuntu-vm)
      - [Trên Windows VM](#trên-windows-vm)
  - [🐛 Troubleshooting](#-troubleshooting)
    - [Vấn đề 1: Database container không khởi động](#vấn-đề-1-database-container-không-khởi-động)
    - [Vấn đề 2: Backend lỗi 500 - Cannot connect to database](#vấn-đề-2-backend-lỗi-500---cannot-connect-to-database)
    - [Vấn đề 3: Frontend call API failed - URL sai](#vấn-đề-3-frontend-call-api-failed---url-sai)
    - [Vấn đề 4: CORS error](#vấn-đề-4-cors-error)
    - [Vấn đề 5: DNS không resolve](#vấn-đề-5-dns-không-resolve)
    - [Vấn đề 6: 502 Bad Gateway từ Nginx](#vấn-đề-6-502-bad-gateway-từ-nginx)
    - [Vấn đề 7: Port 80 conflict giữa Nginx và Docker](#vấn-đề-7-port-80-conflict-giữa-nginx-và-docker)
    - [Vấn đề 8: Window không nhận domain từ router cấp](#vấn-đề-8-window-không-nhận-domain-từ-router-cấp)

---

## 🎯 Tổng quan dự án

### Kiến trúc hệ thống

```tree
Internet
   ↓
Router WiFi (192.168.1.1/24)
   ↓
   ├── Ubuntu Server (Web Server + DNS) - 192.168.1.101
   │   ├── Docker Container: Frontend (Nginx + React) - Port 80
   │   ├── Docker Container: Backend (.NET 7 API) - Port 5000
   │   ├── Docker Container: PostgreSQL 16 - Port 5432
   │   └── DNS Server (bind9) - Port 53
   │
   └── Ubuntu Router (Optional) - 192.168.1.x / 192.168.20.1
       └── VM1, VM2 (Client machines) - 192.168.20.x
```

### Domain

- **Domain:** `www.devopp.edu.vn`
- **IP:** `192.168.1.101` (IP tĩnh của Ubuntu Server)

---

# Laptop 2 (WEB SERVER)

## 📤 Upload lên Ubuntu Server

### Bước 1: Nén project (Từ Windows PowerShell)

```powershell
# Di chuyển vào thư mục project
cd path\Archive

# Nén các file cần thiết (loại trừ file .zip)
$files = @(
    "build",
    "publish",
    "CoffeeShopBk1125.sql",
    "docker-compose.yml",
    "restore-db.sh",
    "deploy-ubuntu.sh"
)

Compress-Archive -Path $files -DestinationPath Archive.zip -Force
```

### Bước 2: Upload lên Ubuntu

```powershell
# Upload file zip
scp Archive.zip username@192.168.1.101:~/

# Hoặc upload thẳng thư mục (recommended)
scp -r path\Archive username@192.168.1.101:~/CoffeeShop/
```

---

## ⚙️ Cấu hình

### Bước 1: SSH vào Ubuntu Server

```bash
ssh username@192.168.1.101
```

### Bước 2: Giải nén và chuẩn bị (Nếu chọn nén folder)

```bash
unzip ~/Archive.zip -d .
```

### Bước 3: Cấp lại permissions

Vì khi `scp` file thường mất _permissions_ nên cần cấp lại để mới thực thi được file/folder

```bash
sudo chmod -R 755 ~/Archive
```

### Bước 4: Cài đặt Docker (nếu chưa có)

```bash
# Cập nhật hệ thống
sudo apt update
sudo apt upgrade -y

# Cài Docker
sudo apt install docker.io -y

# Cài Docker Compose
sudo apt install docker-compose -y

# Thêm user vào docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Kiểm tra
docker --version
docker compose version
```

---

## 🐳 Chạy Docker

### Bước 1: Dừng services chiếm port 80

**⚠️ QUAN TRỌNG:** Vì backend yêu cầu CORS phải truy cập qua domain `http://www.devopp.edu.vn`, Docker frontend container **PHẢI** dùng port 80 trực tiếp để Nginx container bên trong nhận đúng domain.

```bash
# Kiểm tra port 80
sudo lsof -i :80

# Dừng Nginx nếu đang chạy
sudo systemctl stop nginx
sudo systemctl disable nginx

# Dừng Apache nếu đang chạy
sudo systemctl stop apache2
sudo systemctl disable apache2

# Kiểm tra lại port 80 đã free
sudo lsof -i :80
```

**Giải thích:**

- Nginx **container** (bên trong Docker) sẽ xử lý domain và routing `/api/`
- KHÔNG dùng Nginx **host** làm reverse proxy vì sẽ mất domain header

---

### Bước 2: Chạy deploy script

```bash
cd ~/Archive

# Chạy script tự động (recommended)
./deploy-ubuntu.sh
```

**Hoặc manual:**

```bash
# Dừng containers cũ
docker compose down -v

# Build và start
docker compose up -d --build

# Xem logs
docker compose logs -f
```

### Bước 3: Kiểm tra containers

```bash
# Xem status
docker compose ps

# Kết quả phải có 3 containers:
# - Archive-db         (healthy)
# - Archive-backend    (up)
# - Archive-frontend   (up)
```

### Bước 4: Kiểm tra database

```bash
# Vào database container
docker exec -it coffeeshop-db psql -U postgres -d CoffeeShop

# Trong psql, xem tables
\dt

# Phải thấy 8 tables:
# - Branches
# - Customers
# - Drinks
# - Invoices
# - InvoicesDetails
# - MyTables
# - Staffs
# - __EFMigrationsHistory

# Thoát
\q
```

_**Hoặc có thể dùng ứng dụng bên ngoài**_

---

## 🌐 Cấu hình DNS Server

### Bước 1: Cài đặt bind9

```bash
sudo apt update
sudo apt install bind9 bind9utils bind9-doc -y
```

### Bước 2: Cấu hình zone file

#### Sửa named.conf.local

```bash
sudo nano /etc/bind/named.conf.local
```

**Thêm nội dung:**

```conf
zone "devopp.edu.vn" {
    type master;
    file "/etc/bind/zones/db.devopp.edu.vn";
};
```

#### Tạo folder zones và file trong zone

```bash
# Tạo folder zones
sudo mkdir -p /etc/bind/zones

# Tạo file trong zones
sudo nano /etc/bind/zones/db.devopp.edu.vn
```

**Nội dung cần ghi:**

> Lưu ý: (Thay `192.168.1.101` bằng IP thực tế của Ubuntu Server)

```conf
;
; BIND data file for devopp.edu.vn
;
$TTL    604800
@       IN      SOA     devopp.edu.vn. admin.devopp.edu.vn. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.devopp.edu.vn.
@       IN      A       192.168.1.101
www     IN      A       192.168.1.101
ns1     IN      A       192.168.1.101
```

### Bước 3: Cấu hình named.conf.options

```bash
sudo nano /etc/bind/named.conf.options
```

**Sửa thành:**

```confg
options {
    directory "/var/lib/bind";

    // Listen trên tất cả IPv4
    listen-on { any; };

    // Tắt IPv6
    listen-on-v6 { none; };

    // Cho phép query từ mạng local
    allow-query { any; };

    // Recursion
    recursion yes;
    allow-recursion { any; };

    dnssec-validation auto;
};
```

### Bước 4: Kiểm tra cấu hình và restart

```bash
# Kiểm tra cấu hình tổng thể
sudo named-checkconf

# Kiểm tra zone file
sudo named-checkzone devopp.edu.vn /etc/bind/zones/db.devopp.edu.vn

# Phải thấy: zone devopp.edu.vn/IN: loaded serial 3
#           OK

# Restart bind9
sudo systemctl restart named
sudo systemctl enable named

# Kiểm tra status
sudo systemctl status named
```

### Bước 5: Test DNS

```bash
# Test từ local
dig @localhost www.devopp.edu.vn

# Hoặc dùng nslookup
nslookup www.devopp.edu.vn localhost

# Phải trả về: 192.168.1.101
```

---

# Laptop 1 (Router + VM con)

## 🔀 Cấu hình Ubuntu Router (cho VM network nội bộ)

Nếu bạn muốn tạo mạng nội bộ 192.168.20.0/24 cho các VM client, cần Ubuntu Server(Router) làm gateway và DHCP server.

### Kiến trúc Router

```tree
Internet/WiFi Router (192.168.1.1/24)
        ↓
Ubuntu Router (Laptop1 hoặc VM)
  ├─ NIC1 (ens33): DHCP từ WiFi Router (192.168.1.x)
  └─ NIC2 (ens37): IP tĩnh 192.168.20.1/24 (LAN Segment)
        ↓
  VM Clients (192.168.20.x)
```

---

### Bước 1: Tạo card mạng cho Ubuntu Server(Router)

Trong VMware Workstation:

- **NIC1 (ens33):** NAT hoặc Bridged (kết nối ra Internet qua WiFi Router)
- **NIC2 (ens37):** LAN Segment / VMnet3 (mạng nội bộ cho VM clients)

**Lưu ý:** `ens33` và `ens37` phụ thuộc vào thứ tự thêm card mạng trong VMware.

---

### Bước 2: Cấu hình IP cho Ubuntu Server(Router)

```bash
# Tạo file cấu hình netplan
sudo nano /etc/netplan/01-router.yaml
```

**Nội dung:**

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true  # Nhận IP từ WiFi Router (192.168.1.x)
    ens37:
      addresses: [192.168.20.1/24]  # IP tĩnh cho mạng nội bộ
```

**Áp dụng cấu hình:**

```bash
sudo netplan apply

# Kiểm tra IP
ip a
# ens33: 192.168.1.x (DHCP)
# ens37: 192.168.20.1
```

---

### Bước 3: Bật IP Forwarding (cho phép routing)

```bash
# Bật IP forwarding tạm thời
sudo sysctl -w net.ipv4.ip_forward=1

# Bật vĩnh viễn
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-router.conf
sudo sysctl --system

# Kiểm tra
sysctl net.ipv4.ip_forward
# Kết quả: net.ipv4.ip_forward = 1
```

---

### Bước 4: Cấu hình NAT (để VM clients ra Internet)

#### Option A: Dùng nftables (khuyến nghị cho Ubuntu mới)

```bash
# Cài nftables
sudo apt install nftables -y

# Tạo file cấu hình
sudo nano /etc/nftables.conf
```

**Nội dung:**

```nft
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
    chain postrouting {
        type nat hook postrouting priority srcnat;
        oifname "ens33" ip saddr 192.168.20.0/24 masquerade
    }
}
```

**Kích hoạt:**

```bash
sudo systemctl enable nftables
sudo systemctl restart nftables

# Kiểm tra rules
sudo nft list ruleset
```

#### Option B: Dùng iptables (cách truyền thống)

```bash
# Cài iptables-persistent để lưu rules
sudo apt install iptables-persistent -y

# Tạo NAT rules (thay ens33 bằng interface ra Internet)
sudo iptables -t nat -A POSTROUTING -o ens33 -s 192.168.20.0/24 -j MASQUERADE
sudo iptables -A FORWARD -i ens37 -o ens33 -j ACCEPT
sudo iptables -A FORWARD -i ens33 -o ens37 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Lưu rules
sudo netfilter-persistent save

# Xem rules
sudo iptables -t nat -L -n -v
```

---

### Bước 5: Cài đặt và cấu hình DHCP + DNS (dnsmasq)

**Cài đặt**

```bash
sudo apt update
sudo apt install dnsmasq -y
```

**Cấu hình dnsmasq:**

```bash
# Backup file gốc
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

# Sửa file
sudo nano /etc/dnsmasq.conf
```

**Thêm vào cuối file:**

```conf
interface=ens37
dhcp-range=192.168.20.50,192.168.20.100,12h
dhcp-option=option:dns-server,192.168.20.1
address=/www.devopp.edu.vn/192.168.1.101 # ip của web server
```

**Khởi động dnsmasq:**

```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
sudo systemctl status dnsmasq

# Xem log (nếu có vấn đề)
sudo tail -f /var/log/dnsmasq.log
```

---

### Bước 6: Cấu hình Firewall (nếu có ufw)

```bash
# Cho phép DHCP
sudo ufw allow 67/udp
sudo ufw allow 68/udp

# Cho phép DNS
sudo ufw allow 53/tcp
sudo ufw allow 53/udp

# Cho phép SSH
sudo ufw allow 22/tcp

# Enable firewall
sudo ufw enable
sudo ufw status
```

---

### Bước 7: Kiểm tra Router hoạt động

```bash
# 1. Kiểm tra IP forwarding
sysctl net.ipv4.ip_forward
# Kết quả: = 1

# 2. Kiểm tra NAT rules
sudo nft list ruleset  # hoặc sudo iptables -t nat -L

# 3. Kiểm tra dnsmasq
sudo systemctl status dnsmasq

# 4. Test DNS
nslookup www.devopp.edu.vn 192.168.1.101
# Phải trả về: 192.168.1.101

# 5. Test Internet từ Router
ping 8.8.8.8
```

---

## 💻Cấu hình các VM Clients

1. **Cài đặt card mạng:** LAN Segment / VMnet3 (giống Ubuntu Router NIC2)

2. **Cấu hình IP**

### 💻Với Ubuntu Client

```bash
sudo nano /etc/netplan/01-client.yaml
```

**Cấu hình IP tĩnh:**

```yaml
network:
  version: 2
  ethernets:
    ens33:
      addresses: [192.168.20.2/24]
      nameservers:
        addresses: [192.168.20.1, 8.8.8.8]
```

**Hoặc dùng DHCP:**

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
```

**Áp dụng:**

```bash
sudo netplan apply

# hoặc Renew DHCP (nếu dùng DHCP)
sudo dhclient -r
sudo dhclient

# Kiểm tra
ip a
cat /etc/resolv.conf
# Phải có: nameserver 192.168.20.1
```

### 💻Với Windows Client

```conf
   - Tự động (DHCP) - Khuyến nghị
   - Hoặc IP tĩnh:
     - IP: `192.168.20.x` (<50 hoặc >100)
     - Subnet: `255.255.255.0`
     - Gateway: `192.168.20.1`
     - DNS: `192.168.20.1`
```

**Test:**

```cmd
ipconfig /all
ipconfig /flushdns
ping 192.168.20.1
ping 8.8.8.8
nslookup www.devopp.edu.vn
```

---

## ✅ Kiểm tra và Test

### Test: Từ Ubuntu Server (Web Server)

```bash
# Test Docker containers
docker compose ps

# Test frontend container
curl -I http://localhost

# Test backend container trực tiếp
curl http://localhost:5000/swagger

# Test DNS
dig @localhost www.devopp.edu.vn
nslookup www.devopp.edu.vn localhost

# Test truy cập qua domain
curl http://www.devopp.edu.vn

# Xem logs Docker containers
docker compose logs -f frontend
docker compose logs -f backend
```

---

### Test: Từ các VM con

#### Trên Ubuntu VM

```bash
# Renew DHCP
sudo dhclient -r
sudo dhclient

# Kiểm tra DNS
cat /etc/resolv.conf
# Phải có: nameserver 192.168.1.101

# Test
dig www.devopp.edu.vn
ping www.devopp.edu.vn
curl http://www.devopp.edu.vn
# Truy cập browser http://www.devopp.edu.vn
```

#### Trên Windows VM

```cmd
REM Renew IP (khi dùng DHCP)
ipconfig /release
ipconfig /renew

REM Kiểm tra DNS
ipconfig /all

REM Test
nslookup www.devopp.edu.vn
ping www.devopp.edu.vn

REM Truy cập browser: http://www.devopp.edu.vn
```

---

## 🐛 Troubleshooting

### Vấn đề 1: Database container không khởi động

**Triệu chứng:**

```bash
docker compose ps
# Chỉ thấy 2 containers (frontend, backend)
```

**Giải pháp:**

```bash
# Xem logs database
docker compose logs database

# Nếu lỗi "bad interpreter"
sed -i 's/\r$//' restore-db.sh
chmod +x restore-db.sh

# Rebuild
docker compose down -v
docker compose up -d --build
```

---

### Vấn đề 2: Backend lỗi 500 - Cannot connect to database

**Triệu chứng:**

```bash
docker compose logs backend
# Failed to connect to 127.0.0.1:5432
```

**Nguyên nhân:** File `appsettings.json` vẫn có `localhost:5432`

**Giải pháp:**

```bash
# Kiểm tra
cat publish/appsettings.json | grep Host

# Sửa
nano publish/appsettings.json
# Đổi: Host=localhost:5432
# Thành: Host=database:5432

# Rebuild backend
docker compose stop backend
docker compose rm -f backend
docker rmi archive-backend
docker compose up -d --build backend
```

---

### Vấn đề 3: Frontend call API failed - URL sai

**Triệu chứng:**

```bash
Request URL: http://localhost:5094/api/Branch
hoặc
Request URL: http://www.devopp.edu.vn/api/api/Branch
```

**Giải pháp:**

```bash
# Kiểm tra runtime-config.js
cat build/runtime-config.js

# Phải là:
# API_BASE_URL: "/"

# Nếu sai, sửa lại
nano build/runtime-config.js

# Rebuild frontend
docker compose stop frontend
docker compose rm -f frontend
docker rmi archive-frontend
docker compose up -d --build frontend
```

---

### Vấn đề 4: CORS error

**Triệu chứng:**

```bash
Access to XMLHttpRequest has been blocked by CORS policy
```

**Giải pháp:**

1. **Phải truy cập qua domain** `http://www.devopp.edu.vn` không phải `localhost`

2. Kiểm tra backend có biến môi trường CORS:

```bash
docker compose logs backend | grep CORS

# Trong docker-compose.yml phải có:
# - CORS__AllowedOrigins=http://www.devopp.edu.vn
```

---

### Vấn đề 5: DNS không resolve

**Triệu chứng:**

```bash
nslookup www.devopp.edu.vn
# NXDOMAIN hoặc timeout
```

**Giải pháp:**

```bash
# Kiểm tra bind9
sudo systemctl status named

# Xem logs
sudo journalctl -u named -n 50

# Kiểm tra zone file
sudo named-checkzone devopp.edu.vn /etc/bind/zones/db.devopp.edu.vn

# Nếu có lỗi, sửa zone file
sudo nano /etc/bind/zones/db.devopp.edu.vn

# Tăng Serial number lên
# Serial: 3 -> 4

# Restart
sudo systemctl restart named

# Test
dig @localhost www.devopp.edu.vn
```

---

### Vấn đề 6: 502 Bad Gateway từ Nginx

**Triệu chứng:**

```bash
Browser hiển thị: 502 Bad Gateway
```

**Nguyên nhân:** Nginx không kết nối được tới Docker container

**Giải pháp:**

```bash
# Kiểm tra containers có chạy không
docker compose ps

# Kiểm tra Nginx config
sudo nginx -t

# Xem logs Nginx
sudo tail -n 50 /var/log/nginx/coffeeshop_error.log

# Restart Nginx
sudo systemctl restart nginx

# Nếu containers chưa chạy
docker compose up -d

# Kiểm tra kết nối
curl -I http://localhost:80
```

---

### Vấn đề 7: Port 80 conflict giữa Nginx và Docker

**Triệu chứng:**

```bash
Error: failed to bind host port 0.0.0.0:80
```

**Nguyên nhân:** Nginx host và Docker frontend đều muốn dùng port `80`

**Giải pháp: TẮT Nginx host (KHUYẾN NGHỊ)**

Vì backend yêu cầu CORS phải truy cập qua domain `http://www.devopp.edu.vn`, nên **PHẢI** để Docker frontend container sử dụng port `80` trực tiếp.

```bash
# Dừng Nginx host
sudo systemctl stop nginx
sudo systemctl disable nginx

# Kiểm tra port 80 đã free
sudo lsof -i :80

# Docker frontend dùng port 80 trực tiếp
docker compose up -d
```

**Lưu ý:**

- Nginx container **BÊN TRONG** Docker frontend sẽ xử lý domain và routing
- KHÔNG cần Nginx host làm reverse proxy

---

### Vấn đề 8: Window không nhận domain từ router cấp

**Giải pháp** config file host của system

Bước 1: Open notepad với `run as administrator`

Bước 2: Vào mục file > Open > `C:\Windows\System32\drivers\etc`

Bước 3: Chỉnh sang `All files *.*`

Bước 4: Chọn file `host`

Bước 5: Thêm nội dung dưới

```bash
192.168.1.101 www.devopp.edu.vn
```

Bước 6: Ctrl + s

---

**🎉 Chúc bạn deploy thành công!**