# 1. Install Julia
FROM julia:1.10

# Set the working directory
WORKDIR /app

# Install Python build dependencies and pyenv
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libffi-dev \
    liblzma-dev \
    curl \
    git \
    opam \
    build-essential \
    libgmp-dev \
    pkg-config \
    ocamlbuild \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN curl https://pyenv.run | bash

# Add pyenv to PATH and set up environment
ENV PATH="/root/.pyenv/bin:$PATH"
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init --path)"' >> ~/.bashrc

# Install Python 3.10 via pyenv
RUN eval "$(pyenv init -)" && pyenv install 3.10.12 && pyenv global 3.10.12

# Create symlink for convenience and ensure PATH is correct
RUN ln -sf /root/.pyenv/versions/3.10.12/bin/python3.10 /usr/local/bin/python
RUN ln -sf /root/.pyenv/versions/3.10.12/bin/python3.10 /usr/local/bin/python3
RUN ln -sf /root/.pyenv/versions/3.10.12/bin/pip /usr/local/bin/pip3
ENV PATH="/root/.pyenv/versions/3.10.12/bin:$PATH"

# Initialize opam and install Coq
RUN opam init --disable-sandboxing -y
RUN opam switch create 4.10.0+afl -y
RUN eval $(opam env) && opam repo add coq-released https://coq.inria.fr/opam/released
RUN eval $(opam env) && opam update
RUN eval $(opam env) && opam pin coq 8.15.0 -y

COPY lib/ ./lib/

# Build and install QuickChick from source
# TODO_ARTIFACT: the below errors for me
RUN eval $(opam env) && cd lib/QuickChick && opam install . --deps-only -y
RUN eval $(opam env) && cd lib/QuickChick && make clean
RUN eval $(opam env) && cd lib/QuickChick && make
RUN eval $(opam env) && cd lib/QuickChick && make install

# Set up opam environment in .bashrc
RUN echo 'eval $(opam env)' >> /root/.bashrc

# Copy Python requirements and install packages
COPY requirements.txt .
RUN /root/.pyenv/versions/3.10.12/bin/python3.10 -m venv /venv
ENV VIRTUAL_ENV=/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install pandas==1.5.3 numpy==1.22.4 scipy==1.10.1 seaborn dash 
RUN pip install -r lib/etna/tool/requirements.txt
RUN cd lib/etna/tool && pip install -e .
RUN echo 'source /venv/bin/activate' >> /root/.bashrc

# Copy Julia project files
COPY lib/project-for-artifact/Project.toml ./

# Copy local Julia packages and QuickChick

# Install Julia packages
RUN julia --project -e 'using Pkg; Pkg.instantiate()'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/IRTools.jl")'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/CUDD.jl")'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/Dice.jl")'

# Install Coq QuickChick (from lib/QuickChick, run `make install`)

# Copy the rest of the application
COPY . .

# Set a default command (optional)
# CMD ["julia"]

