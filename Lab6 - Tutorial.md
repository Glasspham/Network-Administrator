# **Lab 6 – Triển khai GlusterFS trong Ubuntu Server**

## **1. Mục tiêu**

Xây dựng hệ thống lưu trữ phân tán có khả năng:

* Tự động sao chép dữ liệu giữa 2 hoặc nhiều server.
* Vẫn truy cập được dữ liệu khi 1 server bị lỗi.
* Cho phép client (Linux hoặc Windows) truy cập vùng lưu trữ chung.

---

## **2. Chuẩn bị**

### **2.1. Mô hình**

* **filesvr1** – IP: `192.168.1.102`
* **filesvr2** – IP: `192.168.1.103`
* **client** (Ubuntu hoặc Windows) – IP: `192.168.1.x`

### **2.2. Kiểm tra kết nối**

Cấu hình trong `/etc/hosts` trên cả 3 máy:

```config
192.168.1.102 filesvr1
192.168.1.103 filesvr2
```

Sau đó kiểm tra:

```bash
ping filesvr2
ping filesvr1
```

---

## **3. Cài đặt GlusterFS**

Trên **cả 2 server (filesvr1, filesvr2)**:

```bash
sudo apt update
sudo apt install glusterfs-server -y
sudo systemctl enable --now glusterd
sudo systemctl status glusterd
```

Kiểm tra cổng:

```bash
sudo ss -lntup | grep gluster
```

> GlusterFS cần các port 24007, 24008, và từ 49152 trở lên (TCP/UDP).

---

## **4. Thiết lập Trusted Storage Pool**

Trên **filesvr1**:

```bash
sudo gluster peer probe filesvr2
sudo gluster peer status
```

Kết quả hiển thị `Peer in Cluster (Connected)` là thành công.

---

## **5. Tạo thư mục lưu trữ (Brick)**

Trên **cả hai node**:

```bash
sudo mkdir -p /data/gluster/brick1
```

---

## **6. Tạo Volume và bật Replication**

Trên **filesvr1**:

```bash
sudo gluster volume create gv0 replica 2 \
filesvr1:/data/gluster/brick1 \
filesvr2:/data/gluster/brick1 force
sudo gluster volume start gv0
sudo gluster volume info
```

---

## **7. Mount Volume trên client**

### **7.1. Trên Ubuntu client**

```bash
sudo apt install glusterfs-client -y
sudo mkdir -p /mnt/glusterfs
sudo mount -t glusterfs filesvr1:/gv0 /mnt/glusterfs
```

Tự động mount khi khởi động:

```bash
echo "filesvr1:/gv0 /mnt/glusterfs glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
```

### **7.2. Kiểm tra**

```bash
echo "Hello GlusterFS" | sudo tee /mnt/glusterfs/test.txt
```

Trên **filesvr2**, kiểm tra:

```bash
cat /data/gluster/brick1/test.txt
```

> Nếu thấy nội dung giống nhau, replication đã hoạt động.

---

## **8. Chia sẻ qua Samba để máy Windows truy cập**

### **8.1. Cài đặt Samba**

Trên **filesvr1**:

```bash
sudo apt install samba -y
```

### **8.2. Cấu hình chia sẻ**

```bash
sudo nano /etc/samba/smb.conf
```

Thêm cuối file:

```config
[gv0]
   comment = Gluster volume gv0
   path = /data/gluster/brick1
   read only = no
   browseable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   force user = root
```

> Root cấp ở đây là quyền đọc/ghi cho thư mục đó
> Bạn có thể thay `root` bằng user cụ thể nếu muốn bảo mật hơn. Thì phải cấp quyền thư mục đó cho 1 user bất kỳ.

```bash
sudo chown -R glass:glass /data/gluster/brick1
sudo chmod -R 775 /data/gluster/brick1
```

### **8.3. Khởi động lại dịch vụ**

```bash
sudo systemctl restart smbd
sudo systemctl enable smbd
```

### **8.4. Tạo tài khoản Samba**

Tạo user cho window vào mà không thông qua root:

```bash
sudo smbpasswd -a yourusername
```

### **8.5. Truy cập từ Windows**

Trong File Explorer:

```path
\\filesvr1\gv0
```

Hoặc qua CMD:

```cmd
net use Z: \\filesvr1\gv0 /user:yourusername
```

---

## **9. Kiểm tra đồng bộ**

* Tạo file trong ổ Z:\ trên Windows, xem có xuất hiện ở `/mnt/glusterfs` và `/data/gluster/brick1` trên cả hai server không.
* Nếu có, hệ thống hoạt động ổn định.

---

## **10. Mở rộng và bảo trì**

* Thêm node thứ 3:

  ```bash
  sudo gluster peer probe filesvr3
  sudo gluster volume add-brick gv0 replica 3 filesvr3:/data/gluster/brick1
  ```

* Kiểm tra health:

  ```bash
  sudo gluster volume heal gv0 info
  ```

---

Bạn có muốn tôi tạo sẵn file hướng dẫn này ở định dạng **README.md** để bạn đưa vào thư mục lab hoặc nộp luôn cùng bài thực hành không?


Bạn **không cần làm lại lab từ đầu**. Chỉ cần đổi IP trong một vài chỗ là toàn bộ hệ thống GlusterFS + Samba sẽ hoạt động lại bình thường khi bạn đổi mạng (ở nhà → trường → phát 4G).

Tôi giải thích rõ để bạn yên tâm.

---

# ✅ **1. GlusterFS KHÔNG phụ thuộc mạng bên ngoài**

GlusterFS chỉ cần:

* Hai server *nhìn thấy nhau qua IP*
* hostname trỏ đúng IP

Nó **không quan tâm** bạn dùng:

* Bridge
* NAT
* Wifi 4G
* IP nhà (192.168.1.x)
* IP 4G (10.x.x.x hoặc 172.x.x.x, đôi khi 192.168.x.x khác)

**Bạn chỉ cần sửa IP trong 2 chỗ:**

1. `/etc/hosts`
2. Re-mount lại volume trên client

Không cần tạo lại brick, không cần tạo lại volume.

---

# 🟦 **2. Đổi IP khi đổi mạng – làm như sau:**

Giả sử ở nhà:

```
filesvr1 = 192.168.1.101
filesvr2 = 192.168.1.102
client   = 192.168.1.50
```

Lên trường/4G và bạn được cấp IP kiểu:

```
10.10.45.12
10.10.45.19
10.10.45.21
```

Bạn chỉ làm:

---

## **(A) Trên cả 3 máy (filesvr1, filesvr2, client):**

Sửa:

```bash
sudo nano /etc/hosts
```

Thay toàn bộ thành IP mới:

```
10.10.45.12 filesvr1
10.10.45.19 filesvr2
```

Lưu lại.

---

## **(B) Trên client (Ubuntu client)**

Gỡ mount cũ:

```bash
sudo umount /mnt/glusterfs
```

Mount lại:

```bash
sudo mount -t glusterfs filesvr1:/gv0 /mnt/glusterfs
```

---

# 🟩 **3. Bạn KHÔNG cần:**

* tạo lại brick
* tạo lại thư mục `/data/gluster/...`
* tạo lại volume `gv0`
* chạy `gluster volume create` lại
* cấu hình Samba lại
* đổi tên gì cả

Tất cả **vẫn giữ nguyên**, chỉ IP thay đổi.

---

# 🟨 **4. Lưu ý quan trọng**

**Nếu bạn dùng BRIDGE**, thì VM sẽ được cấp IP từ router hiện tại.

→ **Yêu cầu duy nhất:**
filesvr1 và filesvr2 phải cùng mạng (ví dụ cùng 10.x.x.x hoặc cùng 192.168.x.x).
Nếu bạn dùng 4G từ điện thoại, *đôi khi chỉ cấp được 1 IP cho 1 thiết bị*, và các thiết bị còn lại bị NAT đằng sau → lúc đó 2 VM sẽ không thấy nhau.

**Giải pháp trường hợp 4G chỉ cấp 1 IP:**

* Bạn phải bật “Hotspot Cho phép nhiều thiết bị” hoặc “WiFi sharing” trên máy laptop
  hoặc
* Dùng NAT trong VMware (tất cả máy ảo = cùng mạng NAT của VMware → luôn liên kết được dù IP thật thay đổi).

---

# 🟩 **5. Trường hợp tốt nhất nếu bạn hay di chuyển**

**Dùng NAT thay vì Bridge**
→ Filesvr1, filesvr2, client **luôn giữ IP cố định**, ví dụ:

```
192.168.80.102
192.168.80.103
192.168.80.110
```

→ Khi bạn đổi mạng (ở nhà → trường → 4G), NAT vẫn bảo đảm:

* Máy ảo thấy nhau
* Mạng GlusterFS không bị ảnh hưởng
* Không cần thay IP
* Không cần sửa `/etc/hosts`

Chỉ cần đảm bảo NAT có Internet (optional).

---

# 🔥 **Kết luận**

Bạn có 2 lựa chọn:

## **A. Dùng BRIDGE**

→ Khi đổi mạng bạn phải **đổi IP trong /etc/hosts** và mount lại volume.
→ Không phải làm lại lab.

## **B. Dùng NAT**

→ Không bao giờ phải sửa IP, không bao giờ phải cấu hình lại.
→ GlusterFS hoạt động ổn định dù bạn ở đâu.

---

# Bạn muốn tôi hướng dẫn cách chuyển toàn bộ lab sang NAT để không bao giờ phải sửa IP nữa không?
