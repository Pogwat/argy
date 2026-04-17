{ lua, fetchFromGitHub}:
lua.pkgs.buildLuarocksPackage {
  pname = "argy";
  version = "dev-1";

  src = fetchFromGitHub {
    owner = "Pogwat";
    repo = "argy";
    rev = "66e232ab0a24086c1d714e91c1924ca121203ca8";
    hash = "sha256-6ddsTWih7545w5FIzxUciAD8gwiRL9hCXDkkhBbYjfs=";
  };

  disabled = lua.pkgs.luaOlder "5.1";

  meta = {
    homepage = "https://github.com/Pogwat/argy";
    license.fullName = "MIT";
    description = "Simple Lua arg parser.";
    longDescription = ''Simple Lua arg parser. Supports flags, Arguments, Positional Arguments and Help Generation'';
  };
}