if [ -e "$NIX_ATTRS_SH_FILE" ]; then . "$NIX_ATTRS_SH_FILE"; elif [ -f .attrs.sh ]; then . .attrs.sh; fi
source $stdenv/setup

unpackManually() {
    skip=$(sed 's/^skip=//; t; d' $src)
    tail -n +$skip $src | bsdtar xvf -
    sourceRoot=.
}

unpackFile() {
    sh $src -x || unpackManually
}

buildPhase() {
    runHook preBuild
    echo "------------------"
    export -p
    echo "------------------"

    if [ -n "$bin" ]; then
        # Create the module.
        echo "Building linux driver against kernel: $kernel"
        cd kernel
        unset src # used by the nv makefile
        make $makeFlags -j $NIX_BUILD_CORES module

        cd ..
    fi

    runHook postBuild
}

installPhase() {
    runHook preInstall
    tree ./
    echo "==============="
    ls -lah
    echo "==============="
    echo "Executable files"
    find ./ -type f -executable
    echo "==============="
    echo "Kernel modules"
    find . -name '*.ko'
    # Install the kernel module.
    mkdir -p $out/lib/modules/$kernelVersion/misc $out/bin "$out/lib"
    mkdir -p $bin/lib/modules/$kernelVersion/misc $bin/bin "$bin/lib"
    for i in $(find ./kernel -name '*.ko'); do
        nuke-refs $i
        cp $i $out/lib/modules/$kernelVersion/misc/
        chmod +rx $out/lib/modules/$kernelVersion/misc/
    done

    echo 'cp -prd *.so.* "$out/lib/"'
    cp -prd *.so.* "$out/lib/"
    if [ -d tls ]; then
        echo 'cp -prd tls "$out/lib/"'
        cp -prd tls "$out/lib/"
    fi

    # Install systemd power management executables
    if [ -e systemd/nvidia-sleep.sh ]; then
        mv systemd/nvidia-sleep.sh ./
    fi
    if [ -e nvidia-sleep.sh ]; then
        sed -E 's#(PATH=).*#\1"$PATH"#' nvidia-sleep.sh >nvidia-sleep.sh.fixed
        install -Dm755 nvidia-sleep.sh.fixed $out/bin/nvidia-sleep.sh
    fi

    if [ -e systemd/system-sleep/nvidia ]; then
        mv systemd/system-sleep/nvidia ./
    fi
    if [ -e nvidia ]; then
        sed -E "s#/usr(/bin/nvidia-sleep.sh)#$out\\1#" nvidia >nvidia.fixed
        install -Dm755 nvidia.fixed $out/lib/systemd/system-sleep/nvidia
    fi

    # for i in $lib32 $out; do
    #     rm -f $i/lib/lib{glx,nvidia-wfb}.so.*  # handled separately
    #     rm -f $i/lib/libnvidia-gtk*            # built from source
    #     rm -f $i/lib/libnvidia-wayland-client* # built from source
    #     if [ "$useGLVND" = "1" ]; then
    #         # Pre-built libglvnd
    #         rm $i/lib/lib{GL,GLX,EGL,GLESv1_CM,GLESv2,OpenGL,GLdispatch}.so.*
    #     fi
    #     # Use ocl-icd instead
    #     rm -f $i/lib/libOpenCL.so*
    #     # Move VDPAU libraries to their place
    #     mkdir $i/lib/vdpau
    #     mv $i/lib/libvdpau* $i/lib/vdpau
    #
    #     # Install ICDs, make absolute paths.
    #     # Be careful not to modify any original files because this runs twice.
    #
    #     # OpenCL
    #     sed -E "s#(libnvidia-opencl)#$i/lib/\\1#" nvidia.icd >nvidia.icd.fixed
    #     install -Dm644 nvidia.icd.fixed $i/etc/OpenCL/vendors/nvidia.icd
    #
    #     # Vulkan
    #     if [ -e nvidia_icd.json.template ] || [ -e nvidia_icd.json ]; then
    #         if [ -e nvidia_icd.json.template ]; then
    #             # template patching for version < 435
    #             sed "s#__NV_VK_ICD__#$i/lib/libGLX_nvidia.so#" nvidia_icd.json.template >nvidia_icd.json.fixed
    #         else
    #             sed -E "s#(libGLX_nvidia)#$i/lib/\\1#" nvidia_icd.json >nvidia_icd.json.fixed
    #         fi
    #
    #         # nvidia currently only supports x86_64 and i686
    #         if [ "$i" == "$lib32" ]; then
    #             install -Dm644 nvidia_icd.json.fixed $i/share/vulkan/icd.d/nvidia_icd.i686.json
    #         else
    #             install -Dm644 nvidia_icd.json.fixed $i/share/vulkan/icd.d/nvidia_icd.x86_64.json
    #         fi
    #     fi
    #
    #     if [ -e nvidia_layers.json ]; then
    #         sed -E "s#(libGLX_nvidia)#$i/lib/\\1#" nvidia_layers.json >nvidia_layers.json.fixed
    #         install -Dm644 nvidia_layers.json.fixed $i/share/vulkan/implicit_layer.d/nvidia_layers.json
    #     fi
    #
    #     # EGL
    #     if [ "$useGLVND" = "1" ]; then
    #         sed -E "s#(libEGL_nvidia)#$i/lib/\\1#" 10_nvidia.json >10_nvidia.json.fixed
    #         sed -E "s#(libnvidia-egl-wayland)#$i/lib/\\1#" 10_nvidia_wayland.json >10_nvidia_wayland.json.fixed
    #
    #         install -Dm644 10_nvidia.json.fixed $i/share/glvnd/egl_vendor.d/10_nvidia.json
    #         install -Dm644 10_nvidia_wayland.json.fixed $i/share/egl/egl_external_platform.d/10_nvidia_wayland.json
    #
    #         if [[ -f "15_nvidia_gbm.json" ]]; then
    #             sed -E "s#(libnvidia-egl-gbm)#$i/lib/\\1#" 15_nvidia_gbm.json >15_nvidia_gbm.json.fixed
    #             install -Dm644 15_nvidia_gbm.json.fixed $i/share/egl/egl_external_platform.d/15_nvidia_gbm.json
    #
    #             mkdir -p $i/lib/gbm
    #             ln -s $i/lib/libnvidia-allocator.so $i/lib/gbm/nvidia-drm_gbm.so
    #         fi
    #     fi
    #
    #     # Install libraries needed by Proton to support DLSS
    #     if [ -e nvngx.dll ] && [ -e _nvngx.dll ]; then
    #         install -Dm644 -t $i/lib/nvidia/wine/ nvngx.dll _nvngx.dll
    #     fi
    # done

    # OptiX tries loading `$ORIGIN/nvoptix.bin` first
    if [ -e nvoptix.bin ]; then
        install -Dm444 -t $out/lib/ nvoptix.bin
    fi

    if [ -n "$firmware" ]; then
        # Install the GSP firmware
        install -Dm644 -t $firmware/lib/firmware/nvidia/$version firmware/gsp*.bin
    fi

    # All libs except GUI-only are installed now, so fixup them.
    for libname in $(find "$out/lib/" $(test -n "$bin" && echo "$out/lib/") -name '*.so.*'); do
        libname_short=$(echo -n "$libname" | sed 's/so\..*/so/')

        if [[ "$libname" != "$libname_short" ]]; then
            ln -srnf "$libname" "$libname_short"
        fi

        if [[ $libname_short =~ libEGL.so || $libname_short =~ libEGL_nvidia.so || $libname_short =~ libGLX.so || $libname_short =~ libGLX_nvidia.so ]]; then
            major=0
        else
            major=1
        fi

        if [[ "$libname" != "$libname_short.$major" ]]; then
            ln -srnf "$libname" "$libname_short.$major"
        fi
    done

    if [ -n "$bin" ]; then
        # Install /share files.
        mkdir -p $bin/share/man/man1
        cp -p *.1.gz $bin/share/man/man1
        rm -f $bin/share/man/man1/{nvidia-xconfig,nvidia-settings,nvidia-persistenced}.1.gz
    fi
    for i in libnvidia-vgpu.so.$vgpuVersion libnvidia-vgxcfg.so.$vgpuVersion; do
        install -Dm755 "$i" "$out/lib/$i"
    done
    patchelf --set-rpath $ccLib/lib $out/lib/libnvidia-vgpu.so.$vgpuVersion
    install -Dm644 vgpuConfig.xml $out/vgpuConfig.xml

    for i in nvidia-vgpud nvidia-vgpu-mgr sriov-manage nvidia-vgpud nvidia-vgpu-mgr nvidia-smi nvidia-modprobe nvidia-debugdump; do
        install -Dm755 "$i" "$out/bin/$i"
        # stdenv.cc.cc.lib is for libstdc++.so needed by nvidia-vgpud
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath $out/lib:$libPath $out/bin/$i 
    done

    runHook postInstall
}

genericBuild
