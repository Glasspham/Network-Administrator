# 🌐 Network Administration

<p align="center">
  <img src="https://img.shields.io/badge/Subject-Network%20Administration-green?style=for-the-badge" alt="Network Admin">
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
</p>

## 📝 Giới thiệu

Đây là tài liệu và một số lab thực hành môn **Quản trị mạng** tại **Trường Đại học Giao Thông Vận Tải Thành phố Hồ Chí Minh**.

Repository bao gồm các hướng dẫn chi tiết, scripts tự động hóa và các dự án thực hành từ cơ bản đến nâng cao về quản trị hệ thống mạng.

---

## 📚 Nội dung

### 📖 Slide bài giảng

| STT | Tên Lab                                                                                                                                                        | Mô tả                                    |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| 1   | [Lab 1 - Installing and Managing VMWare](Slide/Lab%201%20-%20Installing%20and%20Managing%20VMWare.pdf)                                                         | Cài đặt và quản lý VMware                |
| 2   | [Lab 2 - Installing and Managing Ubuntu Server](Slide/Lab%202%20-%20Installing%20and%20Managing%20Ubuntu%20Server%20_1.0.2.pdf)                                | Cài đặt và quản lý Ubuntu Server         |
| 3   | [Lab 3 - Managing Ubuntu Server - Users, Roles and Privileges](Slide/Lab%203%20-%20Managing%20Ubuntu%20Server%20-%20Users%20-%20Roles%20and%20Priviledges.pdf) | Quản lý người dùng, vai trò và quyền hạn |
| 4   | [Lab 4 - Discovering Docker](Slide/Lab%204%20-%20Discovering%20Docker.pdf)                                                                                     | Khám phá Docker                          |
| 5   | [Lab 5 - Deploying React Application with Docker](Slide/Lab%205%20-%20Deploying%20React%20Application%20with%20Docker.pdf)                                     | Triển khai ứng dụng React với Docker     |
| 6   | [Lab 6 - Storage service with GlusterFS](Slide/Lab%206%20-%20Storage%20service%20with%20ClusterFS%20in%20Ubuntu%20server.pdf)                                  | Dịch vụ lưu trữ với GlusterFS            |
| 📝  | [Lab - Middle term assessment](Slide/Lab%20-%20Middle%20term%20assessment%20_1.0.1.pdf)                                                                        | Bài kiểm tra giữa kỳ                     |

---

### 📂 Hướng dẫn thực hành

| Tài liệu                                                                                                 | Mô tả                                        |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| [Lab 6 - Tutorial](Lab6%20-%20Tutorial.md)                                                               | Hướng dẫn chi tiết triển khai GlusterFS      |
| [README-Scripts](README-Scripts.md)                                                                      | Hướng dẫn sử dụng scripts tự động cho Lab 6  |
| [HUONG-DAN-SU-DUNG](HUONG-DAN-SU-DUNG.md)                                                                | Hướng dẫn sử dụng scripts GlusterFS nâng cao |
| [UBUNTU-DEPLOY](UBUNTU-DEPLOY.md)                                                                        | Hướng dẫn deploy web lên Ubuntu Server       |
| [WireGuard + Tailscale](Hướng%20dẫn%20WireGuard%20hai%20PC%20Windows%20khác%20LAN%20dùng%20Tailscale.md) | Kết nối hai PC Windows khác LAN              |

---

### 🚀 Dự án thực hành

#### 📌 Bài thi Giữa kỳ (GK)

> **Coffee Shop** - Ứng dụng web với Docker và DNS

- **Công nghệ:** React, .NET Core API, PostgreSQL, Docker, Nginx, DNS (bind9)
- **Nội dung:**
  - Triển khai ứng dụng web với Docker Compose
  - Cấu hình DNS Server
  - Thiết lập Ubuntu Router cho VM network nội bộ
  - Cấu hình NAT, DHCP, Firewall
- 📁 [Xem chi tiết](GK/README.md)

#### 📌 Bài thi Cuối kỳ (CK)

> **Network Admin Test** - Hệ thống quản lý với Docker

- **Công nghệ:** React, .NET Core API, PostgreSQL, Docker
- **Nội dung:**
  - Build và deploy với Docker Compose
  - Quản lý database với PostgreSQL
- 📁 [Xem chi tiết](CK/README.md)

---

### 🛠️ Các dự án Docker mẫu

| Thư mục            | Mô tả                    | Công nghệ        |
| ------------------ | ------------------------ | ---------------- |
| [build/](build/)   | Static website với Nginx | Docker, Nginx    |
| [net6.0/](net6.0/) | ASP.NET Core MVC App     | .NET 6.0, Docker |

---

## 🔧 Công nghệ sử dụng

<p align="center">
  <img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/VMware-607078?style=for-the-badge&logo=vmware&logoColor=white" alt="VMware">
  <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white" alt="Nginx">
  <img src="https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white" alt=".NET">
  <img src="https://img.shields.io/badge/React-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
</p>

---

## 📋 Yêu cầu hệ thống

- **VMware Workstation** hoặc **VirtualBox**
- **Ubuntu Server** 20.04 LTS trở lên
- **Docker** & **Docker Compose**
- **Git** (để clone repository)

---

## 🚀 Bắt đầu nhanh

```bash
# Clone repository
git clone https://github.com/Glasspham/Network-Administrator.git
cd Network-Administrator

# Chạy một dự án Docker (ví dụ: GK)
cd GK
docker-compose up -d --build
```

---

## 📞 Liên hệ

- **Trường:** Đại học Giao Thông Vận Tải TP.HCM (UTC2)
- **Môn học:** Quản trị mạng
- **GitHub:** [Glasspham](https://github.com/Glasspham)

---

## 📄 License

Dự án này được tạo ra với mục đích học tập và nghiên cứu.

---

<p align="center">
  <i>⭐ Nếu thấy hữu ích, hãy cho mình một star nhé! ⭐</i>
</p>
