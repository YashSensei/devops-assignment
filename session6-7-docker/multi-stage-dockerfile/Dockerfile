FROM node:22-alpine AS build
WORKDIR /build
COPY server.js .
RUN node --check server.js
FROM node:22-alpine
WORKDIR /app
COPY --from=build /build/server.js .
USER node
EXPOSE 8080
CMD ["node","server.js"]
