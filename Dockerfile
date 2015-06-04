FROM resin/rpi-raspbian
MAINTAINER abresas@resin.io

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    rsync \
    build-essential \
    dropbear
    
# Install Docker from Docker Inc. repositories.
COPY ./rce /usr/bin/rce
CHMOD u+x /usr/bin/rce
RUN ln -s /usr/bin/rce /usr/bin/docker

# Install the magic wrapper.
ADD ./wraprce /usr/local/bin/wraprce
RUN chmod +x /usr/local/bin/wraprce

ENV DOCKER_HOST unix:///var/run/rce.sock

RUN mkdir /app
COPY ./app1 /app/app1
COPY ./app2 /app/app2
#COPY ./docker-compose.yml /app/docker-compose.yml
WORKDIR /app


# Install Go 1.4.2
RUN mkdir -p /kubernetes/golang \
	&& curl -L http://dave.cheney.net/paste/go1.4.2.linux-arm~multiarch-armv7-1.tar.gz > /kubernetes/go/go1.4.2.tar.gz \
	&& tar -C /usr/local -xzf /kubernetes/go/go1.4.2.tar.gz \
	&& ln -s /usr/local/go/bin/go /usr/bin/go \
	&& ln -s /usr/local/go/bin/godoc /usr/bin/godoc \
	&& ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt \

ENV KUBERNETES_VERSION v0.18.1
RUN cd /kubernetes \
	&& curl -L https://github.com/GoogleCloudPlatform/kubernetes/archive/$KUBERNETES_VERSION.tar.gz \
	&& tar -xzf $KUBERNETES_VERSION.tar.gz
	&& cd kubernetes* \
	&& make
	&& cp ./_output/local/bin/linux/arm/hyperkube /
	&& cp ./_output/local/bin/linux/arm/kubectl /



# Define additional metadata for our image.
VOLUME /var/lib/rce
RUN ln -s /var/lib/rce /var/lib/docker
CMD ["wraprce"]
