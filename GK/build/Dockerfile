# Dockerfile cho Frontend - React App
FROM nginx:alpine

# Copy build files vào nginx
COPY . /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
