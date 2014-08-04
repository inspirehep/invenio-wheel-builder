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
    gnuplot clisp automake pstotext gettext mysql-server libmysqlclient-dev \
    cython libhdf5-serial-dev

###############
# Create user #
###############

RUN useradd --create-home --password docker docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


###################
# Install Invenio #
###################

# Preparing Invenio build folder
RUN git clone https://github.com/inspirehep/invenio.git -b prod /home/docker/invenio
WORKDIR /home/docker/invenio

# Installing Invenio requirements
RUN pip install -r requirements.txt
RUN pip install -r requirements-extras.txt

#################
# Devpi related #
#################

RUN pip install devpi-client wheel
RUN pip install -U pip setuptools
RUN pip freeze | grep -iv pyrxp | grep -iv pychecker | grep -iv winpdb > installed_packages.txt
RUN cat installed_packages.txt
RUN mkdir packages
RUN pip install --allow-unverified gnuplot-py \
                --allow-all-external \
                --download=packages -r installed_packages.txt
RUN pip wheel --allow-external gnuplot-py --allow-unverified gnuplot-py \
              --download-cache=packages \
              --wheel-dir=wheels -r installed_packages.txt
RUN devpi use http://inspireprovisioning.cern.ch/root/inspire --set-cfg
ADD upload_packages.sh /home/docker/upload_packages.sh

###########
# Startup #
###########

WORKDIR /home/docker
