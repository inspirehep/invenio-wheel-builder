FROM cern/slc6-base
MAINTAINER Alessio Deiana "alessio.deiana@cern.ch"


################
# Requirements #
################

RUN yum install -y git unzip wget \
    python-pip python-devel openssl-devel hdf5-devel automake \
    gettext-devel gcc mysql python-ipython python-virtualenvwrapper \
    sbcl freetype-devel libxslt-devel libxml2-devel gnuplot gnuplot-py \
    mod_xsendfile arc afs_tools perl-DBI screen postfix lwp \
    colordiff perl-TermReadKey GraphicsMagick gcc-c++ ksh \
    mysql-devel python27 Cython

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

WORKDIR /home/docker

RUN pip freeze | grep -iv pyrxp | grep -iv pychecker | grep -iv winpdb | grep -iv matplotlib > installed_packages.txt
RUN cat installed_packages.txt
RUN mkdir packages
RUN pip install --allow-unverified gnuplot-py \
                --allow-all-external \
                --download=packages -r installed_packages.txt
RUN pip wheel --allow-external gnuplot-py --allow-unverified gnuplot-py \
              --download-cache=packages \
              --wheel-dir=wheels -r installed_packages.txt
RUN devpi use http://inspireprovisioning.cern.ch/root/inspire --set-cfg
ADD ../upload_packages.sh /home/docker/upload_packages.sh

###########
# Startup #
###########

