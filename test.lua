require "argy"
require "help"
--print(arg[1])
argy.args:arg("hi","--hi", "string", "are you hi or are you bye")
argy.args:arg("bi","--bi", "string", "how bye are you")
argy.positional_args:positional_arg("am",3, "string")
argy.positional_args:positional_arg("mine",4, "string")
print(argy:check_tables("hi").arg_type)
argy:gen_fargs() 
argy:gen_help()    

argy.final_args:set("my",{})
local my_t = argy.final_args:get("my")
my_t.value = "iamfake"
print(argy.final_args:get("my").value)

print(argy.final_args:get("hi").value)
print(argy.final_args:get("am").value)
print(argy.final_args:get("mine").value)
print(argy.unused_args:get(5))

 
 
