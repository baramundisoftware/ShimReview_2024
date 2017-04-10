FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
  make \
  openssl \
  gcc \
  bsdmainutils \
  wget \
  dos2unix \
  gnu-efi

RUN mkdir /build && \
    wget -qO- https://github.com/rhboot/shim/releases/download/15.8/shim-15.8.tar.bz2 | \
    tar -xj -C /build
COPY sbat.baramundi.csv /build/shim-15.8/data/
COPY cert.der shimx64.efi shimia32.efi /build/

WORKDIR /build
RUN cp -r shim-15.8 shim-15.8-x64 && \
    mv shim-15.8 shim-15.8-x86


# build x64 Shim
RUN make -C shim-15.8-x64 CC=gcc ARCH=x86_64 EFIDIR=/usr/lib DEFAULT_LOADER=grub2_x64.efi VENDOR_CERT_FILE=/build/cert.der
RUN make -C shim-15.8-x86 CC=gcc ARCH=ia32 EFIDIR=/usr/lib32 DEFAULT_LOADER=grub2_x86.efi VENDOR_CERT_FILE=/build/cert.der

RUN sha256sum shim-15.8-x64/shimx64.efi shimx64.efi shim-15.8-x86/shimia32.efi shimia32.efi
