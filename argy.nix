{ lua, fetchFromGitHub}:
lua.pkgs.buildLuarocksPackage {
  pname = "argy";
  version = "dev-2";

  src = fetchFromGitHub {
    owner = "Pogwat";
    repo = "argy";
    rev = "0ff83ddab6cf60fe673d56973e9ac1c3c29ec96e";
    hash = "sha256-1Yi3V+OlZHQPwyortnXFNQ4Dc1xBJSUeBg8JJHznM4Y=";
  };

  disabled = lua.pkgs.luaOlder "5.1";

  meta = {
    homepage = "https://github.com/Pogwat/argy";
    license.fullName = "MIT";
    description = "Simple Lua arg parser.";
    longDescription = ''Simple Lua arg parser. Supports flags, Arguments, Positional Arguments and Help Generation'';
  };
}