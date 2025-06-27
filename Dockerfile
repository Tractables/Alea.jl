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

# Add pyenv to PATH
ENV PATH="/root/.pyenv/bin:$PATH"
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Install Python 3.10 via pyenv
RUN eval "$(pyenv init -)" && pyenv install 3.10.12 && pyenv global 3.10.12

# Create symlink for convenience
RUN ln -sf /root/.pyenv/versions/3.10.12/bin/python3.10 /usr/local/bin/python

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
RUN python3 -m venv /venv && . /venv/bin/activate
ENV VIRTUAL_ENV=/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install matplotlib==3.10.3 pandas==2.2.3 pillow==11.2.1 contourpy==1.3.2 cycler==0.12.1 fonttools==4.58.0 kiwisolver==1.4.8 packaging==25.0 pyparsing==3.2.3 python-dateutil==2.9.0.post0 pytz==2025.2 six==1.17.0 tzdata==2025.2
RUN pip install -r lib/etna/tool/requirements.txt
RUN cd lib/etna/tool && pip install -e .

# # Copy Julia project files
# COPY lib/project-for-artifact/Project.toml ./

# # Copy local Julia packages and QuickChick

# # Install Julia packages
# RUN julia --project -e 'using Pkg; Pkg.instantiate()'
# RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/IRTools.jl")'
# RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/CUDD.jl")'
# RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/Dice.jl")'

# Install Coq QuickChick (from lib/QuickChick, run `make install`)

# Copy the rest of the application
COPY . .

# Set a default command (optional)
# CMD ["julia"]

