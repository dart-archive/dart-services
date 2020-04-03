FROM gitpod/workspace-full

USER gitpod

# Install custom tools, runtime, etc. using apt-get
# For example, the command below would install "bastet" - a command line tetris clone:
#
# RUN sudo apt-get -q update && \
#     sudo apt-get install -yq bastet && \
#     sudo rm -rf /var/lib/apt/lists/*
#
# More information: https://www.gitpod.io/docs/config-docker/

RUN sudo apt-get update && \
 sudo apt-get install apt-transport-https && \
 sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' && \
 sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list' && \
 sudo apt-get update && \
 sudo apt-get install dart && \
 sudo echo "export PATH=\"\$PATH:/usr/lib/dart/bin:\$HOME/.pub-cache/bin\"" >> /etc/bash.bashrc && \
 pub global activate grinder && \
 pub global activate protoc_plugin