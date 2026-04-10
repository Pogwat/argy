require "argy"
require "help"
--print(arg[1])
argy:arg("hi","--hi", "string")
 argy:arg("bi","--bi", "string")
 --argy:flag("h","-h", "string")
 argy:positional_arg("am",3, "string")
argy:positional_arg("mine",4, "string")
-- print(argy.args["--hi"])

 argy:gen_fargs() 
print(argy:get("hi"))
-- print(argy.final_args["hi"])
 print(argy.final_args["am"].value)

 -- print(argy.final_args["mine"])

--print(argy.final_args["bi"])
-- print(argy.final_args[2])
--print(argy.final_args)

 
 argy:gen_help()
