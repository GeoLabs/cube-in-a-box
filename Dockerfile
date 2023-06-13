FROM osgeo/gdal:ubuntu-small-3.3.1

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    TINI_VERSION=v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      # For Psycopg2
      libpq-dev python3-dev \
      python3-pip \
      wget \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

COPY requirements.txt /conf/
COPY products.csv /conf/
RUN pip3 install --no-cache-dir --requirement /conf/requirements.txt\
    && sed "s:from odc.aws.queue import publish_to_topic:#from odc.aws.queue import publish_to_topic:g" -i /usr/local/lib/python3.10/dist-packages/odc/apps/dc_tools/utils.py 

WORKDIR /notebooks

ENTRYPOINT ["/tini", "--"]

CMD ["jupyter", "notebook", "--allow-root", "--ip='0.0.0.0'", "--NotebookApp.token='secretpassword'"]
