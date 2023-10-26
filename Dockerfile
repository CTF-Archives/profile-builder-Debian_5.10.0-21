FROM debian:11.8

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update && \
    apt install -y linux-kbuild-5.10 gcc-10 dwarfdump build-essential unzip

COPY ./service/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && \
    mkdir /app

COPY ./src/ /src/

WORKDIR /src

RUN wget https://debian.sipwise.com/debian-security/pool/main/l/linux/linux-headers-5.10.0-21-amd64_5.10.162-1_amd64.deb && \
    wget https://debian.sipwise.com/debian-security/pool/main/l/linux/linux-headers-5.10.0-21-common_5.10.162-1_all.deb && \
    wget https://debian.sipwise.com/debian-security/pool/main/l/linux/linux-image-5.10.0-21-amd64-dbg_5.10.162-1_amd64.deb && \
    wget https://debian.sipwise.com/debian-security/pool/main/l/linux/linux-image-5.10.0-21-amd64-unsigned_5.10.162-1_amd64.deb

RUN dpkg -i linux-headers-5.10.0-21-common_5.10.162-1_all.deb
RUN dpkg -i linux-image-5.10.0-21-amd64-dbg_5.10.162-1_amd64.deb
RUN apt install linux-compiler-gcc-10-x86
RUN dpkg -i linux-headers-5.10.0-21-amd64_5.10.162-1_amd64.deb
RUN apt --fix-broken install
RUN apt install kmod linux-base initramfs-tools
# RUN dpkg -i linux-image-5.10.0-21-amd64-unsigned_5.10.162-1_amd64.deb
# RUN apt --fix-broken install -y
RUN dpkg -i linux-image-5.10.0-21-amd64-unsigned_5.10.162-1_amd64.deb

RUN unzip tool.zip
WORKDIR /src/linux
RUN echo 'MODULE_LICENSE("GPL");' >> module.c && \
    sed -i 's/$(shell uname -r)/5.10.0-21-amd64/g' Makefile && \
    make && \
    mv module.dwarf /app