# Network Administration - Docker Setup

## Yêu cầu
- Docker Desktop đã được cài đặt
- Docker Compose

## Cách chạy

### 1. Build và khởi động tất cả services
```bash
docker-compose up -d --build
```

### 2. Kiểm tra trạng thái containers
```bash
docker-compose ps
```

### 3. Xem logs
```bash
# Xem tất cả logs
docker-compose logs -f

# Xem logs của webapp
docker-compose logs -f webapp

# Xem logs của postgres
docker-compose logs -f postgres
```

### 4. Truy cập ứng dụng
- Website: http://localhost:8080
- PostgreSQL: localhost:5432

### 5. Restore database (nếu cần)
```bash
# Truy cập vào container postgres
docker exec -it networkadmin-postgres bash

# Restore từ backup
pg_restore -U postgres -d EventManagement /docker-entrypoint-initdb.d/TestDb.backup
```

### 6. Dừng services
```bash
docker-compose down
```

### 7. Dừng và xóa volumes (xóa dữ liệu database)
```bash
docker-compose down -v
```

## Cấu trúc
- **postgres**: PostgreSQL 16 database
- **webapp**: ASP.NET Core application với React frontend

## Ports
- 8080: Web application
- 5432: PostgreSQL database

## Environment Variables
Có thể thay đổi trong file `docker-compose.yml`:
- `POSTGRES_DB`: Tên database
- `POSTGRES_USER`: Username
- `POSTGRES_PASSWORD`: Password
- `ConnectionStrings__EventConnectedDb`: Connection string cho .NET app
