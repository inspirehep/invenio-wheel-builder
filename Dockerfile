FROM ubuntu:12.04
MAINTAINER Alessio Deiana "alessio.deiana@cern.ch"


################
# Requirements #
################

RUN apt-get update

# Database
RUN apt-get install -y mariadb-server libmariadbclient-dev

# Webserver
RUN apt-get install -y \
    python-pip redis-server python-dev libssl-dev libxml2-dev libxslt-dev \
    gnuplot clisp automake pstotext gettext
RUN apt-get install -y git
RUN pip install git+https://bitbucket.org/osso/invenio-devserver.git

# System
RUN apt-get install -y unzip wget


###############
# Create user #
###############

RUN useradd --create-home --password docker docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV HOME /home/docker
USER docker


###################
# Install Invenio #
###################

# Preparing Invenio build folder
RUN git clone https://github.com/inveniosoftware/invenio.git /home/docker/invenio
WORKDIR /home/docker/invenio

# Installing Invenio requirements
RUN sudo pip install -r requirements.txt
RUN sudo pip install -r requirements-extras.txt

#################
# Devpi related #
#################

RUN sudo pip install devpi-client
RUN devpi use http://inspireprovisioning.cern.ch/root/inspire --set-cfg
RUN pip freeze > installed_packages.txt
RUN pip wheel --wheel-dir=wheels -r installed_packages.txt
ADD prepare_packages.sh /home/docker/prepare_packages.sh

###########
# Startup #
###########

WORKDIR /home/docker
ENTRYPOINT ["/home/docker/prepare_packages.sh"]
