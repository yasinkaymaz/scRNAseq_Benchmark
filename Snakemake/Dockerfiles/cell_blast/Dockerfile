FROM scrnaseqbenchmark/cell_blast:latest

RUN pip3 --no-cache-dir install Cell-BLAST==0.2.14 && \
    apt-get autoremove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
