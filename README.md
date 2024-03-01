# Pixelfed Deployment Script

This script is designed to automate the initial deployment of Pixelfed and its related components using Docker and bash scripting.

This is a free-to-use Bash script that allows you to easily install Pixelfed and enhance its security with a single command. You can utilize this script on a blank server or an existing server, making it suitable for both new and experienced Pixelfed server owners.

The script handles the entire Pixelfed installation process, including activating the admin user. It ensures the security of your Pixelfed server by changing the SSH port, installing a firewall, and automatically updating the firewall rules to reflect the new SSH port and installing Fail2Ban with progressive blocking rules.

The Bash file is unencrypted, freely usable, and redistributable (though credit to Honeytree Technologies is required).



## About the Script

- **Language**: Bash
- **Deployment**: Uses Docker images for deploying Pixelfed containers.
- **Configuration**:
  - SSL certificate generation via Let's Encrypt for designated domains and Nginx setup.

## Pre-requisites

- Server or VPS with a minimum of 4GB Ram, 2 vCPU, and 65 GB storage.
- Ubuntu v20.04, v22.04 , v23.04 or v23.10 pre-installed.
- Open ports:  443, 80 and SSH (Which you will choose in the script).
- Machine should have internet access for fetching packages and Docker images.
- Point domain name to the server's IP address (necessary for SSL certification).
- An email delivery service or SMTP server.

## Deployment Steps

1. SSH into the machine and assume root privileges.
2. Create and navigate to a directory: `mkdir auto_script && cd auto_script`.
    You can also use own directory.
3. Run the following command to start the script.
    ```bash
    curl -lO https://code.honeytreetech.com/fediverse/pixelfed/auto-installer/pixelfed_auto_script.sh && sudo chmod +x pixelfed_auto_script.sh && ./pixelfed_auto_script.sh
    ```
4. Input the requested details as per the following table.
    | Name | Description | Mandatory | Optional | Default Value | 
    |------|---------|-----------|----------|---------------|
    | `app_name`|Application name| &checkmark; | &#10006;| &#10006; | 
    |`domain_name` | Domain name| &checkmark;| &#10006;| &#10006;|
    |`mail_driver` | Mail driver| &checkmark;| &#10006;| &#10006;|
    |`mail_host` | Mail host | &checkmark;|  &#10006;| &#10006; | 
    |`mail_port` | Mail port| &checkmark;| &#10006;| &#10006;|
    |`mail_addr` | Mail address| &checkmark;| &#10006;| &#10006;|
    |`mail_name` | Mail name| &checkmark;| &#10006;| &#10006;|
    |`mail_username` | Mail user name| &checkmark;| &#10006;| &#10006;|
    |`mail_password` | Mail password| &checkmark;| &#10006;| &#10006;|
    |`mail_encryption` | Mail encrption| &checkmark;| &#10006;| &#10006;|
    |`db_username` | Database user| &#10006;| &checkmark;|pixelfed |
    |`db_password` | Database Password| &#10006;| &checkmark;|pass_XXXXXXXXX (whereX is Random character) |
    |`db_name` | Database name| &#10006;| &checkmark;|pixel_XXXXXXXXX (whereX is Random character) |
    |`port` | SSH port | &checkmark;| &#10006;| &#10006;|

                                
5. Accept terms of service as prompted.
6. Create Admin user and password during installation of script.
7. Follow further on-screen instructions to complete the setup.

## Post Deployment

- Access Pixelfed via the provided domain with the given admin credentials.
- SSH port defaults to new port (which you entered in the script).
- fail2ban is activated with progressive blocking.

### Updating your Pixelfed application

- It is recommended that you keep your Pixelfed application up to date with new versions, otherwise things may break. You can use the below commands to update your Pixelfed application.

```bash
cd ~/pixelfed  &&  git pull origin dev && docker compose -f compose.yml up -d --build
```
- If you have old automation which is using Elestio/pixelFed:latest docker image. Run below command to update the elestio docker image with github source code
```bash
curl -lO https://code.honeytreetech.com/fediverse/pixelfed/updater/updater.sh && sudo chmod +x updater.sh && ./updater.sh
 ```

## Post-Installation Security Recommendations

Once you have successfully deployed Pixelfed using this script, it's crucial to take additional steps to secure and harden your environment. 

Consider the following actions:

- **Regular Updates**: Ensure that all system packages and software are regularly updated to patch potential vulnerabilities.
- **Firewall Configuration**: Fine-tune your firewall settings to allow only necessary traffic and block potential threats.
- **User Access**: Limit or disable root access. Use sudo for administrative tasks and avoid using the root account for daily tasks.
- **Secure Passwords**: Implement strong password policies, and consider using password managers.
- **Two-Factor Authentication**: Where possible, enable 2FA for critical services and accounts.
- **Backup**: Regularly back up critical data and ensure backups are stored securely.
- **Monitoring & Logging**: Set up monitoring and logging to detect and alert on suspicious activities.
- **Application-Specific Security**: Explore and implement security best practices specifically tailored to Pixelfed and any other applications you might be running.
- **Review and Audit**: Periodically review and audit your security settings and practices to ensure they are up-to-date with the latest threats and vulnerabilities.

It's essential to recognize that the security landscape is dynamic. Stay informed, and be proactive in securing your digital assets.


## Disclaimer
Using the installer is solely at your own risk, and you are responsible for any issues regarding quality, performance, accuracy, and effort. Additionally, support is only available to managed services clients of [Honeytree Technologies, LLC](https://honeytreetech.com); no free support is provided.

## CREDITS

This script and deployment guide have been made possible by [Honeytree Technologies, LLC](https://honeytreetech.com).

Please follow [@jeff@honeytree.social](https://honeytree.social/@jeff).
