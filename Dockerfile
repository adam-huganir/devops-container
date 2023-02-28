# syntax=docker/dockerfile:1.5
FROM ubuntu:lunar-20230128

ARG USERNAME
ENV USERNAME=${USERNAME:-dev}

ENV HELM_EXPERIMENTAL_OCI=1

# Versions
ENV GCLOUD_CLI_VERSION=419.0.0
ENV GO_VERSION=1.20.1
ENV KNATIVE_CLI_VERSION=1.9.0
ENV TERRAFORM_VERSION=1.3.9

USER root
SHELL  ["bash", "-c"]

COPY --chown=ubuntu:ubuntu ./user_setup.zsh /home/ubuntu/user_setup.zsh

WORKDIR /root
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked  <<BLOCK
set -euo pipefail

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
apt autoremove && apt autoclean

# Rename the user
groupmod -n $USERNAME ubuntu && usermod -l $USERNAME -md /home/$USERNAME ubuntu
usermod -aG sudo \
    --shell /usr/bin/zsh \
    $USERNAME

runuser -l $USERNAME <<USER_BLOCK
set -euo  pipefail

export GCLOUD_CLI_VERSION=$GCLOUD_CLI_VERSION
export GO_VERSION=$GO_VERSION
export KNATIVE_CLI_VERSION=$KNATIVE_CLI_VERSION
export TERRAFORM_VERSION=$TERRAFORM_VERSION

sudo chown -R 1000:1000 .
zsh ./user_setup.zsh && rm user_setup.zsh
USER_BLOCK

rm -rf /tmp/* /root/.cache /root/.local
BLOCK


# using build args is a little more user friendly on build commands

USER $USERNAME
WORKDIR /home/$USERNAME
COPY --chown=$USERNAME:$USERNAME ./.zshrc ./.zshrc
ENV USER=""

# Customize
# see https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ENV ZSH_THEME jreese

# remove strictness
SHELL [ "/usr/bin/zsh", "-l", "-c" ]
ENTRYPOINT [ "/usr/bin/zsh", "-l" ]
