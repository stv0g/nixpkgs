{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitLab,
  gitUpdater,
  pkg-config,
  systemd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ethercat";
  version = "1.6.1";

  src = fetchFromGitLab {
    owner = "etherlab.org";
    repo = "ethercat";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-fvuyADZzH1lHo1TkGd9s3n2n8y9vsGgs/ZOakIw48WI=";
  };

  separateDebugInfo = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ systemd ];

  outputs = [
    "bin"
    "dev"
  ];

  configureFlags = [
    # Components
    "--enable-tool=yes"
    "--enable-userlib=yes"
    "--enable-kernel=no"

    "--with-systemdsystemunitdir=$$out/lib/systemd/system"

    # Features
    "--enable-eoe=yes"
    "--enable-cycles=yes"
    "--enable-rtmutex=yes"
    "--enable-hrtimer=yes"
    "--enable-regalias=yes"
    "--enable-refclkop=yes"
    "--enable-tty=no" # Is broken in Kernel 6.6
    "--enable-wildcards"

    # Debugging
    "--enable-debug-if=yes"
    "--enable-debug-ring=yes"
  ];

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "IgH EtherCAT Master for Linux";
    homepage = "https://etherlab.org/ethercat";
    changelog = "https://gitlab.com/etherlab.org/ethercat/-/blob/${finalAttrs.version}/NEWS";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ stv0g ];
    platforms = platforms.linux;
  };
})
