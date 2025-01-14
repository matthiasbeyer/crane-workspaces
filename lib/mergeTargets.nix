{ pkgs }: default_derivation: derivations:
let
  name = "merged-targets-${builtins.concatStringsSep "-" (["default"] ++ (pkgs.lib.mapAttrsToList (name: _: name) derivations))}";
in
# This derivation results in a merged set of different workspace members.
# The default (aka the 'external dependencies') are always included, 
# and then only the required local dependencies are added.
pkgs.runCommandLocal name { } ''
  mkdir -p $out
  echo "Copying default workspace artifacts"
  cp --recursive --no-preserve=mode,ownership ${default_derivation}/. -t $out
  ${builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: drv: ''
      echo "Copying artifacts from ${name}: ${drv}"
      cp --remove-destination --recursive --no-preserve=mode,ownership ${drv}/. -t $out
    '') derivations)}
''
