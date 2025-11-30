# 🚀 Hướng dẫn sử dụng Scripts GlusterFS - Phiên bản nâng cao

## 📌 Tính năng mới

✅ **Hỗ trợ nhiều server** - không giới hạn 2 server nữa!  
✅ **Tự động lấy IP** - script tự phát hiện IP của máy  
✅ **Đặt tên tùy chỉnh** - bạn có thể đặt hostname bất kỳ  
✅ **Tạo volume động** - tự động tính replica count  
✅ **Linh hoạt khi đổi IP** - script change-ip hỗ trợ nhiều server

---

## 📁 Các file script

1. **setup-filesvr1.sh** - Master server (chạy trên server đầu tiên)
2. **setup-filesvr2.sh** - Worker server (chạy trên các server còn lại)
3. **setup-client.sh** - Client Ubuntu
4. **change-ip.sh** - Thay đổi IP khi chuyển mạng

---

## 🎯 Kịch bản sử dụng

### Kịch bản 1: Hệ thống 3 server

**Chuẩn bị:**

- Server 1 (Master): IP 192.168.1.101
- Server 2: IP 192.168.1.102
- Server 3: IP 192.168.1.103

**Bước 1: Chạy trên Server 2 và Server 3**

Trên **Server 2**:

```bash
chmod +x setup-filesvr2.sh
./setup-filesvr2.sh
```

Khi script hỏi:

```
IP hiện tại của máy này: 192.168.1.102
Nhập tên hostname cho máy này: filesvr2

Số lượng server khác cần thêm: 2
--- Server thứ 1 ---
Nhập IP: 192.168.1.101
Nhập hostname: filesvr1

--- Server thứ 2 ---
Nhập IP: 192.168.1.103
Nhập hostname: filesvr3
```

Tương tự trên **Server 3**:

```bash
./setup-filesvr2.sh
```

```
Nhập hostname: filesvr3
Số server khác: 2
  filesvr1: 192.168.1.101
  filesvr2: 192.168.1.102
```

**Bước 2: Chạy trên Server 1 (Master)**

```bash
chmod +x setup-filesvr1.sh
./setup-filesvr1.sh
```

Khi script hỏi:

```
IP hiện tại: 192.168.1.101
Nhập hostname: filesvr1

Số lượng server khác: 2
--- Server thứ 1 ---
IP: 192.168.1.102
Hostname: filesvr2

--- Server thứ 2 ---
IP: 192.168.1.103
Hostname: filesvr3
```

Script sẽ tự động:

- Kết nối peer với filesvr2 và filesvr3
- Tạo volume với replica 3
- Cài đặt Samba

---

### Kịch bản 2: Hệ thống 5 server

Tương tự, chỉ cần:

- Chạy `setup-filesvr2.sh` trên 4 server (server 2,3,4,5)
- Chạy `setup-filesvr1.sh` trên server 1
- Nhập đầy đủ 4 server khi được hỏi

Hệ thống sẽ tự tạo volume với **replica 5**!

---

## 🔄 Khi đổi IP (chuyển mạng)

### Ví dụ: Từ mạng nhà sang mạng trường

**Mạng cũ (nhà):**

```
192.168.1.101 filesvr1
192.168.1.102 filesvr2
192.168.1.103 filesvr3
```

**Mạng mới (trường):**

```
10.45.20.15 filesvr1
10.45.20.16 filesvr2
10.45.20.17 filesvr3
```

**Chạy trên TỪNG server:**

```bash
chmod +x change-ip.sh
./change-ip.sh
```

**Trên filesvr1:**

```
IP hiện tại: 10.45.20.15
Nhập IP mới: [Enter] (giữ nguyên)
Nhập hostname: filesvr1

Số server khác: 2
Server 1: 10.45.20.16 filesvr2
Server 2: 10.45.20.17 filesvr3
```

**Trên filesvr2:**

```
IP hiện tại: 10.45.20.16
Nhập hostname: filesvr2

Số server khác: 2
Server 1: 10.45.20.15 filesvr1
Server 2: 10.45.20.17 filesvr3
```

Tương tự cho filesvr3.

**Trên client (nếu có):**

```bash
./change-ip.sh
```

Sau đó script sẽ tự động unmount và mount lại!

---

## 📝 Chi tiết từng script

### setup-filesvr2.sh (Worker Server)

**Chức năng:**

- ✅ Tự động phát hiện IP của máy
- ✅ Cho phép đặt hostname tùy chỉnh
- ✅ Nhập thông tin tất cả server khác
- ✅ Cài GlusterFS Server
- ✅ Tạo brick directory
- ✅ Kiểm tra kết nối (tùy chọn)

**Input từ người dùng:**

1. Hostname của máy này
2. Số lượng server khác
3. IP + hostname của từng server

**Output:**

- Server sẵn sàng chờ Master kết nối

---

### setup-filesvr1.sh (Master Server)

**Chức năng:**

- ✅ Tất cả chức năng của worker
- ✅ Tự động probe tất cả peer
- ✅ Tạo volume với replica count động
- ✅ Cài Samba + cấu hình share
- ✅ Tạo user Samba

**Input từ người dùng:**

1. Hostname của máy này
2. Số lượng server khác
3. IP + hostname của từng server
4. Password cho Samba user

**Output:**

- Volume đã tạo và start
- Samba sẵn sàng cho Windows

**Brick list tự động:**

```bash
# Nếu có 3 server: filesvr1, filesvr2, filesvr3
Brick list:
  filesvr1:/data/gluster/brick1
  filesvr2:/data/gluster/brick1
  filesvr3:/data/gluster/brick1

Replica count: 3
```

---

### setup-client.sh

**Chức năng:**

- ✅ Nhập thông tin tất cả server
- ✅ Chọn volume name (mặc định: gv0)
- ✅ Tự động mount từ server đầu tiên
- ✅ Thêm vào fstab

**Input:**

1. Số lượng server
2. IP + hostname từng server
3. Tên volume (nếu khác gv0)

---

### change-ip.sh

**Chức năng:**

- ✅ Backup /etc/hosts
- ✅ Phát hiện IP hiện tại
- ✅ Cập nhật hostname của máy này
- ✅ Cập nhật tất cả server khác
- ✅ Unmount + mount lại (nếu là client)

**Lưu ý:**

- Chạy trên **TẤT CẢ các máy** (servers + client)
- Đảm bảo nhập đúng thông tin để tất cả máy đồng bộ

---

## ✅ Kiểm tra sau khi cài

**Trên Master (filesvr1):**

```bash
sudo gluster peer status
# Phải thấy: State: Peer in Cluster (Connected)

sudo gluster volume info
# Phải thấy: Number of Bricks = số server

sudo gluster volume status
# Tất cả brick phải Online
```

**Test replication:**

```bash
# Trên filesvr1
echo "Test from filesvr1" | sudo tee /data/gluster/brick1/test.txt

# Trên filesvr2
cat /data/gluster/brick1/test.txt
# Phải thấy: Test from filesvr1

# Trên filesvr3
cat /data/gluster/brick1/test.txt
# Phải thấy: Test from filesvr1
```

---

## 🪟 Truy cập từ Windows

Sau khi Master setup xong:

**Cách 1: File Explorer**

```
\\filesvr1\gv0
hoặc
\\192.168.1.101\gv0
```

**Cách 2: Map network drive**

```cmd
net use Z: \\filesvr1\gv0 /user:yourusername
```

**Cách 3: PowerShell**

```powershell
New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\filesvr1\gv0" -Persist
```

---

## 🛠️ Troubleshooting

### Lỗi: Peer probe failed

**Nguyên nhân:** Server chưa cài GlusterFS hoặc chưa chạy

**Giải pháp:**

```bash
# Kiểm tra trên server bị lỗi
sudo systemctl status glusterd

# Nếu chưa chạy
sudo systemctl start glusterd
```

---

### Lỗi: Volume create failed - replica count mismatch

**Nguyên nhân:** Số brick không khớp với replica count

**Ví dụ lỗi:**

```
Replica count = 4
Số brick = 3
```

**Giải pháp:** Đảm bảo nhập đúng số server khi chạy script

---

### Lỗi: Mount failed

**Nguyên nhân:** Volume chưa start hoặc /etc/hosts sai

**Giải pháp:**

```bash
# 1. Kiểm tra volume
sudo gluster volume status
sudo gluster volume start gv0

# 2. Kiểm tra /etc/hosts
cat /etc/hosts | grep filesvr

# 3. Ping thử
ping filesvr1
```

---

### Windows không kết nối được Samba

**Nguyên nhân:** Firewall hoặc SMB version

**Giải pháp:**

**1. Kiểm tra Samba:**

```bash
sudo systemctl status smbd
sudo systemctl restart smbd
```

**2. Kiểm tra user:**

```bash
sudo pdbedit -L
# Nếu không thấy user
sudo smbpasswd -a yourusername
```

**3. Test từ Linux:**

```bash
smbclient -L filesvr1 -U yourusername
```

**4. Windows: Enable SMBv1 (nếu cần):**

```powershell
# PowerShell as Admin
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
```

---

## 🎓 Tips & Best Practices

### 1. Đặt tên server có quy tắc

✅ **Tốt:**

```
filesvr1, filesvr2, filesvr3
storage1, storage2, storage3
gluster-node1, gluster-node2
```

❌ **Tránh:**

```
server, myserver, test
máy1, máy2 (có dấu)
192.168.1.101 (dùng IP làm hostname)
```

### 2. Dùng NAT nếu hay di chuyển

Nếu bạn thường xuyên chuyển mạng, cấu hình VMware/VirtualBox dùng NAT:

- IP sẽ cố định (192.168.80.x)
- Không cần chạy change-ip.sh
- GlusterFS luôn ổn định

### 3. Backup /etc/hosts

Trước khi chạy bất kỳ script nào:

```bash
sudo cp /etc/hosts /etc/hosts.original
```

### 4. Test ping trước

Trước khi chạy setup-filesvr1.sh (Master), đảm bảo:

```bash
ping filesvr2
ping filesvr3
# Tất cả phải ping được
```

### 5. Replica count = số lẻ

Với GlusterFS, nên dùng số lẻ (3, 5, 7) để tránh split-brain:

- ✅ 3 server (replica 3)
- ✅ 5 server (replica 5)
- ⚠️ 2 server (replica 2 - có thể split-brain)
- ⚠️ 4 server (replica 4 - lãng phí)

---

## 📊 Kịch bản nâng cao

### Thêm server mới vào cluster đang chạy

**Ví dụ:** Hệ thống đang có 3 server, muốn thêm server thứ 4

**Bước 1: Trên server mới (filesvr4)**

```bash
# Cài GlusterFS
sudo apt install glusterfs-server -y
sudo systemctl enable --now glusterd

# Tạo brick
sudo mkdir -p /data/gluster/brick1

# Cấu hình /etc/hosts
sudo nano /etc/hosts
# Thêm:
192.168.1.101 filesvr1
192.168.1.102 filesvr2
192.168.1.103 filesvr3
192.168.1.104 filesvr4
```

**Bước 2: Trên Master (filesvr1)**

```bash
# Thêm vào /etc/hosts
echo "192.168.1.104 filesvr4" | sudo tee -a /etc/hosts

# Probe peer
sudo gluster peer probe filesvr4

# Thêm brick vào volume
sudo gluster volume add-brick gv0 replica 4 filesvr4:/data/gluster/brick1

# Rebalance dữ liệu
sudo gluster volume rebalance gv0 start
sudo gluster volume rebalance gv0 status
```

**Bước 3: Cập nhật /etc/hosts trên server 2,3 và client**

---

## 🔐 Bảo mật

### 1. Dùng user riêng thay vì root

Trong setup-filesvr1.sh, thay đổi:

```bash
# Tạo user riêng
sudo useradd -m glusteruser
sudo chown -R glusteruser:glusteruser /data/gluster/brick1
sudo chmod -R 775 /data/gluster/brick1

# Trong smb.conf
force user = glusteruser
```

### 2. Firewall

```bash
# Mở port GlusterFS
sudo ufw allow from 192.168.1.0/24 to any port 24007:24008 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 49152:49251 proto tcp

# Port Samba
sudo ufw allow from 192.168.1.0/24 to any port 445 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 139 proto tcp
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:

1. **Kiểm tra log:**

```bash
# GlusterFS
sudo tail -f /var/log/glusterfs/glusterd.log

# Samba
sudo tail -f /var/log/samba/log.smbd
```

2. **Check service:**

```bash
sudo systemctl status glusterd
sudo systemctl status smbd
```

3. **Xem chi tiết lỗi:**

```bash
sudo gluster volume status gv0 detail
sudo gluster volume heal gv0 info
```

---

**Tác giả:** VAN_VO  
**Lab:** Lab 6 - GlusterFS (Enhanced)  
**Version:** 2.0  
**Ngày cập nhật:** 18/11/2025

---

## 📎 Phụ lục: File mẫu /etc/hosts

### Hệ thống 3 server

```
127.0.0.1       localhost
127.0.1.1       ubuntu

# GlusterFS Cluster
192.168.1.101   filesvr1
192.168.1.102   filesvr2
192.168.1.103   filesvr3
```

### Hệ thống 5 server

```
127.0.0.1       localhost
127.0.1.1       ubuntu

# GlusterFS Cluster
10.10.45.10     storage1
10.10.45.11     storage2
10.10.45.12     storage3
10.10.45.13     storage4
10.10.45.14     storage5
```
