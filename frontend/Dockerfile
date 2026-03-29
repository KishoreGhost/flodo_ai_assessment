# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:3.29.0 AS build

WORKDIR /app

# Copy pubspec and get dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the code and build for web
COPY . .
RUN flutter build web

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the build output from the first stage to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
