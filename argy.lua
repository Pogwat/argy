-- cmd -a "b"    -c "d"
argy = {
            
    no_dash = {
        positional_args = {} -- arg,
    },
    
    dash = { 
        args = {}, -- -a --arg
        flags = {} -- -f
    },

    final_args = {}
}

function argy:flag(flag_name, flag_type) 
    assert(type(flag_name) == "string", "flag " .. flag_name .. " is not of type string")
    assert(string.len(flag_name) == 2, "flag " .. flag_name .. " is not of size: " .. 2)
    assert(string.find(flag_name, "^-"),"flag dosent start with -") -- probably should check if next char is not - we dont want -- as a flag
    assert(string.find(flag_name, "^--")~=nil,"flag name is -")
    self.dash.flags[flag_name] = flag_type
end

function argy:arg(arg_name, arg_type)
    assert(type(arg_name) == "string", "arg " .. arg_name .. " is not of type string" )
    assert(string.len(arg_name)>=2, "arg " .. arg_name .. " is not of size >2")
    assert(
        string.find(arg_name, "^--") or string.find(arg_name, "^-"), 
        "arg dosent start with -- or -")
    self.dash.args[arg_name] = arg_type
end

function argy:positional_arg(arg_position, arg_type)
    assert(type(arg_position) == "number", "positional arg " .. arg_position .. " is not of type number" )
    --assert(arg_position>0, "positional arg" .. arg_position .. "must be greater than 0") -- let them have 0
    self.no_dash.positional_args[arg_position] = arg_type
end

function argy:which_group(arg_name, index) --Return arg group from arg value and index
    if self.no_dash.positional_args[index]~=nil then return self.no_dash.positional_args
        elseif self.dash.args[arg_name]~=nil then return self.dash.args
        elseif self.dash.flags[arg_name]~=nil then return self.dash.flags
    end
end

function argy:parse_arg(argument,index)
    local group_funcs = {
        [self.dash.args] = {skip_amount= 2, arg_value =arg[index+1]},
        [self.no_dash.positional_args] = {skip_amount= 1,arg_value = arg[index]},
        [self.dash.flags] = {skip_amount= 1,arg_value = true}
    }
    local group = self:which_group(argument,index)
    return group_funcs[group] or error(argument .." is not a valid argument")
end

function argy:estab_fargs() 
    local parg = 1
    while parg <= #arg do
        arg_name = arg[parg]
        local parg_table_ret = argy:parse_arg(arg_name,parg)
        self.final_args[arg_name] = parg_table_ret.arg_value
        parg=parg+parg_table_ret.skip_amount
    end
end

argy:arg("--hi", "string")
argy:arg("--bi", "string")
print(argy.dash.args["--hi"])
argy:flag("-h", "string")
--argy:positional_arg(4, "string")
--argy:estab_pos_arg(1, "string")
--print(argy.args["--hi"])
--print(argy:which_group("--hi"))
argy:estab_fargs() 
print(argy.final_args["--hi"])
print(argy.final_args["--bi"])
print(argy.final_args["-h"])
--print(argy.final_args)