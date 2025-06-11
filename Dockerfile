# 1. Install Julia
FROM julia:1.10

# Set the working directory
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Install opam and other dependencies
RUN apt-get install -y opam build-essential libgmp-dev pkg-config

# Initialize opam and install Coq
RUN opam init --disable-sandboxing -y
RUN opam switch create 4.10.0+afl -y
RUN eval $(opam env) && opam pin coq 8.15.2 -y --assume-depexts

# Copy Python requirements and install packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Copy Julia project files
COPY lib/project-for-artifact/Project.toml ./

# Copy local Julia packages
COPY lib/ ./lib/

# Install Julia packages
RUN julia --project -e 'using Pkg; Pkg.instantiate()'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/IRTools.jl")'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/CUDD.jl")'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/Dice.jl")'

# Copy the rest of the application
COPY . .

# Set a default command (optional)
# CMD ["julia"]
