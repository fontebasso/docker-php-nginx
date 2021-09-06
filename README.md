# fontebasso/php-nginx

This project is a image docker for run PHP with NGINX and extras bonus.

The goal is to finalize an image ready to run in production, suggestions for improvements and corrections are very welcome, see [how to contribute](CONTRIBUTING.md).

 However, if you identify a security breach, please report it as soon as possible under guidelines outlined in our [SECURITY POLICY](SECURITY.md).

## Getting Started

Use this docker image as a base to run your project, tested on Laravel 8 projects, map your source code to the `/app` directory and build your image as suggested below:

### Step-to-step

#### 1. Your Dockerfile

```Dockerfile
FROM fontebasso/php-nginx:[version]
COPY /src /app
RUN chown -R 82:82 /app
```

> **Important note:**
  we run the command chown -R 82:82 /app to change the user and group owning the files to `www-data`, this avoids permissions issues when running your code.

#### 2. Build a image

```ssh
docker build -t your-app:latest .
```

#### 3. Run application

```ssh
docker run -p 8080:80 -t your-app:latest
```
After `run`, open in your browser `http://localhost:8080` and enjoy!

### Prerequisities

To run this image, only the Docker Engine is needed.

* [Linux](https://docs.docker.com/linux/started/)
* [OS X](https://docs.docker.com/mac/started/)
* [Windows](https://docs.docker.com/windows/started)

#### Volumes

* `/app` - base directory for your application
* `/app/public` - directory exposed to the world

## Built With

* php
* nginx
* imagemagick
* others+

## Find Us

* [GitHub](https://github.com/fontebasso/docker-php-nginx)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Samuel Fontebasso** - *Initial work* - [fontebasso](https://github.com/fontebasso)

See also the list of [contributors](https://github.com/fontebasso/docker-php-nginx/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
