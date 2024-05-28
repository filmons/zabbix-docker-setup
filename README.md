# Zabbix Docker Setup

This repository provides a script to set up Zabbix using Docker containers. The script initializes the necessary containers and configures Zabbix to work with MySQL.

## Prerequisites

- Docker installed on your system
- Basic knowledge of Docker commands

## Setup Instructions

1. **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/zabbix-docker-setup.git
    cd zabbix-docker-setup
    ```

2. **Make the script executable:**

    ```bash
    chmod +x setup_zabbix.sh
    ```

3. **Run the setup script:**

    ```bash
    ./setup_zabbix.sh
    ```

4. **Access the Zabbix web interface:**

    Open your web browser and navigate to `http://localhost:8080`. Use the default login credentials:

    - Username: `Admin`
    - Password: `zabbix`

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
