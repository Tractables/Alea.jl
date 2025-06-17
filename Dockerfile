# 1. Install Julia
FROM julia:1.10

# Set the working directory
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Install opam and other dependencies
RUN apt-get install -y opam build-essential libgmp-dev pkg-config ocamlbuild

# Initialize opam and install Coq
RUN opam init --disable-sandboxing -y
RUN opam switch create 4.10.0+afl -y
RUN eval $(opam env) && opam repo add coq-released https://coq.inria.fr/opam/released
RUN eval $(opam env) && opam update
RUN eval $(opam env) && opam install -y ocamlbuild cppo.1.6.9 coq-mathcomp-ssreflect.1.17.0 coq-ext-lib.0.11.8 coq-simple-io.1.8.0

COPY lib/ ./lib/

# Build and install QuickChick from source
# TODO_ARTIFACT: the below errors for me
# RUN eval $(opam env) && cd lib/QuickChick && make
# RUN eval $(opam env) && cd lib/QuickChick && make install

# Set up opam environment in .bashrc
RUN echo 'eval $(opam env)' >> /root/.bashrc

# Copy Python requirements and install packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

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
