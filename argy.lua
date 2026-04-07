-- cmd -a "b"    -c "d"
argy = {
    args = {},
    positional_args = {},
    flags = {},
    final_args = {}
}

function argy:arg_func_gen(arg_name_type, fixed_arg_type) 
    return function (self,arg_name,arg_type)
        assert(type(arg_name) == arg_name_type, arg_name .. " is not a " .. arg_name_type)
        self.args[arg_name] = arg_type
    end
end

argy.estab_pos_arg = argy:arg_func_gen("number")
argy.estab_flag = argy:arg_func_gen("string","boolean") 
argy.estab_arg = argy:arg_func_gen("string") 

function argy:which_group(arg, index) --Return arg group from arg value and index
    if self.args[arg]~=nil then return self.args
        elseif self.positional_args[index]~=nil then return self.positional_args
        elseif self.flags[arg]~=nil then return self.flags
    end
end

function argy:parse_arg(argument,index)
    local group_funcs = {
        [self.args] = {skip_amount= 2, arg_value =arg[index+1]},
        [self.positional_args] = {skip_amount= 1,arg_value = arg[index]},
        [self.flags] = {skip_amount= 1,arg_value = true}
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

argy:estab_arg("--hi", "string")
argy:estab_arg("--bi", "string")
--argy:estab_pos_arg(1, "string")
--print(argy.args["--hi"])
--print(argy:which_group("--hi"))
argy:estab_fargs() 
print(argy.final_args["--hi"])
print(argy.final_args["--bi"])
--print(argy.final_args)