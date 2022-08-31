{
  description = "Gwendoline Nijssen's bachelor thesis Nix flake";

  nixConfig.extra-experimetal-features = "nix-command flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    jupyterWith.url = "github:tweag/jupyterWith";
    jupyterWith.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, jupyterWith, flake-utils }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
      };

      textblob = pkgs.python3Packages.buildPythonPackage {
        pname = "textblob";
        version = "0.15.3";

        propagatedBuildInputs = with pkgs.python3Packages; [
          setuptools
          wheel
          nltk
        ];

        format = "wheel";
        src = pkgs.python3Packages.fetchPypi rec {
          pname = "textblob";
          version = "0.15.3";
          format = "wheel";
          sha256 =
            "b0eafd8b129c9b196c8128056caed891d64b7fa20ba570e1fcde438f4f7dd312";
          dist = python;
          python = "py2.py3";
        };
      };

      spacyTextblob = pkgs.python3Packages.buildPythonPackage {
        pname = "spacytextblob";
        version = "4.0.0";

        propagatedBuildInputs = with pkgs.python3Packages; [
          setuptools
          wheel
          textblob
          spacy
        ];

        src = pkgs.python3Packages.fetchPypi {
          pname = "spacytextblob";
          version = "4.0.0";
          sha256 = "19gq8gxy19qz4qmc385wq3wyvab0kjclrh15b0vr513ypiad5zh0";
        };
      };

      iPython = pkgs.kernels.iPythonWith {
        name = "Python-env";
        packages = p:
          with p; [
            numpy
            pandas
            nltk
            tweepy
            python-dotenv
            ipywidgets
            textblob
            spacy
            spacyTextblob
            spacy_models.en_core_web_sm
          ];
        ignoreCollisions = true;
      };

      jupyterlab = pkgs.jupyterlabWith { kernels = [ iPython ]; };
    in {
      apps.${system}.default = {
        type = "app";
        program = "${jupyterlab}/bin/jupyter-lab";
      };

      devShells.${system}.default = jupyterlab.env;

      packages.${system}.default = pkgs.dockerTools.buildImage {
        name = "gwendoline-bachelor-thesis";
        tag = "latest";
        contents = [ jupyterlab pkgs.glibcLocales pkgs.cacert ];
        config = {
          Env = [
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            "LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive"
            "LANG=en_US.UTF-8"
            "LANGUAGE=en_US:en"
            "LC_ALL=en_US.UTF-8"
          ];
          CMD = [
            "/bin/jupyter-lab"
            "--ip=0.0.0.0"
            "--port=8888"
            "--no-browser"
            "--allow-root"
          ];
          WorkingDir = "/data";
          ExposedPorts = { "8888" = { }; };
          Volumes = { "/data" = { }; };
        };
      };
    };
}
