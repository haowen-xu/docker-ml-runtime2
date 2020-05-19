MAINTAINER Haowen Xu <haowen.xu@outlook.com>

ARG VARIANT=
ARG GPU_LIB_PATH=
ARG TORCH_VERSION=
ARG TORCH_VISION_VERSION=
ARG TENSORFLOW_VERSION=
ARG PIP_DEFAULT_TIMEOUT=120
ARG PIP_MIRROR=

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV SHELL=/bin/bash
ENV RUNTIME_VARIANT=${VARIANT}
ENV LD_LIBRARY_PATH="${GPU_LIB_PATH}:${LD_LIBRARY_PATH}"

# Basic configuration and dependencies
RUN chsh -s /bin/bash && \
    DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    bash -c 'DEBIAN_FRONTEND=noninteractive apt-mark hold cuda* libcudnn* || echo "no gpu"' && \
    DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        locales language-pack-en tzdata ca-certificates lsb-release iputils-ping \
        apt-utils apt-transport-https gnupg dirmngr openssl software-properties-common  \
        tar wget curl ssh git mercurial vim openssh-client psmisc rsync \
        build-essential autoconf libtool \
        libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev \
        libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev \
        libnlopt-dev libpq-dev libffi-dev libcairo-dev libedit-dev \
        libcurl4-nss-dev libsasl2-dev libsasl2-modules libapr1-dev libsvn-dev \
        python3 python3-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install graph-tool
RUN DISTRO="$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -f2 -d'=')" && \
    echo "Ubuntu distro is: ${DISTRO}" && \
    echo "deb http://downloads.skewed.de/apt ${DISTRO} main" >> /etc/apt/sources.list && \
    DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keys.openpgp.org --recv-key 612DEFB798507F25 && \
    DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    apt-get install -y python3-graph-tool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install python packages
RUN ln -s /usr/bin/python3 /usr/local/bin/python && \
    python --version && \
    curl https://bootstrap.pypa.io/get-pip.py -o - | python && \
    python -m pip --version && \
    python -m pip install --no-cache-dir --upgrade setuptools pip six virtualenv && \
    python -m pip config set global.index-url "${PIP_MIRROR}" && \
    python -m pip config list && \
    python -m pip install --no-cache-dir \
        numpy scipy sympy pandas tables scikit-learn matplotlib 'ipython[all]' tqdm \
        seaborn pillow imageio PyYAML sqlalchemy pymongo jinja2 scikit-image scipy progressbar2 mock pep8 coverage \
        mako Flask GitPython tinydb tinydb-serialization hashfs fs opencv-python lmdb gunicorn \
        bokeh dask distributed joblib tensorboardX \
    && \
    python -m pip install --no-cache-dir \
        "tensorflow==${TENSORFLOW_VERSION}" keras \
    && \
    python -m pip install --no-cache-dir \
        "torch==${TORCH_VERSION}" "torchvision==${TORCH_VISION_VERSION}" -f https://download.pytorch.org/whl/torch_stable.html \
    && \
    rm -rf /root/.cache

# Install the entry script
COPY entry.sh /
ENTRYPOINT ["/entry.sh"]
