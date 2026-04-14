require "argy"
require "help"
--print(arg[1])
argy.inputs.args:arg("hi","--hi", "string", "are you hi or are you bye")
argy.inputs.args:arg("bi","--bi", "string", "how bye are you")
argy.inputs.positional_args:positional_arg("am",3, "string")
argy.inputs.positional_args:positional_arg("mine",4, "string")
print(argy.outputs:check_tables("hi").arg_type)
argy:gen_fargs() 
argy:gen_help()    

argy.outputs.final_args:set("my",{})
local my_t = argy.outputs.final_args:get("my")
my_t.value = "iamfake"
print(argy.outputs.final_args:get("my").value)

print(argy.outputs.final_args:get("hi").value)
print(argy.outputs.final_args:get("am").value)
print(argy.outputs.final_args:get("mine").value)
argy.outputs.unused_args:set(5,6)
print(argy.outputs.unused_args:get(5))

 
 
