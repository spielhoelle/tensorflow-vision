FROM node:16 AS build

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
RUN npm install
COPY . ./
RUN npm run build
COPY ./nginx.conf /app/build/nginx.conf
RUN ls -la /app/build

FROM nginx:1.19-alpine
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/build /usr/share/nginx/html