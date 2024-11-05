FROM debian:bookworm-20240926-slim

ARG TARGETOS
ARG TARGETARCH

ARG REPRODUCIBLE_CONTAINERS_VERSION

ADD --chmod=0755 \
    https://raw.githubusercontent.com/reproducible-containers/repro-sources-list.sh/refs/tags/v${REPRODUCIBLE_CONTAINERS_VERSION}/repro-sources-list.sh \
    /usr/local/bin

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    KEEP_CACHE=1 /usr/local/bin/repro-sources-list.sh

ARG APT_INSTALL='\
set -euxo pipefail; \

apt_install() { \
    apt-get update; \

    apt-get install -y \
    --no-install-recommends \
    --no-install-suggests \
    $@; \

    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/ldconfig/aux-cache; \
}; \
'

# setup ca-certificates so SSL stuff like cert verification can work
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install ca-certificates
EOF

## setup compiler
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install gcc libc6-dev
EOF

# setup build dependencies

# rules_bison
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install g++
EOF

# setup bazelisk
ARG BAZELISK_VERSION
ADD --chmod=755 \
    https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-${TARGETOS}-${TARGETARCH} \
    /usr/bin
RUN ln -s /usr/bin/bazelisk-${TARGETOS}-${TARGETARCH} /usr/bin/bazel

# bazel: git_override
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install git
EOF

# setup bazel
ARG USE_BAZEL_VERSION
RUN /usr/bin/bazel --version


## DEBUG

# setup basic tooling that's useful for debugging, etc (bsdextrautils: column)
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install vim curl grep less file tree bsdextrautils
EOF

## setup bash autocompletion
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install bash-completion

cat <<EOT >> ~/.bashrc

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

EOT
EOF

# setup bazel autocompletion
RUN /bin/bash <<EOF
set -euxo pipefail
BAZEL_URL="https://raw.githubusercontent.com/bazelbuild/bazel"

mkdir -p ~/.local/share/bazel-completion
cd ~/.local/share/bazel-completion

echo '# Bazelisk bazel autocompletion hack:' >> ~/.bashrc
echo '# https://github.com/bazelbuild/bazelisk/issues/29#issuecomment-1696326105' >> ~/.bashrc

for bazel_completion_file in bazel-complete-header.bash bazel-complete-template.bash; do
    curl -fsSL "\$BAZEL_URL/$USE_BAZEL_VERSION/scripts/\$bazel_completion_file" > \$bazel_completion_file
    echo "source ~/.local/share/bazel-completion/\$bazel_completion_file" >> ~/.bashrc
done

/usr/bin/bazel help completion > ~/.local/share/bazel-completion/bazel-help-completion.bash
echo "source ~/.local/share/bazel-completion/bazel-help-completion.bash" >> ~/.bashrc
EOF

# setup tooling
RUN /bin/bash <<EOF
set -euxo pipefail

echo "alias ls='ls --color'" >> ~/.bashrc

echo "
[alias]
    st = status
    co = checkout
    ci = commit
    br = branch
    unstage = reset HEAD --
    last = log -1
    summary = last --summary
    slog = log --oneline
    nslog = slog --name-status
    gslog = slog --graph
    gnslog = nslog --graph

[core]
    editor = /usr/bin/vim
" > ~/.gitconfig
EOF
