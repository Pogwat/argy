-- cmd -a "b"    -c "d"
argy = {
        positional_args = {}, -- arg,
        args = {}, -- -a --arg
        flags = {}, -- -f
        final_args = {}
}

argy.positional_args.__index = function(table,key) return table[key] .." is not a value in " .. table end
argy.args.__index = function(table,key) return table[key] .." is not a value in " .. table end
argy.flags.__index = function(table,key) return table[key] .." is not a value in " .. table end

function argy:flag(name,arg_string, arg_type) 
    assert(type(arg_string) == "string", "flag " .. arg_string .. " is not of type string")
    assert(string.len(arg_string) == 2, "flag " .. arg_string .. " is not of size: " .. 2)
    assert(string.find(arg_string, "^%-"),"flag dosent start with -") -- probably should check if next char is not - we dont want -- as a flag
    assert(string.find(arg_string, "^%-%-")==nil,"flag " .. arg_string .." name is -")
    self.flags[arg_string] = name
    self.final_args[name] = {type = arg_type}
end

function argy:arg(name,arg_string, arg_type)
    assert(type(arg_string) == "string", "arg " .. arg_string .. " is not of type string" )
    assert(string.len(arg_string)>=2, "arg " .. arg_string .. " is not of size >2")
    assert(
        string.find(arg_string, "^%-%-") or string.find(arg_string, "^%-"), 
        "arg dosent start with -- or -")
    self.args[arg_string] = name
    self.final_args[name] = {type = arg_type}
end

function argy:positional_arg(name, arg_position, arg_type)
    assert(type(arg_position) == "number", "positional arg " .. arg_position .. " is not of type number" )
    self.positional_args[arg_position] = name
    self.final_args[name] = {type = arg_type}
    
end

function argy:get(name) 
    return self.final_args[name]
end

function argy:is_string_arg_or_flag(arg_string)
    if self.args[arg_string]~=nil then return "argument" end
    if self.flags[arg_string]~=nil then return "flag" end
end

function argy:is_name_arg_or_flag(name)
    self.final_args[name] = arg_string or error(name .." is not in final_args")
    if self.args[arg_string]~=nil then return "argument", self.args[arg_string] end
    if self.flags[arg_string]~=nil then return "flag", self.flags[arg_string] end
end

function argy:is_index_pos_arg(index) 
    if self.positional_args[index]~=nil then return "positional_arg", self.positional_args[index] end
end

function argy:handle_arg_type(arg_type, position)
    local types = {
        ["argument"] = {value = arg[position+1]  , skip =2, table = self.args, table_index = arg[position]},
        ["flag"] =  {value = true, skip = 1, table = self.flags, table_index = arg[position]},
        ["positional_arg"] =  {value = arg[position], skip = 1, table = self.positional_args, table_index = position }
    }
    return types[arg_type]
end

function argy:gen_fargs() 
    local position = 1
    while position <= #arg do
        local arg_string = arg[position]
        local arg_type = self:is_index_pos_arg(position) or self:is_string_arg_or_flag(arg_string) or error(arg_string .." matched no type")
        local handler = self:handle_arg_type(arg_type, position)
        local arg_name = handler.table[handler.table_index] or error(arg_string .. " did not match a table")
        self.final_args[arg_name] = handler.value 
        position=position+handler.skip
    end
end

--print(arg[1])
argy:arg("hi","--hi", "string")
argy:arg("bi","--bi", "string")
argy:flag("h","-h", "string")
argy:positional_arg("am",3, "string")
argy:positional_arg("mine",4, "string")
print(argy.args["--hi"])

argy:gen_fargs() 
print(argy:get("hi"))
-- print(argy.final_args["hi"])
-- print(argy.final_args["am"])
-- print(argy.final_args["mine"])

--print(argy.final_args["bi"])
-- print(argy.final_args[2])
--print(argy.final_args)

return argy --this is cool! The parser uses the return