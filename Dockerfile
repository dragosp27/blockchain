FROM ubuntu:latest

LABEL maintainer="dragos.petre@stud.acs.upb.ro" LABEL_VERSION="0.1"

# Setup the environment
RUN apt -y update && apt-get -y update
RUN apt-get install -y \
    git \
    curl \
    wget \
    python3.10-venv \
    sudo \
    build-essential \
    pkg-config \
    openssl \
    libssl-dev

RUN useradd -m student && \
    echo "student:student" | chpasswd && \
    adduser student sudo

# Clone the needed repositories
WORKDIR /home/student
RUN git clone https://github.com/multiversx/mx-chain-scripts
RUN git clone https://github.com/bogdan124/master-blockchain-v.0.0.1-.git

# Add the needed packages from the net
RUN curl -OL https://go.dev/dl/go1.21.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz && \
    rm -f go1.21.6.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

RUN wget -O mxpy-up.py https://raw.githubusercontent.com/multiversx/mx-sdk-py-cli/main/mxpy-up.py
USER student
RUN printf "y\n" | python3 mxpy-up.py

USER root
RUN cp multiversx-sdk/mxpy /usr/bin && \
    chmod a+rwx /usr/bin/mxpy

# Smart Contract tools
USER student
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="${HOME}/.cargo/bin:${PATH}"
RUN ./.cargo/bin/rustup default nightly
RUN ./.cargo/bin/cargo install multiversx-sc-meta

USER root
RUN git clone https://github.com/multiversx/mx-contracts-rs.git

USER student