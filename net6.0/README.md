# MyMvcApp - ASP.NET Core 6.0 MVC Application

## Mô tả

Ứng dụng web ASP.NET Core MVC chạy trên .NET 6.0, được đóng gói bằng Docker.

## Yêu cầu hệ thống

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Cấu trúc thư mục

```tree
net6.0/
├── Dockerfile                 # File cấu hình Docker image
├── docker-compose.yml         # File cấu hình Docker Compose
├── MyMvcApp.dll              # Ứng dụng chính
├── appsettings.json          # Cấu hình ứng dụng
├── appsettings.Development.json
└── wwwroot/                  # Tài nguyên tĩnh (CSS, JS, images)
    ├── css/
    ├── js/
    └── lib/
```

## Hướng dẫn triển khai

### Cách 1: Sử dụng Docker Compose (Khuyến nghị)

```bash
# Build và chạy ứng dụng
docker-compose up -d --build

# Xem logs
docker-compose logs -f

# Dừng ứng dụng
docker-compose down
```

### Cách 2: Sử dụng Docker trực tiếp

```bash
# Build image
docker build -t mymvcapp .

# Chạy container
docker run -d -p 8080:8080 --name mymvcapp-container mymvcapp

# Dừng container
docker stop mymvcapp-container

# Xóa container
docker rm mymvcapp-container
```

## Truy cập ứng dụng

Sau khi chạy thành công, mở trình duyệt và truy cập:

🌐 **http://localhost:8080**

## Các lệnh hữu ích

| Lệnh                           | Mô tả                             |
| ------------------------------ | --------------------------------- |
| `docker-compose up -d --build` | Build và chạy ứng dụng            |
| `docker-compose down`          | Dừng và xóa container             |
| `docker-compose logs -f`       | Xem logs real-time                |
| `docker-compose restart`       | Khởi động lại ứng dụng            |
| `docker ps`                    | Xem danh sách container đang chạy |

## Cấu hình

### Biến môi trường

| Biến                     | Giá trị mặc định | Mô tả                    |
| ------------------------ | ---------------- | ------------------------ |
| `ASPNETCORE_ENVIRONMENT` | `Production`     | Môi trường chạy ứng dụng |
| `ASPNETCORE_URLS`        | `http://+:8080`  | URL và port lắng nghe    |

### Thay đổi port

Để thay đổi port, chỉnh sửa file `docker-compose.yml`:

```yaml
ports:
  - "3000:8080"  # Đổi 8080 thành port mong muốn
```

## Xử lý sự cố

### Container không khởi động được

```bash
# Xem logs để kiểm tra lỗi
docker-compose logs mymvcapp
```

### Port đã được sử dụng

```bash
# Kiểm tra port đang được sử dụng
netstat -ano | findstr :8080

# Hoặc đổi sang port khác trong docker-compose.yml
```

### Xóa và build lại hoàn toàn

```bash
docker-compose down
docker rmi mymvcapp
docker-compose up -d --build
```

## Thông tin kỹ thuật

- **Framework**: ASP.NET Core 6.0
- **Base Image**: `mcr.microsoft.com/dotnet/aspnet:6.0`
- **Port**: 8080

---

📝 **Ghi chú**: Đảm bảo Docker đang chạy trước khi thực hiện các lệnh trên.
