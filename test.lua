require "argy"
require "help"
--print(arg[1])
argy:arg("hi","--hi", "string", "are you hi or are you bye")
argy:arg("bi","--bi", "string", "how bye are you")
argy:positional_arg("am",3, "string")
argy:positional_arg("mine",4, "string")

argy:gen_fargs() 
argy:gen_help()    

print(argy:get("hi"))
print(argy:get("am"))
print(argy:get("mine"))
print(argy:get_unused(5))

 
 
