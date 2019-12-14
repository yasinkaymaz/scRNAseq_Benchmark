FROM scrnaseqbenchmark/baseline:latest

RUN pip3 --no-cache-dir install tensorflow optunity && \
    rm -rf /var/lib/apt/lists/*

COPY run_LAmbDA.py Scripts/
