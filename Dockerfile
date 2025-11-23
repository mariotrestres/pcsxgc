FROM devkitpro/devkitppc:latest

USER root

# Install required keys and the custom repo
RUN dkp-pacman-key --recv-keys C8A2759C315CFBC3429CC2E422B803BA8AA3D7CE --keyserver keyserver.ubuntu.com && \
    dkp-pacman-key --lsign-key C8A2759C315CFBC3429CC2E422B803BA8AA3D7CE && \
    sed -i '/^\[dkp-libs\]/,$d' /opt/devkitpro/pacman/etc/pacman.conf && \
    printf '\n[extremscorner-devkitpro]\nServer = https://packages.extremscorner.org/devkitpro/linux/$arch\n' \
      >> /opt/devkitpro/pacman/etc/pacman.conf && \
    dkp-pacman -Sy && \
    dkp-pacman -S --noconfirm --ask 4 \
        gamecube-tools-git \
        libogc2 \
        libogc2-cmake \
        libogc2-libdvm \
        ppc-zlib-ng-compat

# Export PATH for devkitPPC
ENV PATH="$PATH:/opt/devkitpro/devkitPPC/bin"

# Set compile flags
ENV CFLAGS="-O3 -fipa-pta -flto -DNDEBUG"
ENV CXXFLAGS="-O3 -fipa-pta -flto -DNDEBUG"

# Clone PCSXGC
#RUN git clone https://github.com/emukidid/pcsxgc /pcsxgc
RUN git clone https://github.com/mariotrestres/pcsxgc  /pcsxgc

# Copy release folders (matches workflow)
RUN cp -r /pcsxgc/Gamecube/release /pcsxgc/release && \
    cp -r /pcsxgc/Gamecube/release /pcsxgc/release_unai

WORKDIR /pcsxgc

# BUILD CubeSX (Peops)
RUN mkdir build_cube && \
    cmake -B build_cube -DCMAKE_BUILD_TYPE=None -DWIISX_TARGET=NintendoGameCube -DGPU_PLUGIN=Peops && \
    cmake --build build_cube && \
    mv build_cube/CubeSX.dol release/CubeSX.dol

# BUILD CubeSX (Unai)
RUN mkdir build_cube_unai && \
    cmake -B build_cube_unai -DCMAKE_BUILD_TYPE=None -DWIISX_TARGET=NintendoGameCube -DGPU_PLUGIN=Unai && \
    cmake --build build_cube_unai && \
    mv build_cube_unai/CubeSX.dol release_unai/CubeSX.dol

CMD ["/bin/bash"]

