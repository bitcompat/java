# Java

## What is Java?

> Java is a general-purpose computer programming language that is concurrent, class-based, object-oriented, and specifically designed to have as few implementation dependencies as possible.

[Overview of Java](https://openjdk.java.net/)

Trademarks: The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

## TL;DR

```console
$ docker run -it --name java ghcr.io/bitcompat/java
```

## Get this image

The recommended way to get the Bitcompat Java Docker Image is to pull the prebuilt image from the [AWS Public ECR Gallery](https://gallery.ecr.aws/bitcompat/java) or from the [GitHub Container Registry](https://github.com/bitcompat/java/pkgs/container/java)

```console
$ docker pull ghcr.io/bitcompat/java:latest
```

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://github.com/bitcompat/java/pkgs/container/java/versions) in the GitHub Registry or the [available tags](https://gallery.ecr.aws/bitcompat/java) in the public ECR gallery.

```console
$ docker pull ghcr.io/bitcompat/java:[TAG]
```

## Configuration

### Running your Java jar or war

The default work directory for the Java image is `/app`. You can mount a folder from your host here that includes your Java jar or war, and run it normally using the `java` command.

```console
$ docker run -it --name java -v /path/to/app:/app ghcr.io/bitcompat/java:latest \
  java -jar package.jar
```

or using Docker Compose:

```yaml
java:
  image: ghcr.io/bitcompat/java:latest
  command: "java -jar package.jar"
  volumes:
    - .:/app
```

**Further Reading:**

- [Java SE Documentation](https://docs.oracle.com/javase/8/docs/api/)

## Replace the default truststore using a custom base image

In case you are replacing the default [minideb](https://github.com/bitnami/minideb) base image with a custom base image (based on Debian), it is possible to replace the default truststore located in the `/opt/bitnami/java/lib/security` folder. This is done by setting the `JAVA_EXTRA_SECURITY_DIR` docker build ARG variable, which needs to point to a location that contains a *cacerts* file that would substitute the originally bundled truststore. In the following example we will use a minideb fork that contains a custom *cacerts* file in the */bitnami/java/extra-security* folder:

- In the Dockerfile, replace `FROM docker.io/bitnami/minideb:latest` to use a custom image, defined with the `MYJAVAFORK:TAG` placeholder:

```diff
- FROM bitnami/minideb:latest
+ FROM MYFORK:TAG
```

- Run `docker build` setting the value of `JAVA_EXTRA_SECURITY_DIR`. Remember to replace the `MYJAVAFORK:TAG` placeholder.

```
docker build --build-arg JAVA_EXTRA_SECURITY_DIR=/bitnami/java/extra-security -t MYJAVAFORK:TAG .
```

## Maintenance

### Upgrade this image

Bitcompat provides up-to-date versions of Java, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container.

#### Step 1: Get the updated image

```console
$ docker pull ghcr.io/bitcompat/java:latest
```

or if you're using Docker Compose, update the value of the image property to `ghcr.io/bitcompat/java:latest`.

#### Step 2: Remove the currently running container

```console
$ docker rm -v java
```

or using Docker Compose:

```console
$ docker-compose rm -v java
```

#### Step 3: Run the new image

Re-create your container from the new image.

```console
$ docker run --name java ghcr.io/bitcompat/java:latest
```

or using Docker Compose:

```console
$ docker-compose up java
```

## Contributing

We'd love for you to contribute to this Docker image. You can request new features by creating an [issue](https://github.com/bitcompat/java/issues) or submitting a [pull request](https://github.com/bitcompat/java/pulls) with your contribution.

## Issues

If you encountered a problem running this container, you can file an [issue](https://github.com/bitcompat/java/issues/new).

## License

This package is released under MIT license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
