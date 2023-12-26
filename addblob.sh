#!/bin/bash
set -x
set -e # exit on non-zero status

# params
# $1: src
# $2: target
function addBlobOnChecksumChange() {
  src="$1"
  target="$2"
  blob_checksum=$(cat config/blobs.yml  | yq .'"'${target}'"'.sha)
  src_checksum=$(cat "${src}"  | sha256sum |  cut -d " " -f1)
  if [ "${blob_checksum}" != "sha256:${src_checksum}" ]; then
    bosh add-blob ${src} ${target}
  else
    echo "skipping blob creation for ${target} with existing checksum: ${src_checksum}"
  fi
}

addBlobOnChecksumChange src/github.com/k3s-io/k3s/k3s k3s/k3s
addBlobOnChecksumChange src/github.com/k3s-io/k3s/k3s-airgap-images-amd64.tar k3s-images/k3s-airgap-images-amd64.tar


pushd src/github.com/derailed/k9s/
tar xfv ./k9s_Linux_amd64.tar.gz
popd


addBlobOnChecksumChange src/github.com/derailed/k9s/k9s k9s/k9s

pushd src/github.com/containerd/nerdctl/
tar xfv ./nerdctl-1.3.1-linux-amd64.tar.gz
popd

addBlobOnChecksumChange src/github.com/containerd/nerdctl/nerdctl nerdctl/nerdctl

chmod ugo+x src/github.com/kubernetes/kubectl/kubectl
addBlobOnChecksumChange src/github.com/kubernetes/kubectl/kubectl kubectl/kubectl


