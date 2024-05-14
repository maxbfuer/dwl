{
  description = "My personal build of dwl";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
    inherit (pkgs) stdenv lib;
  in {
    packages.x86_64-linux.dwl = stdenv.mkDerivation (finalAttrs: {
      pname = "dwl";
      version = "personal";

      src = ./.;

      nativeBuildInputs = with pkgs; [
        installShellFiles
        pkg-config
        wayland-scanner
      ];

      buildInputs = with pkgs; [
        libinput
        xorg.libxcb
        libxkbcommon
        pixman
        wayland
        wayland-protocols
        wlroots
        # XWayland deps
        xorg.libX11
        xorg.xcbutilwm
        xwayland
        # bar patch deps
        fcft
        libdrm
      ];

      outputs = ["out" "man"];

      makeFlags = [
        "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
        "WAYLAND_SCANNER=wayland-scanner"
        "PREFIX=$(out)"
        "MANDIR=$(man)/share/man"
      ];

      preBuild = ''
        makeFlagsArray+=(
          XWAYLAND=-DXWAYLAND
          XLIBS="xcb xcb-icccm"
        )
      '';

      meta = {
        homepage = "https://github.com/maxbfuer/dwl/";
        description = "Dynamic window manager for Wayland";
        longDescription = ''
          dwl is a compact, hackable compositor for Wayland based on wlroots. It is
          intended to fill the same space in the Wayland world that dwm does in X11,
          primarily in terms of philosophy, and secondarily in terms of
          functionality. Like dwm, dwl is:

          - Easy to understand, hack on, and extend with patches
          - One C source file (or a very small number) configurable via config.h
          - Limited to 2000 SLOC to promote hackability
          - Tied to as few external dependencies as possible
        '';
        changelog = "https://github.com/djpohly/dwl/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.gpl3Only;
        maintainers = [lib.maintainers.AndersonTorres];
        inherit (pkgs.wayland.meta) platforms;
        mainProgram = "dwl";
      };
    });
  };
}
