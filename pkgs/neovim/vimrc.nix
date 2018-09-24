{ stdenv, writeText }:

let
    generic = builtins.readFile ./vimrc/general.vim;
in ''
    ${generic}
''
