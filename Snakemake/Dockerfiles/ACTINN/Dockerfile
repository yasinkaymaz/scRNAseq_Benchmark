FROM scrnaseqbenchmark/baseline:latest

RUN apt-get update && \
    apt-get install --no-install-recommends --yes libhdf5-dev && \
    env HDF5_DIR=/usr/lib/x86_64-linux-gnu/ pip3 --no-cache-dir install tensorflow optunity argparse tables==3.4.4 && \
    rm -rf /var/lib/apt/lists/*

COPY run_ACTINN.py actinn_format.py actinn_predict.py Scripts/
