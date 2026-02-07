FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    sudo \
    dotnet-runtime-6.0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/lampac

RUN curl -L -k -s https://raw.githubusercontent.com/lampastore/lampac-scripts/master/docker-install.sh | bash

VOLUME /home/lampac/cache

EXPOSE 9111

ENTRYPOINT ["dotnet", "Lampac.dll"]