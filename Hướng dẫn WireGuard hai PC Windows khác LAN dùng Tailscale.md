# Hướng dẫn kết nối hai PC Windows ở hai mạng LAN khác nhau bằng Tailscale (WireGuard)

## 1. Tổng quan

Tailscale là dịch vụ triển khai WireGuard dạng mesh: mỗi thiết bị tự động tạo tunnel WireGuard tới nhau qua mạng trung gian của Tailscale (DERP relay nếu cần). Nhờ đó bạn không phải mở port router hay cấu hình NAT. Hai PC Windows tại hai mạng LAN khác nhau sẽ giao tiếp qua địa chỉ riêng `100.x.y.z` do Tailscale cấp.

## 2. Chuẩn bị

1. **Tài khoản Tailscale** (đăng nhập bằng Google, Microsoft, GitHub…).
2. **Quyền cài phần mềm** trên cả hai PC Windows.
3. **Quyền truy cập Internet ổn định** cho cả hai máy.
4. (Tuỳ chọn) Bật **MagicDNS** trong admin console để dùng tên máy thay vì IP.

## 3. Cài đặt Tailscale

Thực hiện trên từng PC:

1. Tải installer Windows từ `https://tailscale.com/download`.
2. Chạy file `.msi` → hoàn tất cài → Tailscale icon xuất hiện trong system tray.
3. Đăng nhập bằng tài khoản đã chuẩn bị; cho phép máy tham gia tailnet.
4. Kiểm tra Tailscale chạy ở chế độ **Connected** (icon xanh).

## 4. Lấy địa chỉ WireGuard (Tailscale IP)

- Sau khi đăng nhập, mỗi PC nhận một địa chỉ IPv4 `100.x.y.z` và IPv6 `fd7a:115c:a1e0::/48`.
- Xem trong GUI: nhấn icon Tailscale → Copy IP.
- Hoặc PowerShell (sau khi cài tailscale CLI):

  ```powershell
  tailscale ip -4
  tailscale ip -6
  ```

- Ghi lại địa chỉ của mỗi máy (ví dụ PC1: `100.80.10.5`, PC2: `100.101.22.7`).

## Chỗ này mày cần:

- ở mục user mời pc2 vào, rồi ở pc2 ấn ở icon hình tài khoản chuyển qua mail pc1
- Thế nói mới ping đc với nhau khi khác mạng LAN
- Dễ hiểu thì như vậy này:
  Admin Console → Settings → Users
  Invite email của PC2 vào cùng organization
  PC2 logout tailnet cũ, join tailnet mới

## 5. Kiểm tra kết nối trực tiếp

1. Từ PC1, mở PowerShell:

   ```powershell
   ping 100.101.22.7
   ```

2. Từ PC2:

   ```powershell
   ping 100.80.10.5
   ```

3. Kiểm tra thêm bằng `tailscale status` để thấy phiên handshake WireGuard.

## 6. Chia sẻ mạng LAN (Subnet Routing) – tuỳ chọn

Nếu muốn PC1 truy cập các thiết bị khác trong LAN của PC2 (ví dụ `192.168.156.0/24`):

1. Trên PC2 chạy Tailscale, bật **Enable subnet routes**:

   ```powershell
   tailscale up --advertise-routes=192.168.156.0/24
   ```

   (hoặc dùng GUI → Preferences → Advertise routes…)
2. Vào `https://login.tailscale.com/admin/routes` chấp thuận route vừa quảng bá.
3. Trên PC1, truy cập thiết bị LAN PC2 bằng IP nội bộ qua tunnel (ví dụ `ping 192.168.156.10`).
4. Lặp lại tương tự nếu muốn chia sẻ LAN từ PC1.

# IP Forwarding vẫn chưa hoạt động

- Trên PC1, kiểm tra registry
  reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v IPEnableRouter

- Nếu không có hoặc = 0, thì set lại
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v IPEnableRouter /t REG_DWORD /d 1 /f

restart lại máy

# Restart PC1

shutdown /r /t 0

## 7. Thiết lập tự khởi động & quyền

- Windows Service của Tailscale mặc định chạy cùng hệ thống. Đảm bảo icon Tailscale trong tray → **Settings** → bật "Run Tailscale on startup".
- Nếu dùng tài khoản chuẩn, Tailscale cài service `Tailscale IPN Service` (Automatic); kiểm tra bằng `services.msc`.

## 8. Bảo mật & quản trị

1. **ACL**: trong admin console → Access controls, đặt chính sách ai được truy cập ai. Mặc định cho phép tất cả thiết bị trong tailnet.
2. **Device approval**: bật chế độ "Device approval" nếu muốn chủ tailnet duyệt thủ công mỗi thiết bị mới.
3. **Key expiry**: mặc định 180 ngày. Có thể bật "keep alive" hoặc gia hạn thủ công.
4. **Nâng cao**: bật "Disable key expiry" cho thiết bị cố định hoặc dùng `tailscale up --accept-routes --ssh` nếu cần SSH qua tunnel.

## 9. Troubleshooting

1. **Không ping được**:
   - Kiểm tra Tailscale icon có xanh không.
   - Mở `tailscale status` xem peer có `direct` hay `derp`. Dù `derp` vẫn hoạt động, nhưng nếu không thấy peer, đăng xuất/đăng nhập lại.
   - Kiểm tra firewall Windows: Tailscale tự thêm rule. Nếu bạn dùng firewall bên thứ ba, cho phép `tailscale.exe` và UDP 41641.
2. **Không thấy subnet route**:
   - Đảm bảo đã approve route trong admin console.
   - Trên máy nhận route, chạy `tailscale ip -4` để xác nhận IP; route xuất hiện trong `route print`.
3. **Thiết bị idle bị ngắt**: Tailscale tự giữ tunnel, nhưng nếu sleep kéo dài, cần wake và đợi 1-2 giây.
4. **Muốn đổi tailnet**: đăng xuất Tailscale (GUI → Logout) rồi đăng nhập tailnet khác.

## 10. Chia sẻ thiết bị giữa các tài khoản Tailscale khác nhau

### 10.1. Tổng quan về Node Sharing

Tailscale cho phép chia sẻ thiết bị (node) giữa các tailnet khác nhau thông qua tính năng **Node Sharing**. Điều này có nghĩa là:

- Mỗi người vẫn giữ tài khoản Tailscale riêng của mình
- Thiết bị có thể được chia sẻ và xuất hiện trong nhiều tailnet
- Không cần hợp nhất hoàn toàn hai tài khoản

### 10.2. Cách chia sẻ thiết bị từ PC1 cho PC2

#### Bước 1: Chia sẻ từ PC1 (chủ sở hữu thiết bị)

1. Trên PC1, đảm bảo Tailscale đã đăng nhập và hoạt động
2. Truy cập **Tailscale Admin Console**:`https://login.tailscale.com/admin/machines`
3. Tìm PC1 trong danh sách thiết bị
4. Nhấp vào **ba chấm (⋯)** bên cạnh tên thiết bị → chọn **"Share..."**
5. Trong hộp thoại chia sẻ:
   - Nhập **email tài khoản Tailscale** của người dùng PC2
   - Chọn quyền truy cập (Read-only hoặc Full access)
   - Nhấp **"Send invitation"**

#### Bước 2: Chấp nhận lời mời từ PC2

1. Người dùng PC2 kiểm tra email và tìm thư mời từ Tailscale
2. Nhấp vào **"Accept invitation"** trong email
3. Đăng nhập vào tài khoản Tailscale của mình nếu được yêu cầu
4. PC1 sẽ xuất hiện trong danh sách thiết bị của PC2 với nhãn **"Shared"**

#### Bước 3: Chia sẻ ngược từ PC2 cho PC1 (nếu cần)

Lặp lại các bước trên nhưng từ tài khoản của PC2 để chia sẻ PC2 cho PC1.

### 10.3. Kiểm tra kết nối sau khi chia sẻ

1. Trên PC2, mở PowerShell và ping địa chỉ Tailscale của PC1:

   ```powershell
   tailscale status
   ping [IP-của-PC1]
   ```

2. Thiết bị được chia sẻ sẽ hiển thị trong `tailscale status` với trạng thái kết nối

### 10.4. Quản lý quyền truy cập

1. **Chủ sở hữu thiết bị** có thể:

   - Thu hồi quyền chia sẻ bất kỳ lúc nào
   - Thay đổi mức độ quyền truy cập
   - Xem ai đang truy cập thiết bị của mình

2. **Người nhận chia sẻ** có thể:
   - Từ chối hoặc rời khỏi thiết bị được chia sẻ
   - Truy cập thiết bị theo quyền được cấp

### 10.5. Lưu ý quan trọng

- **Bảo mật**: Chỉ chia sẻ với những người bạn tin tưởng
- **Băng thông**: Lưu lượng vẫn đi qua tunnel WireGuard được mã hóa
- **Giới hạn**: Mỗi thiết bị có thể được chia sẻ với tối đa 10 tài khoản khác
- **Billing**: Thiết bị được chia sẻ không tính vào quota của người nhận

### 10.6. Troubleshooting chia sẻ thiết bị

1. **Không nhận được email mời**:

   - Kiểm tra thư mục spam/junk
   - Đảm bảo email chính xác
   - Thử gửi lại lời mời

2. **Không thể ping thiết bị được chia sẻ**:

   - Kiểm tra trạng thái kết nối: `tailscale status`
   - Đảm bảo cả hai thiết bị đều online
   - Kiểm tra firewall trên thiết bị được chia sẻ

3. **Muốn hủy chia sẻ**:
   - Chủ sở hữu: Admin Console → Machines → chọn thiết bị → Unshare
   - Người nhận: Admin Console → Shared with me → Leave

## 11. Kết luận

Sau khi cả hai PC Windows chạy Tailscale thành công, chúng tự động thiết lập tunnel WireGuard và có thể ping qua IP `100.x.y.z` mà không cần cấu hình port forwarding. Với tính năng Node Sharing, bạn có thể dễ dàng chia sẻ thiết bị giữa các tài khoản Tailscale khác nhau mà vẫn duy trì tính bảo mật và kiểm soát truy cập.
