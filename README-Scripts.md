# Hướng dẫn sử dụng Scripts tự động cho Lab 6 - GlusterFS

## 📁 Các file script

1. **setup-filesvr1.sh** - Cài đặt tự động cho filesvr1 (192.168.1.102)
2. **setup-filesvr2.sh** - Cài đặt tự động cho filesvr2 (192.168.1.103)
3. **setup-client.sh** - Cài đặt tự động cho client Ubuntu
4. **change-ip.sh** - Script thay đổi IP khi chuyển mạng

## 🚀 Cách sử dụng

### Bước 1: Copy script vào từng máy

**Trên filesvr1:**

```bash
# Copy nội dung file setup-filesvr1.sh vào máy
nano setup-filesvr1.sh
# Paste nội dung, Ctrl+O để save, Ctrl+X để thoát

# Cấp quyền thực thi
chmod +x setup-filesvr1.sh

# Chạy script
./setup-filesvr1.sh
```

**Trên filesvr2:**

```bash
# Copy nội dung file setup-filesvr2.sh vào máy
nano setup-filesvr2.sh
# Paste nội dung, Ctrl+O để save, Ctrl+X để thoát

# Cấp quyền thực thi
chmod +x setup-filesvr2.sh

# Chạy script
./setup-filesvr2.sh
```

**Trên client (nếu dùng Ubuntu client):**

```bash
nano setup-client.sh
# Paste nội dung

chmod +x setup-client.sh
./setup-client.sh
```

### Bước 2: Thứ tự thực hiện

⚠️ **LƯU Ý CỰC KỲ QUAN TRỌNG:**

Khi bạn **BẮT ĐẦU TỪ ĐẦU** (PC/laptop mới, chưa có server nào):

```
📌 QUY TẮC: Worker servers TRƯỚC → Master server SAU CÙNG
```

**Tại sao?**

- Khi chạy Master (filesvr1), script sẽ **cố gắng kết nối** ngay với các worker
- Nếu worker **chưa tồn tại** hoặc **chưa cài GlusterFS** → **LỖI!**

---

#### 🔰 Quy trình chuẩn (Bắt đầu từ đầu):

**Bước 1: Tạo và cài đặt TẤT CẢ worker servers**

```bash
# Tạo VM filesvr2 → Chạy
./setup-filesvr2.sh

# Tạo VM filesvr3 → Chạy
./setup-filesvr2.sh

# Tạo VM filesvr4, 5, 6... (nếu cần) → Chạy
./setup-filesvr2.sh
```

💡 Bạn có thể:

- Chạy **tuần tự**: filesvr2 → filesvr3 → filesvr4...
- Hoặc chạy **song song** (nhanh hơn): mở cùng lúc nhiều terminal

**Bước 2: Đợi TẤT CẢ worker xong**

Đảm bảo trên mỗi worker đã thấy:

```
✅ glusterd đang chạy
✅ /etc/hosts đã cấu hình
✅ Brick directory đã tạo
```

**Bước 3: SAU CÙNG chạy Master (filesvr1)**

```bash
# Tạo VM filesvr1 → Chạy
./setup-filesvr1.sh
```

Script sẽ:

- ✅ Tự động probe (kết nối) TẤT CẢ worker
- ✅ Tạo volume với replica tự động (= số server)
- ✅ Cài Samba và chia sẻ cho Windows

**Bước 4: Cuối cùng setup client (nếu cần)**

```bash
./setup-client.sh
```

---

#### ⚡ Tóm tắt nhanh:

```
❌ SAI: filesvr1 → filesvr2 → filesvr3
         (Master chạy trước, không tìm thấy worker → LỖI!)

✅ ĐÚNG: filesvr2 → filesvr3 → filesvr4 → filesvr1
         (Worker sẵn sàng, Master kết nối thành công)

✅ ĐÚNG: (filesvr2 + filesvr3 + filesvr4) → filesvr1
         (Worker chạy song song, rồi Master)
```

## 📝 Script làm gì?

### setup-filesvr1.sh

- ✅ Cập nhật hệ thống
- ✅ Cài GlusterFS Server
- ✅ Cấu hình /etc/hosts
- ✅ Tạo thư mục brick
- ✅ Kết nối với filesvr2
- ✅ Tạo volume gv0 với replica 2
- ✅ Cài đặt Samba
- ✅ Cấu hình share cho Windows
- ✅ Tạo user Samba

### setup-filesvr2.sh

- ✅ Cập nhật hệ thống
- ✅ Cài GlusterFS Server
- ✅ Cấu hình /etc/hosts
- ✅ Tạo thư mục brick
- ✅ Chờ filesvr1 kết nối

### setup-client.sh

- ✅ Cài GlusterFS Client
- ✅ Cấu hình /etc/hosts
- ✅ Tạo mount point
- ✅ Mount volume
- ✅ Thêm vào fstab để tự động mount

## 🔄 Khi đổi IP (chuyển mạng)

Sử dụng script `change-ip.sh`:

```bash
# Copy script vào máy
nano change-ip.sh
chmod +x change-ip.sh

# Chạy với IP mới
./change-ip.sh 10.10.45.12 10.10.45.19
```

Script sẽ:

- Backup file /etc/hosts
- Cập nhật IP mới
- Tự động unmount và mount lại (nếu là client)

## 🪟 Truy cập từ Windows

Sau khi script chạy xong trên filesvr1, từ Windows:

1. Mở File Explorer
2. Gõ vào thanh địa chỉ:

   ```
   \\192.168.1.102\gv0
   ```

   hoặc

   ```
   \\filesvr1\gv0
   ```

3. Nhập username và password (user Samba đã tạo)

Hoặc dùng CMD:

```cmd
net use Z: \\filesvr1\gv0 /user:yourusername
```

## ✅ Kiểm tra sau khi cài đặt

**Trên filesvr1:**

```bash
sudo gluster peer status
sudo gluster volume info
sudo gluster volume status
```

**Trên client:**

```bash
df -h | grep glusterfs
echo "Test from client" | sudo tee /mnt/glusterfs/test.txt
```

**Trên filesvr2:**

```bash
cat /data/gluster/brick1/test.txt
# Phải thấy nội dung "Test from client"
```

## 🛠️ Troubleshooting

### Lỗi: không kết nối được giữa 2 server

```bash
# Kiểm tra firewall
sudo ufw status
# Nếu bật, cần mở port
sudo ufw allow from 192.168.1.0/24
```

### Lỗi: mount không được

```bash
# Kiểm tra volume đã start chưa
sudo gluster volume status
# Nếu chưa:
sudo gluster volume start gv0
```

### Lỗi: Windows không truy cập được Samba

```bash
# Kiểm tra Samba đang chạy
sudo systemctl status smbd
# Restart nếu cần
sudo systemctl restart smbd
```

## 📌 Lưu ý

- IP mặc định trong script: filesvr1 = 192.168.1.102, filesvr2 = 192.168.1.103
- Nếu IP của bạn khác, sửa trong file /etc/hosts hoặc dùng script change-ip.sh
- Đảm bảo 2 server ping được nhau trước khi chạy script
- Nếu dùng NAT trong VMware, IP sẽ cố định và không cần đổi khi chuyển mạng

## 🎯 Lợi ích của script

- ⚡ Tiết kiệm thời gian (chạy tự động thay vì gõ từng lệnh)
- 🎯 Không sót bước
- 🔄 Dễ dàng làm lại nếu cần
- 📦 Có thể dùng cho nhiều lab
- 🚀 Phù hợp khi demo hoặc nộp bài

---

**Tác giả:** VAN_VO  
**Lab:** Lab 6 - GlusterFS  
**Ngày:** 18/11/2025
