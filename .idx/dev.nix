# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.cmake
    pkgs.android-tools
  ];

  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "circlecodesolution.ccs-flutter-color"
      "Dart-Code.dart-code"
      "Dart-Code.flutter"
      "jeroen-meijer.pubspec-assist"
    ];

    # Enable previews
    previews = {
      enable = true;
      previews = {
        android = {
            manager = "flutter";
        };
        ios = {
            manager = "flutter";
        };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        install-deps = "flutter pub get";
      };
      onStart = {
      };
    };
  };
}
