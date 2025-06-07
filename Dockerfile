# 1. Install Julia
FROM julia:1.10

# Set the working directory
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Copy Python requirements and install packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy Julia project files
COPY Project.toml Manifest.toml ./

# Copy local Julia packages
COPY lib/ ./lib/

# Install Julia packages
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/IRTools.jl")'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/CUDD.jl")'
RUN julia --project -e 'using Pkg; Pkg.develop(path="lib/Dice.jl")'
RUN julia --project -e 'using Pkg; Pkg.instantiate()'

# Copy the rest of the application
COPY . .

# Set a default command (optional)
# CMD ["julia"]
