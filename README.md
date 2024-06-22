# fontebasso/php-nginx

[![Docker Build](https://github.com/fontebasso/docker-php-nginx/workflows/docker/badge.svg)](https://github.com/fontebasso/docker-php-nginx/actions?query=workflow%3Adocker)
[![Docker Pulls](https://img.shields.io/docker/pulls/fontebasso/php-nginx)](https://hub.docker.com/r/fontebasso/php-nginx)
[![GitHub Repo](https://img.shields.io/badge/github-repo-yellowgreen)](https://github.com/fontebasso/docker-php-nginx)
[![GitHub License](https://img.shields.io/github/license/fontebasso/docker-php-nginx)](https://github.com/fontebasso/docker-php-nginx/blob/main/LICENSE)

This repository contains a Docker image for running high-performance PHP web applications. It is optimized for speed, efficiency, and includes a comprehensive set of tools and libraries commonly used in web development.

> This image is ready to run in production, suggestions for improvements and corrections are very welcome, see [how to contribute](CONTRIBUTING.md).

> If you identify a security breach, please report it as soon as possible under guidelines outlined in our [security policy](SECURITY.md).

## Features

- **PHP 8.2**: The image uses PHP 8.2, which is optimized for performance and includes numerous features and improvements.
- **Alpine Linux 3.16**: A minimal Docker image based on Alpine Linux for security and reduced image size.
- **Nginx**: Fast and reliable web server.
- **Essential PHP Extensions**: Including `bcmath`, `bz2`, `calendar`, `exif`, `gd`, `opcache`, `pdo_mysql`, `shmop`, `sockets`, `sysvmsg`, `sysvsem`, `sysvshm`, `pcntl`, `zip`, and `imagick`.
- **Pre-installed Libraries**: `git`, `bzip2-dev`, `freetype-dev`, `icu-dev`, `imagemagick`, `jpeg-dev`, `libpng-dev`, `libressl-dev`, `libxml2-dev`, `libzip-dev`, `oniguruma-dev` and more.
- **Runit**: Lightweight and easy-to-use init system.

## Getting Started

### Prerequisites

- Docker installed on your machine.
- Docker Hub account for pulling the image.

### Pulling the Image

To pull the image from Docker Hub, run:

```bash
docker pull fontebasso/php-nginx:latest
```
### Running the Container

To run a container using this image, execute:

```bash
docker run -d -p 8080:80 fontebasso/php-nginx:latest
```

This command will start a container and map port 8080 on your local machine to port 80 on the container.

### Custom Configuration

You can customize the PHP configuration by editing the custom_params.ini file and copying it to the appropriate directory:

```dockerfile
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-02-custom-params.ini
```

### Directory Structure

- `/app`: The application code.
- `/env`: Environment variables directory.
- `/var/log/nginx`: Nginx logs.
- `/etc/service`: Service definitions for `runit`.

## Development

To build the Docker image locally, clone this repository and run:

```bash
git clone https://github.com/fontebasso/docker-php-nginx.git
cd docker-php-nginx
docker build -t fontebasso/php-nginx:latest .
```

### Building for Multiple Architectures

This repository is configured to build for multiple architectures using GitHub Actions. Supported architectures:

- `linux/amd64`
- `linux/arm64`

### Contributing

Contributions are welcome! Please fork this repository and submit a pull request with your changes.

## Maintainers

- [Samuel Fontebasso](https://github.com/fontebasso)

## Contact

For questions or support, please open an [issue](https://github.com/fontebasso/docker-php-nginx/issues) or contact the maintainers.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
