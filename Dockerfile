# Use an official Nginx image as a base
FROM nginx:alpine

# Copy your project files to the Nginx HTML directory
COPY . /usr/share/nginx/html

# Expose port 3000
EXPOSE 3000
