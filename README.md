# Gwendoline's Bachelor Thesis

Welcome to the Git repository for my bachelor's thesis on sentiment analysis. This
README will show you how you can set up the same environment as the one used while developing code for this thesis.

## 🐳 Using the pre-built Docker image

Run the following command to pull in the pre-built image.

```bash
docker pull gwendolinen/gwendoline-bachelor-thesis
```

## <a name="running"></a>🏃 Running the environment with Docker Desktop

To run the environment, execute following command and customize where needed.

```bash
docker run --env-file .env --volume $(pwd):/data --publish 8888:8888 gwendolinen/gwendoline-bachelor-thesis 
```

In Windows:
```bash
docker run --env-file .env -v "$(PWD)/:/data" -p 8888:8888 gwendolinen/gwendoline-bachelor-thesis
```

Your terminal should return a URL to open in your browser that leads to the 
Jupyter Notebook environment it has set up. You should now be able to run the
notebook that contains all the code used in the thesis.

### 🐧 Note for Linux users

Docker has some weird behaviour regarding its networking. It's best to create
your own Docker network, and attach the container to that to prevent some errors. E.g.

```bash
docker network create my-net
docker run --network my-net --volume $(pwd):/data --publish 8888:8888 gwendolinen/gwendoline-bachelor-thesis
```

This is needed as we will make use of NLTK's download functionality, and acces
the Twitter API through Tweepy.

## ❄ Building the Docker container with Nix

We use Nix to build our docker container, which makes the process easy *and*
reproducible. To use Nix, make sure you have it installed, check
[here][nix-install] for installation instructions.

If you're using Windows, consider using [WSL][wsl-install], and [installing a
NixOS image for WSL 2][wsl-nixos]. You can follow along in the WSL
instance to build the docker image with Nix. 
NOTE: for WSL users, don't execute the `docker load` command *inside* WSL, 
rather build the image in WSL, and load the `.tar.gz` image in Windows.

```bash
NIXPKGS_ALLOW_INSECURE=1 nix build github:GwendolineN-1745873/bachelor-thesis \
    && cat result | docker load 
```

We need `NIXPKGS_ALLOW_INSECURE` since one of the packages we depend on is
considered insecure.

If we now run `docker image ls` we'll see our newly generate image! 🎉 To run
the image, check the [Running the environment section](#running).

### Local
If you have cloned the repository locally, run the following.
```bash
NIXPKGS_ALLOW_INSECURE=1 nix build && cat result | docker load 
```
NOTE: for WSL users, don't execute the `docker load` command *inside* WSL, 
rather build the image in WSL, and load the `.tar.gz` image in Windows.

#### Windows
In wsl:
```bash
NIXPKGS_ALLOW_INSECURE=1 nix build
cp result image.tar.gz
```

In Windows:
```bash
docker load --input .\image.tar.gz
```

## 💾 Creating a dataset
Due to the Twitter API's developer agreement & policy the raw data used to perform
our sentiment analysis on will not be shared in this repository. Instead, you can 
create your own dataset using the script provided by `twitter_API.py` and by 
requesting access to the Twitter API through the Twitter Developer Portal.

### 🌳 Environment
To access the Tweepy API, some environment variables must be set in an `.env` file.
Run following command and fill in the appropriate credentials in the newly created file.
```bash
    cp .env_example .env
```

[nix-install]: https://nixos.org/download.html
[wsl-install]: https://docs.microsoft.com/en-us/windows/wsl/install#install-wsl-command
[wsl-nixos]: https://github.com/nix-community/NixOS-WSL
