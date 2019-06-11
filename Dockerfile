FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONIOENCODING=UTF-8
ENV PYTHONNOUSERSITE="True"
ENV CONDA_ENV_PATH /root/miniconda3/bin
ENV GPU_CONDA_ENV "gpu_env_py37"
ENV CPU_CONDA_ENV "cpu_env_py37"
ENV PYTHON_VERSION 3.7
ENV OPEN_CV_VERSION 4.1.0
ENV TENSORFLOW_VERSION 1.13.1
ENV TENSORFLOW_BRANCH r1.13

# Change sh to bash
RUN ln -sf /bin/bash /bin/sh

# Install miniconda3
RUN apt-get update -y && apt-get install -y --no-install-recommends wget bzip2 curl && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x Miniconda3-latest-Linux-x86_64.sh && \
    ./Miniconda3-latest-Linux-x86_64.sh -b && \
    rm -f ./Miniconda3-latest-Linux-x86_64.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create virtualenv
RUN ${CONDA_ENV_PATH}/conda update -n base conda && \
    ${CONDA_ENV_PATH}/conda create -n $GPU_CONDA_ENV python=${PYTHON_VERSION} && \
    ${CONDA_ENV_PATH}/conda create -n $CPU_CONDA_ENV python=${PYTHON_VERSION}

# This is how you will activate this conda environment
ENV CONDA_ACTIVATE_GPU "source ${CONDA_ENV_PATH}/activate ${GPU_CONDA_ENV}"
ENV CONDA_ACTIVATE_CPU "source ${CONDA_ENV_PATH}/activate ${CPU_CONDA_ENV}"

# Install APT packages
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    pkg-config zip g++ zlib1g-dev unzip \
    openjdk-8-jdk \
    python3-dev python3-pip python3-numpy\
    python-dev python-numpy \
    apt-utils \
    build-essential cmake ninja-build git\
    libjpeg-dev libtiff-dev  libpng-dev libavcodec-dev\
    libavformat-dev libswscale-dev libv4l-dev\
    libgtk2.0-dev libatlas-base-dev gfortran\
    libtbb2 libtbb-dev\
    libdc1394-22-dev libxvidcore-dev libx264-dev\
    libgtk-3-dev libboost-all-dev swig graphviz libgtest-dev\
    doxygen clang qtdeclarative5-dev g++-multilib\
    gcc-multilib texlive-latex-base\
    texlive-fonts-recommended libboost-all-dev netcdf-bin\
    libnetcdf-dev libtool-bin automake ccache\
    qtcreator clang-format

RUN wget https://github.com/bazelbuild/bazel/releases/download/0.21.0/bazel-0.21.0-installer-linux-x86_64.sh && \
    sh bazel-0.21.0-installer-linux-x86_64.sh

# Build OpenCV
RUN mkdir /cv && cd /cv &&\
    git clone --depth 1 https://github.com/opencv/opencv_contrib.git -b ${OPEN_CV_VERSION} &&\
    git clone --depth 1 https://github.com/opencv/opencv.git -b ${OPEN_CV_VERSION} &&\
    cd opencv &&\
    mkdir build &&\
    cd build &&\
    cmake -G "Ninja"\
    -D CMAKE_BUILD_TYPE=RELEASE\
    -D CMAKE_INSTALL_PREFIX=/usr/local\
    -D INSTALL_C_EXAMPLES=OFF\
    -D INSTALL_PYTHON_EXAMPLES=OFF\
    -D OPENCV_EXTRA_MODULES_PATH=/cv/opencv_contrib/modules\
    -D BUILD_opencv_legacy=OFF\
    -D BUILD_EXAMPLES=OFF\
    -D WITH_CUDA=OFF\
    -D ENABLE_AVX=ON\
    -D WITH_OPENGL=ON\
    -D WITH_TIFF=ON\
    -D BUILD_TIFF=ON .. &&\
    ninja
