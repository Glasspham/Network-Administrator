# Serve the already-built React app with Nginx
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html
HEALTHCHECK CMD wget -qO- http://127.0.0.1/ || exit 1
EXPOSE 80