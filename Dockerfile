FROM nginx:alpine

WORKDIR /build

COPY ./build /build

COPY ./nginx.conf /etc/nginx/nginx.conf