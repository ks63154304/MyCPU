# Building Stage
FROM ubuntu:22.04 AS stage_building
ARG RISCV_GNU_DEP="wget curl make autoconf automake autotools-dev python3 python3-pip \
  libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
  libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git libglib2.0-dev"

ARG SAIL_DEP="opam build-essential libgmp-dev z3 pkg-config zlib1g-dev"

RUN apt update && apt -y install ${RISCV_GNU_DEP} ${SAIL_DEP}

# riscv-gnu-toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain && \
    cd riscv-gnu-toolchain && \
    ./configure --prefix=/usr/local/riscv --enable-multilib --with-arch=rv32gc --with-abi=ilp32d && \
    make -j `nproc` && \
    make install

# SAIL C-emulator
RUN opam init -y --disable-sandboxing && \
    opam switch create ocaml-base-compiler.4.08.1 && \
    opam install sail -y && \
    eval $(opam config env) && \
    git clone https://github.com/riscv/sail-riscv.git /usr/local/sail-riscv && \
    cd /usr/local/sail-riscv && \
    ARCH=RV32 make -j `nproc`

# Final Stage
FROM ubuntu:22.04 AS stage_final

# copy tools built in last stage to final stage
COPY --from=stage_building /usr/local/riscv /usr/local/riscv
COPY --from=stage_building /usr/local/sail-riscv /usr/local/sail-riscv

# set PATH to include RISC-V GNU Toolchain and SAIL C-emulator
ENV PATH="$PATH:/usr/local/riscv/bin"
ENV PATH="$PATH:/usr/local/sail-riscv/c_emulator"

# zip and unzip are required for the sdkman to be installed from script
RUN \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        verilator \
        curl \
        zip \ 
        unzip \
        sudo \
        git \
        python3 \
        python3-pip \
        && \
    rm -rf /var/lib/apt/lists/*

# this SHELL command is needed to allow `source` to work properly
# reference: https://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work/45087082#45087082
SHELL ["/bin/bash", "-c"] 

# add a user whose uid and gid are same as the master user
ARG UID GID NAME=user
RUN groupadd -g $GID -o $NAME
RUN useradd -u $UID -m -g $NAME -G plugdev $NAME && \
    echo "$NAME ALL = NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user
RUN chown -R $NAME:$NAME /home/$NAME
USER $NAME

# reference: https://sdkman.io/install
RUN curl -s "https://get.sdkman.io" | bash 

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && \
    sdk install java $(sdk list java | grep -o "\b8\.[0-9]*\.[0-9]*\-tem" | head -1) && \
    sdk install sbt

# install riscof and riscv-arch-test
RUN pip3 install --upgrade pip && \
    pip3 install riscof 
ENV PATH="$PATH:/home/user/.local/bin"

WORKDIR "/home/user/workspace"

ENTRYPOINT ["/bin/bash"]
