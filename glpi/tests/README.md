<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# GLPI, verified and packaged by Elestio

[GLPI](https://glpi-project.org/) is the most complete open source service management software.

<img src="https://github.com/elestio-examples/glpi/raw/main/glpi.png" alt="glpi" width="800">

Deploy a <a target="_blank" href="https://elest.io/open-source/glpi">fully managed GLPI</a> on <a target="_blank" href="https://elest.io/">elest.io</a> if you want automated backups, reverse proxy with SSL termination, firewall, automated OS & Software updates, and a team of Linux experts and open source enthusiasts to ensure your services are always safe, and functional.

[![deploy](https://github.com/elestio-examples/glpi/raw/main/deploy-on-elestio.png)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/glpi)

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/glpi.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.

Run the project with the following command

    docker-compose up -d

You can access the Web UI at: `http://your-domain:22571`

## Docker-compose

Here are some example snippets to help you get started creating a container.

    version: "3.3"

    services:
        mysql:
            image: elestio/mysql:8.0
            restart: always
            hostname: mysql
            volumes:
                - ./storage/mysql:/var/lib/mysql
            env_file:
                - ./.env
            ports:
                - "172.17.0.1:50778:3306"

        glpi:
            image: elestio4test/glpi:latest
            restart: always
            hostname: glpi
            ports:
                - "172.17.0.1:22571:80"
            volumes:
                - /etc/timezone:/etc/timezone:ro
                - /etc/localtime:/etc/localtime:ro
                - ./storage/var/www/html/glpi/:/var/www/html/glpi
            environment:
                - TIMEZONE=Europe/Brussels

        pma:
            image: phpmyadmin
            restart: always
            links:
                - mysql:mysql
            ports:
                - "172.17.0.1:22811:80"
            environment:
              PMA_HOST: mysql
              PMA_PORT: 3306
              PMA_USER: root
              PMA_PASSWORD: ${ADMIN_PASSWORD}
              UPLOAD_LIMIT: 500M
              MYSQL_USERNAME: glpi
              MYSQL_ROOT_PASSWORD: ${ADMIN_PASSWORD}
            depends_on:
                - mysql

### Environment variables

|      Variable       | Value (example) |
| :-----------------: | :-------------: |
|     ADMIN_EMAIL     | admin@email.com |
|   ADMIN_PASSWORD    |  your-password  |
|       DOMAIN        | your.domain.com |
| MYSQL_ROOT_PASSWORD |  your-password  |
|   MYSQL_DATABASE    |     glpidb      |
|     MYSQL_USER      |      glpi       |
|   MYSQL_PASSWORD    |  your-password  |

# Maintenance

## Logging

The Elestio GLPI Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://github.com/glpi-project/glpi">GLPI Github repository</a>

- <a target="_blank" href="https://glpi-project.org/documentation/">GLPI documentation</a>

- <a target="_blank" href="https://github.com/elestio-examples/glpi">Elestio/glpi Github repository</a>
