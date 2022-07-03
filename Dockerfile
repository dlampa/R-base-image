FROM ubuntu:20.04

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8 
ENV R_BASE_VERSION 4.2.1
ENV DEBIAN_FRONTEND noninteractive

# Add user 'runr' and assign it to group 'staff' to allow writing to the /usr/lib/R/site-library directory 
# Update the image and install base packages required for installation
# Configure default locale, see https://github.com/rocker-org/rocker/issues/19
# Install R from CRAN apt repository
# Install littler to assist with scripting
# Set default CRAN package repository

RUN useradd runr -g staff -d /home/runr -m\
    && echo "Updating image and Installing base packages" \
    && apt-get update \
    && apt-get upgrade -yqq \
	&& apt-get install -yqq --no-install-recommends \
	    apt-utils \
		less \
		locales \
		wget \
		ca-certificates \
		apt-transport-https \
		gsfonts \
		gnupg2 \
        curl \
    && echo "Configuring locale en_US.utf8" \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && echo "Installing R" \
    && echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" > /etc/apt/sources.list.d/cran.list \
    && add-apt-repository ppa:c2d4u.team/c2d4u4.0+ \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && apt-get update \
	&& apt-get install -y --no-install-recommends \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}* \
                r-base-core=${R_BASE_VERSION}* \
		r-base-dev=${R_BASE_VERSION}* \
		r-recommended=${R_BASE_VERSION}* \
    && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
	&& ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
    && apt-get -yqq autoremove --purge \
    && apt-get clean \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/* 

VOLUME /scripts

CMD ["R"]