Xác nhận. Tập trung **Laptop1**. Mục tiêu trong sơ đồ bạn gửi:

Laptop1 gồm:

- 1 VM **Ubuntu Router**:

  - Newtwork Adapter 1: lấy IP từ **VMware NAT or Brigde**
  - Newtwork Adapter 2: **192.168.20.1/24** (VMnet3 or LAN Segment)

- 2 VM Client: **192.168.20.2/24** và **192.168.20.3/24** (Adapter VMnet3 or LAN Segment)
  Gateway: **192.168.20.1**
- Các Client phải ra Internet qua Router VM

Tôi hướng dẫn theo đúng thứ tự cấu hình cần thiết.

---

## Bước 1. Tạo card mạng cho Router VM

Trong VMware Workstation:

- NIC1: chọn **NAT** thì tương ứng ens33
- NIC2: chọn **VMnet3** (Host-only hoặc LAN segment) tương ứng ens37

---

## Bước 2. Cấu hình IP cho Router VM

File:

```
/etc/netplan/01-router.yaml
```

Nội dung:

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens37:
      addresses: [192.168.20.1/24]
```

Áp dụng:

```
sudo netplan apply
```

---

## Bước 3. Bật IP Forwarding

```
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-router.conf
sudo sysctl --system
```

Kiểm tra:

```
sysctl net.ipv4.ip_forward
```

---

## Bước 4. Cấp DHCP + DNS nội bộ (tuỳ chọn nhưng nên làm)

```
sudo apt install dnsmasq -y
```

Chỉnh `/etc/dnsmasq.conf`:

```
interface=ens37
dhcp-range=192.168.20.50,192.168.20.100,12h
```

Khởi động:

```
sudo systemctl restart dnsmasq
```

---

## Bước 5. NAT cho LAN ra Internet

Tạo `/etc/nftables.conf`:

```nft
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "ens33" ip saddr 192.168.20.0/24 masquerade
    }
}
```

Áp dụng:

```
sudo systemctl enable nftables
sudo systemctl restart nftables
```

---

## Bước 6. Cấu hình mạng PC1 và PC2

Chỉnh file:

```
sudo nano /etc/netplan/50-cloud-init.yaml
```

Nội dung:

```yaml
network:
  version: 2
  ethernets:
    ens33:
      addresses: [192.168.20.2/24]  # PC2 đổi số cuối
      gateway4: 192.168.20.1
      nameservers:
        addresses: [192.168.20.1]
```

Áp dụng:

```
sudo netplan apply
```

---

## Bước 7. Kiểm tra kết quả

Trên PC1:

```
ping 192.168.20.1        # Router LAN
ping 192.168.146.1       # default gateway NAT từ VMware
ping 8.8.8.8             # Internet
curl google.com
```

Nếu tất cả thông suốt → cấu hình **Laptop1 hoàn chỉnh**.
