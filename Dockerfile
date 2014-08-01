FROM ubuntu:12.04
MAINTAINER Alessio Deiana "alessio.deiana@cern.ch"


################
# Requirements #
################

RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y apt-utils

RUN apt-get install -y git unzip wget \
    python-pip redis-server python-dev libssl-dev libxml2-dev libxslt-dev \
    gnuplot clisp automake pstotext gettext mysql-server libmysqlclient-dev

RUN apt-get install -y cython

###############
# Create user #
###############

RUN useradd --create-home --password docker docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


###################
# Install Invenio #
###################

# Preparing Invenio build folder
RUN git clone https://github.com/inveniosoftware/invenio.git /home/docker/invenio
WORKDIR /home/docker/invenio

# Installing Invenio requirements
RUN pip install -r requirements.txt
RUN pip install -r requirements-extras.txt

#################
# Devpi related #
#################

RUN pip install devpi-client
RUN devpi use http://inspireprovisioning.cern.ch/root/inspire --set-cfg
RUN pip freeze > installed_packages.txt
RUN pip wheel --wheel-dir=wheels -r installed_packages.txt
ADD prepare_packages.sh /home/docker/prepare_packages.sh

###########
# Startup #
###########

WORKDIR /home/docker
ENTRYPOINT ["/home/docker/prepare_packages.sh"]
