# fontebasso/php-nginx

[![Docker Build](https://github.com/fontebasso/docker-php-nginx/workflows/docker/badge.svg)](https://github.com/fontebasso/docker-php-nginx/actions?query=workflow%3Adocker)
[![Docker Pulls](https://img.shields.io/docker/pulls/fontebasso/php-nginx)](https://hub.docker.com/r/fontebasso/php-nginx)
[![Signed with Sigstore](https://img.shields.io/badge/sigstore-signed-blue?logo=sigstore)](https://www.sigstore.dev)
[![SLSA Provenance](https://img.shields.io/badge/provenance-SLSA%20attested-green)](https://slsa.dev)
[![GitHub License](https://img.shields.io/github/license/fontebasso/docker-php-nginx)](https://github.com/fontebasso/docker-php-nginx/blob/main/LICENSE)

This repository contains a Docker image for running high-performance PHP web applications. It is optimized for speed, efficiency, and includes a comprehensive set of tools and libraries commonly used in web development.

> If you identify a security breach, please report it as soon as possible under the guidelines outlined in our [security policy](SECURITY.md).

## Features

- **Alpine Linux 3.20:** Minimal base for better security and smaller footprint.
- **PHP 8.3:** Modern version with performance improvements and extended support timeline.
- **Nginx:** Fast and reliable web server.
- **Runit:** Lightweight init system for process supervision.
- **Multi-arch builds:** Supports linux/amd64 and linux/arm64.

## Supply Chain Security

This image is:

- ✅ Signed with [Sigstore Cosign](https://docs.sigstore.dev)
- ✅ Provenance generated in the [SLSA v0.2](https://slsa.dev/spec/v0.2/provenance)
- ✅ Compatible with verification using `cosign verify` and `cosign verify-attestation`

To verify the image and its provenance (example):

```bash
cosign verify \
  --certificate-identity-regexp "github.com/fontebasso/.+" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  docker.io/fontebasso/php-nginx@sha256:03c339da2342dd29c04a4c20da486150efc38f93a3aaf675fdf7a08899d8cb56
```

```bash
cosign verify-attestation \
  --type=https://slsa.dev/provenance/v0.2 \
  --certificate-identity-regexp "github.com/slsa-framework/.+" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  docker.io/fontebasso/php-nginx@sha256:03c339da2342dd29c04a4c20da486150efc38f93a3aaf675fdf7a08899d8cb56
```

No manual setup or keys required — Cosign uses GitHub Actions identity.

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

This will expose Nginx on port 8080 of your local machine.

### Custom Configuration

You can customize the PHP configuration by editing the custom_params.ini file and copying it to the appropriate directory:

```dockerfile
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-03-custom-params.ini
```

### Directory Structure

- `/app`: The application code.
- `/env`: Environment variables directory.
- `/var/log/nginx`: Nginx logs.
- `/etc/service`: Runit service definitions.

## Development

To build the Docker image locally, clone this repository and run:

```bash
git clone https://github.com/fontebasso/docker-php-nginx.git
cd docker-php-nginx
docker build -t fontebasso/php-nginx:latest .
```

### Building for Multiple Architectures

This repository is configured to build for:

- `linux/amd64`
- `linux/arm64`

Via GitHub Actions with provenance and public signing.

### Contributing

Pull requests are welcome! Please fork the repository and submit your improvements.

We follow standard open-source contribution guidelines, and are happy to receive help improving this project.

## Maintainers

- [Samuel Fontebasso](https://github.com/fontebasso)

## Contact

For questions or support, please open an [issue](https://github.com/fontebasso/docker-php-nginx/issues) or contact the maintainers.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
