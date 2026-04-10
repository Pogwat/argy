-- cmd -a "b"    -c "d"
local ahandler = function(table,key) return table[key] .." is not a value in " .. table end
argy = {
        positional_args = {
            __arg_type = "positional_argument",
            __index = ahandler,
            __index_type = "number"
        }, -- arg,
        args = {
            __arg_type = "argument",
            __index = ahandler,
            __index_type = "string"
        }, -- -a --arg
        flags = {
            __arg_type = "flag",
            __index = ahandler,
            __index_type = "string"
        }, -- -f
        final_args = {}
}

function argy:initalizers(arg_table, assert_callback)
    assert_callback = assert_callback or function() end
    return function(self,name,arg_ident, input_type) -- fix for the ":" funciton calls which pass self as first arg
    local arg_type = arg_table.__arg_type
    local arg_index_type = arg_table.__index_type
    assert(type(arg_ident) == arg_index_type, arg_type.." "..arg_ident.." is not of type "..arg_index_type )
    assert_callback(arg_ident,arg_type)
    arg_table[arg_ident] = name
    self.final_args[name] = {type = input_type, arg_table = arg_table}
    end
end

function argy.assert_arg(arg_string,arg_type)  
    assert(string.len(arg_string)>=2, arg_type.." "..arg_string .. " is not of size >2")
    assert(
        string.find(arg_string, "^%-%-") or string.find(arg_string, "^%-"), 
        arg_type.." dosent start with -- or -")
end

function argy.assert_flag(arg_string,arg_type)
    assert(string.len(arg_string) == 2, arg_type.." "..arg_string.." is not of size: "..2)
    assert(string.find(arg_string, "^%-"), arg_type.." dosent start with -")
    assert(string.find(arg_string, "^%-%-")==nil, arg_type.." ".. arg_string.." name is -")
end

argy.positional_arg = argy:initalizers(argy.positional_args)
argy.arg = argy:initalizers(argy.args, argy.assert_arg)
argy.flag = argy:initalizers(argy.flags, argy.assert_flag)

function argy:get(name) return self.final_args[name] end

function argy:is_string_arg_or_flag(arg_string)
    if self.args[arg_string]~=nil then return self.args.__arg_type end
    if self.flags[arg_string]~=nil then return self.flags.__arg_type end
end

function argy:name_arg_type(name) return 
    self.final_args[name].arg_table.__arg_type
end

function argy:is_index_pos_arg(index) 
    if self.positional_args[index]~=nil then return  self.positional_args.__arg_type end
end

function argy:handle_arg_type(arg_type, position)
    local types = {
        [self.args.__arg_type] = {value = arg[position+1]  , skip =2, table = self.args, table_index = arg[position]},
        [self.flags.__arg_type] =  {value = true, skip = 1, table = self.flags, table_index = arg[position]},
        [self.positional_args.__arg_type] =  {value = arg[position], skip = 1, table = self.positional_args, table_index = position }
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

return argy --this is cool! The parser uses the return