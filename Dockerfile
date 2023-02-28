# syntax=docker/dockerfile:1.5
FROM ubuntu:lunar-20230128

ENV HELM_EXPERIMENTAL_OCI 1

# Versions
ENV GCLOUD_CLI_VERSION=419.0.0
ENV GO_VERSION=1.20.1
ENV KNATIVE_CLI_VERSION=1.9.0
ENV TERRAFORM_VERSION 1.3.9

USER root
SHELL  ["bash", "-c"]

WORKDIR /root
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked  <<BLOCK
set -euo pipefail

echo devops > /etc/hostname

sed -i -r 's/# deb-src/deb-src/g' /etc/apt/sources.list
apt-get update

# Tools to keep:
apt-get install -y \
        build-essential \
        curl \
        fzf \
        git \
        lsb-release \
        postgresql-client \
        python-is-python3 \
        python3 \
        python3-pip \
        python3-venv \
        sudo \
        tmux \
        unzip \
        wget \
        zsh
apt build-dep -y python3
pip install pipx

echo "" >> /etc/sudoers && echo '%sudo            ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers
usermod -aG sudo \
    --shell /usr/bin/zsh \
    ubuntu
sudo rm -rf /tmp/* /root/.cache /root/.local
apt autoremove && apt autoclean
BLOCK

USER ubuntu
WORKDIR /home/ubuntu
COPY --chown=ubuntu:ubuntu ./user_setup.zsh ./user_setup.zsh
SHELL [ "/usr/bin/zsh", "-lc" ]
RUN <<BLOCK
set -euo  pipefail
sudo chown -R ubuntu:ubuntu .
zsh ./user_setup.zsh && rm user_setup.zsh

sudo rm -rf /home/ubuntu/.cache && mkdir /home/ubuntu/.cache
sudo mv /home/ubuntu/.cargo/bin/(fd|rg|dust) /usr/local/bin
sudo rm -rf /home/ubuntu/.cargo /home/ubuntu/.rustup             # rust no longer needed unless we install other stuff
sudo mv /home/ubuntu/go/bin/* /usr/local/bin
sudo rm -rf /home/ubuntu/go                               # ditto
sudo rm -rf /home/ubuntu/.local/google-cloud-sdk/.install # we didnt use the normal installer so we nuke this
BLOCK


# using build args is a little more user friendly on build commands
ARG USER
ENV USER=${USER:-dev}
# Rename the user
USER root
RUN groupmod -n $USER ubuntu && usermod -l $USER -md /home/$USER ubuntu

USER $USER
WORKDIR /home/$USER
COPY --chown=$USER:$USER ./.zshrc ./.zshrc
ENV USER=""

# Customize
# see https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ENV ZSH_THEME jreese

# remove strictness
SHELL [ "zsh", "-lc" ]
ENTRYPOINT [ "/usr/bin/zsh", "-l" ]
