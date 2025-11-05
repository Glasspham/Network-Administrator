# Dockerfile cho Backend - CoffeeAPI
FROM mcr.microsoft.com/dotnet/aspnet:7.0

WORKDIR /app

# Copy tất cả files từ publish folder
COPY . .

# Expose port cho API
EXPOSE 80

# Chạy ứng dụng
ENTRYPOINT ["dotnet", "CoffeeAPI.dll"]
