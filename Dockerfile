FROM tensorflow/tensorflow:1.15.2-gpu-py3
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

RUN apt-get update && \
    apt-get install git apt-utils python3-venv -y
RUN python -m venv /ve
RUN /ve/bin/pip --no-cache-dir install setuptools --upgrade 
RUN /ve/bin/pip install --upgrade pip

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev

RUN git clone https://github.com/anoidgit/yasa.git
RUN apt-get install libboost-dev -y
RUN cd yasa && \
    /bin/sh configure CFLAGS='-O2 -Wno-deprecated-declarations -fpermissive' CXXFLAGS='-Wno-deprecated-declarations -fpermissive' && \
    make && \
    make install
#RUN pip install OpenNMT-tf
#RUN pip install youtokentome
RUN apt-get install libcurl4-openssl-dev libssl-dev -y
RUN /ve/bin/pip install --upgrade \
        six==1.12.0 \
        pyyaml \
        colorama \
        click \
        numpy==1.18.5\
        scipy \
        pandas \
        sklearn \
        ipykernel \
        jupyter \
        matplotlib \
        seaborn \
        tqdm \
        requests \
        pycurl \
        subword-nmt


# RUN apt-get install  python3-dev python3-numpy-dev -y
##        && \
##    python3 -m ipykernel.kernelspec

RUN apt-get install supervisor -y
#CLEANUP
RUN apt-get autoremove -y && \
apt-get clean
#rm -rf /usr/local/src/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /root/.jupyter
RUN mkdir /data
RUN echo c.NotebookApp.ip = \'0.0.0.0\' > /root/.jupyter/jupyter_notebook_config.py
ENV PYTHONPATH "${PYTHONPATH}:/root/.local/bin"
ADD /start-jupyter.sh /
WORKDIR /notebooks

CMD ["/usr/bin/supervisord"]
