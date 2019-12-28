FROM r-base:3.6.0

COPY install_packages.R \
     /Scripts/

# Install R packages
RUN apt-get update && \
    apt-get install --no-install-recommends --yes make gcc g++ libxml2-dev zlib1g-dev gfortran liblapack-dev libcurl4-gnutls-dev libssl-dev && \
    Rscript --vanilla /Scripts/install_packages.R && \
    apt-get purge --yes make gcc g++ zlib1g-dev gfortran liblapack-dev libcurl4-gnutls-dev libssl-dev && \
    apt-get autoremove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
