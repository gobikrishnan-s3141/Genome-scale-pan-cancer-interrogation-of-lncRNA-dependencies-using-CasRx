# r-ver image from rocker [debian based R-image by rocker community]
FROM rocker/r-ver:4.6.1

# avoids prompting during installation
ARG DEBIAN_FRONTEND=noninteractive

# install system dep
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential\
	cmake \
	gfortran \
	git \
	libomp-dev \
	curl \
	libopenblas-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	libxml2-dev \
	libcairo2-dev \
	libxt-dev \
	libfontconfig1-dev \
	libharfbuzz-dev \
	libfribidi-dev \
	libfreetype6-dev \
	libpng-dev \
	libtiff5-dev \
	libjpeg-dev \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=mambaorg/micromamba:2.0.5 /bin/micromamba /usr/local/bin/micromamba
RUN micromamba create -y -p /opt/tools -c conda-forge -c bioconda \
        mageck=0.5.9.4 bowtie=1.2.2 bowtie2=2.3.5.1 trimmomatic=0.38 samtools viennarna \
        && micromamba clean -afy \
        && ln -s /opt/tools/bin/RNAfold /usr/local/bin/RNAfold \
        && ln -s /opt/tools/bin/RNAplfold /usr/local/bin/RNAplfold
ENV PATH="${PATH}:/opt/tools/bin"

RUN useradd -m -s /bin/bash rmonk
# restore renv.lock file
ENV RENV_PATHS_LIBRARY=/opt/renv/library \
        RENV_CONFIG_REPOS_OVERRIDE=https://p3m.dev/cran/__linux__/noble/latest

WORKDIR /home/rmonk/analysis
RUN chown rmonk:rmonk /home/rmonk/analysis
COPY . . 
RUN R -e "install.packages('renv')" && R -e "renv::restore(prompt=F)"
# install R pkgs for your project / use renv / {rix}
#RUN R -e "install.packages('pak', repos ='https://cloud.r-project.org/')"

#RUN R -e "pak::pkg_install(c('doParallel','foreach','tidyverse', 'data.table'))"

USER rmonk
CMD ["R"]
