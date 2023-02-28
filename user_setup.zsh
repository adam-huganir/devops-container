#!/usr/bin/env zsh
set -euo pipefail
export HELM_EXPERIMENTAL_OCI=1

mkdir -p ~/.local/bin ~/.local/share ~/.local/lib ~/.local/src
export PATH="$HOME/.local/bin:$HOME/.pyenv/bin:$HOME/.local/google-cloud-sdk/bin:$HOME/.local/go/bin:$HOME/.cargo/bin:$PATH"


# install zsh
echo "Installing og-my-zsh"
function {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  git clone https://github.com/johanhaleby/kubetail.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/kubetail
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions \
    ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
}

#  install python tools
echo "Installing python and python apps"
function {
  curl -sL https://pyenv.run | bash
  pipx install poetry
  pipx inject --include-apps poetry poethepoet
  pipx install yq
  pipx install rich-cli
  pipx install httpie
}


echo "Installing go"
function {
  curl -sL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o - | tar --directory $HOME/.local -xz
}

echo "Installing rust and a handing/fast du alternative in rust"
function {
  curl -sL https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
  cargo install du-dust
}

echo "Installing node version manager (nvm)"
function {
  bash -c "$(curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh)"
  source "$HOME/.nvm/nvm.sh"
  nvm install --lts
}

echo "Installing NeoVim and LunarVim"
function {
  curl -sLO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
  sudo dpkg -i ./nvim-linux64.deb && rm ./nvim-linux64.deb
  # LunarVim so we can get ourselves some ide like features
  LV_BRANCH='release-1.2/neovim-0.8' bash \
    <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh) \
    --install-dependencies --yes
}
sudo install $HOME/.local/bin/lvim /usr/local/bin && rm $HOME/.local/bin/lvim

echo "Installing cicd and kubernetes tools"
echo "Installing google cli tools"
function {
  curl -sLO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_CLI_VERSION}-linux-x86_64.tar.gz
  tar --directory $HOME/.local -xzf google-cloud-cli-${GCLOUD_CLI_VERSION}-linux-x86_64.tar.gz && rm google-cloud-cli-${GCLOUD_CLI_VERSION}-linux-x86_64.tar.gz
  gcloud components install gke-gcloud-auth-plugin
}

echo "Installing github tools"
function {
  curl -sL -o ./github.deb \
    "$( curl -sL https://github.com/cli/cli/releases/ | grep -m1 -oi '/cli/.*/gh_.*_linux_amd64.deb' | xargs -I % echo https://github.com%)"
  sudo dpkg -i ./github.deb && rm ./github.deb
}

echo "Installing terraform"
function {
  curl -sL -o terraform.zip \
    https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform.zip
  sudo install terraform /usr/local/bin && rm terraform  terraform.zip
}

echo "Installing kubectl"
function {
  curl -sL "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o kubectl
  sudo install kubectl /usr/local/bin && rm kubectl
}

echo "Installing istio and native cli tools"
function {
  curl -sL https://istio.io/downloadIstio | sh -
  sudo install ./istio*/bin/istioctl /usr/local/bin && rm -rf ./istio*

  curl -sL https://github.com/knative/client/releases/download/knative-v${KNATIVE_CLI_VERSION}/kn-linux-amd64 -o kn
  sudo install kn /usr/local/bin && rm  kn
}

echo "Installing skaffold"
function {
  curl -sL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o skaffold
  sudo install skaffold /usr/local/bin && rm  skaffold
}

echo "Installing helm and adding some repos"
function {
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o get-helm.sh
  sudo bash get-helm.sh && rm get-helm.sh
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo add kedacore https://kedacore.github.io/charts
  helm repo add kiali https://kiali.org/helm-charts
  helm repo add milvus https://milvus-io.github.io/milvus-helm
  helm repo add minio https://operator.min.io/
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
}
function {
  go install github.com/stern/stern@latest
}
