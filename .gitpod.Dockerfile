FROM gitpod/workspace-full

USER gitpod

# Install custom tools, runtime, etc. using apt-get
# More information: https://www.gitpod.io/docs/config-docker/

RUN sudo apt-get update && \
    wget https://storage.googleapis.com/dart-archive/channels/beta/release/2.11.0-213.5.beta/linux_packages/dart_2.11.0-213.5.beta-1_amd64.deb && \
    sudo dpkg -i dart_2.11.0-213.5.beta-1_amd64.deb && \
    sudo apt-get install -y protobuf-compiler redis && \
    sudo apt-get update && \
    echo "export PATH=\"\$PATH:/usr/lib/dart/bin:\$HOME/.pub-cache/bin\"" >> $HOME/.bashrc && \
    /usr/lib/dart/bin/pub global activate grinder && \
    /usr/lib/dart/bin/pub global activate protoc_plugin && \
    /usr/lib/dart/bin/pub global activate webdev && \
    sudo rm -rf /var/lib/apt/lists/*
