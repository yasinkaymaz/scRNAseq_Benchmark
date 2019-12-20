FROM scrnaseqbenchmark/baseline:latest

RUN apt-get update && \
    pip3 --no-cache-dir install plotly==2.7 moana && \
    rm -rf /var/lib/apt/lists/*

COPY run_moana.py Scripts/
