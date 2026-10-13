FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY index.html vite.config.js ./
COPY src ./src
RUN npm run build
FROM nginxinc/nginx-unprivileged:stable-alpine
LABEL org.opencontainers.image.source="https://github.com/YashSensei/devops-assignment" \
      org.opencontainers.image.title="KitLedger frontend" \
      org.opencontainers.image.description="Equipment inventory and lending interface by Yash Agrawal" \
      org.opencontainers.image.licenses="MIT"
USER root
RUN apk upgrade --no-cache
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
USER 101:101
EXPOSE 8080
