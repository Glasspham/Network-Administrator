# Chạy dự án tĩnh bằng Docker (hướng dẫn tiếng Việt)

Các file đã thêm vào thư mục này:

- `Dockerfile` — image nginx sẽ phục vụ `index.html` và thư mục `static/`.
- `.dockerignore` — loại trừ file/folder không cần thiết khỏi image.
- `docker-compose.yml` — dễ build và chạy container (map port 8080 -> 80).

Lưu ý: thư mục hiện tại (workspace) đã có `index.html` và thư mục `static/` như trong build output — Dockerfile giả định cấu trúc này.

## Build image (PowerShell)

Chạy trong thư mục chứa Dockerfile (ví dụ trong PowerShell):

```powershell
# build image
docker build -t my-static-site:latest .

# chạy container
docker run -d -p 8080:80 --name my-static-site my-static-site:latest

# xem logs
docker logs -f my-static-site

# dừng và gỡ container
docker stop my-static-site
docker rm my-static-site
```

## Dùng docker-compose (PowerShell)

```powershell
# build & chạy ở background
docker-compose up --build -d

# xem trạng thái
docker-compose ps

# dừng và gỡ
docker-compose down
```

## Port

Mặc định service map port `8080` trên máy chủ -> `80` trong container. Truy cập http://localhost:8080 để xem trang.

## Tùy chỉnh nginx

Nếu bạn cần cấu hình nginx (cache, headers, SPA rewrite), tạo file `nginx.conf` và chỉnh `Dockerfile` để copy file cấu hình đó vào `/etc/nginx/conf.d/default.conf`.

## Ghi chú

- Nếu site của bạn cần HTTPS, cân nhắc chạy reverse proxy (nginx/traefik) hoặc triển khai phía host với certificate.
- Nếu build artifacts chưa ở folder hiện tại, đảm bảo copy build output vào cùng thư mục với Dockerfile trước khi build image.
