# Backend Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM base AS final
WORKDIR /app

# Copy published files
COPY publish/ .

# Copy static files (React build)
COPY build/ ./wwwroot/

ENTRYPOINT ["dotnet", "NetworkAdminTest.dll"]
