{
  autoreconfHook,
  cmake,
  lib,
  pkg-config,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  kernel,
}:
let
  deviceKernelCompatabilities = {
    "6.6" = [ "igc" ];
    "6.4" = [
      "e100"
      "igc"
    ];
    "6.1" = [
      "8139too"
      "bcmgenet"
      "e100"
      "e1000"
      "e1000e"
      "igb"
      "igc"
      "r8169"
    ];
    "5.15" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "igb"
      "r8169"
    ];
    "5.14" = [
      "8139too"
      "bcmgenet"
      "e100"
      "e1000"
      "e1000e"
      "igb"
      "igc"
      "r8169"
    ];
    "5.10" = [
      "8139too"
      "bcmgenet"
      "e100"
      "e1000"
      "e1000e"
      "igb"
      "r8169"
    ];
    "5.4" = [
      "e100"
      "e1000e"
    ];
    "4.19" = [ "igb" ];
    "4.4" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "igb"
      "r8169"
    ];
    "3.18" = [ "igb" ];
    "3.16" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.14" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.12" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.10" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.8" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.6" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.4" = [
      "8139too"
      "e100"
      "e1000"
      "e1000e"
      "r8169"
    ];
    "3.2" = [
      "8139too"
      "e1000e"
      "r8169"
    ];
    "3.0" = [
      "8139too"
      "e100"
      "e1000"
    ];
  };

  kernelVersionMajorMinor = builtins.concatStringsSep "." (
    builtins.take 2 (builtins.splitVersion kernel.version)
  );

  supportedDrivers = deviceKernelCompatabilities.${kernelVersionMajorMinor};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ethercat";
  version = "1.6-alpha";

  src = fetchFromGitLab {
    owner = "etherlab.org";
    repo = "ethercat";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-kzyA6h0rZFEROLcFZoU+2fIQ/Y0NwtdPuliKDbwkHrE=";
  };

  separateDebugInfo = true;
  hardeningDisable = [
    "pic"
    "format"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    kernel.moduleBuildDependencies
  ];

  outputs = [
    "bin"
    "dev"
    "kmod"
  ];

  configureFlags = [
    # Components
    "--enable-tool=yes"
    "--enable-userlib=yes"
    "--enable-kernel=yes"

    # Features
    "--enable-eoe=yes=yes"
    "--enable-cycles=yes=yes"
    "--enable-rtmutex=yes"
    "--enable-hrtimer=yes"
    "--enable-regalias=yes"
    "--enable-refclkop=yes"

    # Kernel
    "--with-linux-dir=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "--module-dir=$$kmod"

    # Debugging
    "--enable-debug-if=yes"
    "--enable-debug-ring=yes"
  ] ++ builtins.map (driver: "--enable-${driver}=yes") supportedDrivers;

  buildFlags = [
    "all"
    "modules"
  ];

  installTargets = [
    "modules_install"
    "install"
  ];

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "IgH EtherCAT Master for Linux";
    homepage = "https://etherlab.org/ethercat";
    changelog = "https://gitlab.com/etherlab.org/ethercat/-/blob/${finalAttrs.version}/NEWS";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ stv0g ];
    platforms = platforms.linux;
    outputsToInstall = [
      "bin"
      "out"
    ];
  };
})
