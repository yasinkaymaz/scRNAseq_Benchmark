FROM debian:9.9-slim

# Install newest R version
RUN apt-get update && \
    apt-get install --no-install-recommends --yes wget gnupg apt-transport-https && \
    wget -qO - http://keys.gnupg.net/pks/lookup?op=get\&search=0xAD5F960A256A04AF | apt-key add - && \
    echo 'deb http://cloud.r-project.org/bin/linux/debian stretch-cran35/' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends --yes r-base && \
    apt-get purge --yes wget gnupg apt-transport-https && \
    apt-get autoremove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY run_HieRFIT.R \
     install_packages.R \
     /Scripts/

RUN apt-get update && \
    apt-get install --no-install-recommends --yes make gcc g++ r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev libxml2 && \
    Rscript --vanilla /Scripts/install_packages.R && \
    apt-get purge --yes make gcc g++ r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev && \
    apt-get autoremove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "devtools::install_github('yasinkaymaz/HieRFIT')"
