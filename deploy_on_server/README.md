Sure, here is an updated `README.md` file that includes detailed steps to run the script on a VPS. This README will guide users through setting up Zabbix using Docker containers, configuring a domain name, and securing the setup with SSL.

### README.md

```markdown
# Zabbix Docker Setup

This repository provides a script and Docker Compose setup to set up Zabbix using Docker containers. The script initializes the necessary containers and configures Zabbix to work with MySQL, Nginx for reverse proxy, and SSL for security.

![Zabbix Setup](images/Capture%20d’écran%20du%202024-05-28%2009-30-12.png)

## Prerequisites

- A VPS with Docker and Docker Compose installed
- A domain name pointing to your VPS's IP address
- Basic knowledge of Docker and DNS configuration

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/zabbix-docker-setup.git
cd zabbix-docker-setup
```

### 2. Add Your Domain Name to `nginx.conf`

Edit the `nginx.conf` file to include your domain name:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://zabbix-web-nginx-mysql:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    listen 443 ssl;
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;
}

server {
    if ($host = www.yourdomain.com) {
        return 301 https://$host$request_uri;
    }

    if ($host = yourdomain.com) {
        return 301 https://$host$request_uri;
    }
}
```

### 3. Obtain SSL Certificates

You can use Let's Encrypt to obtain free SSL certificates. Install `certbot` and use the following command to obtain certificates:

```bash
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

Place the obtained certificates in the `certs` directory.

### 4. Make the script executable

```bash
chmod +x setup_zabbix.sh
```

### 5. Run the setup script

```bash
./setup_zabbix.sh
```

### 6. Access the Zabbix web interface

Open your web browser and navigate to `https://yourdomain.com`. Use the default login credentials:

- Username: `Admin`
- Password: `zabbix`

![Zabbix Dashboard](images/Capture%20d’écran%20du%202024-05-27%2018-04-04.png)

## Configuration

The script uses the following default configurations:

- MySQL root password: `password`
- MySQL database: `zabbix`
- MySQL user: `zabbix`
- MySQL user password: `password`

You can modify these values in the script as needed.

## Good Practices

- **Use Environment Variables:** To avoid hardcoding sensitive information, consider using environment variables.
- **Error Handling:** The script includes basic error handling to ensure each step is successful.
- **Logging:** The script logs progress and issues to help with troubleshooting.

## Contributing

Feel free to open issues or submit pull requests if you have suggestions or improvements.

## License

This project is licensed under the MIT License.
```

### Summary of the Steps in the README

1. **Clone the Repository:**
   Users will clone the repository to their local machine.

2. **Add Your Domain Name to `nginx.conf`:**
   Users will need to edit the `nginx.conf` file to include their own domain name.

3. **Obtain SSL Certificates:**
   Users will use Let's Encrypt's `certbot` to obtain SSL certificates for their domain.

4. **Make the Script Executable:**
   Ensure the `setup_zabbix.sh` script is executable.

5. **Run the Setup Script:**
   Execute the `setup_zabbix.sh` script to set up Zabbix.

6. **Access the Zabbix Web Interface:**
   Provide instructions to access the Zabbix web interface via the domain name with default credentials.

By following these steps, users should be able to set up Zabbix on their VPS, accessible through a domain name and secured with SSL. If you need any further customization or additional details, feel free to ask!