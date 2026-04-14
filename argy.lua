-- cmd -a "b"    -c "d"
argy = {
    inputs = {},
    outputs = {}
}

argy_methods = {}
argy_methods.__index = argy_methods

function argy_methods:get(name) 
    return self.args[name]
end

function argy_methods:set(name,value)
    local old_value = self:get(name)
    if value~=nil then
        if self:get(name)==nil then 
            self.len = self.len+1
        end
        assert(type(name) == self.name_type, name.." is not of type "..self.name_type)
    elseif value == nil and self.args[name] ~= nil then
        self.len = self.len - 1
    end
    self.args[name] = value
    return old_value
end

function argy_methods:initalizers(assert_callback, push_val_where )
    local assert_callback = assert_callback or function() end
    local push_val_where = push_val_where or argy.outputs.final_args.args
    self[self.arg_type] = function(self,name,arg_ident, input_type, description) -- fix for the ":" funciton calls which pass self as first arg
    assert(type(arg_ident) == self.name_type, self.arg_type.." "..arg_ident.." is not of type "..self.name_type )
    assert_callback(arg_ident,self.arg_type)
    self:set(arg_ident,name)
    push_val_where[name] = {type = input_type, arg_table = arg_table, description = description, value = nil}
    end
end

argy_top_level = {}
argy_top_level.__index = argy_top_level

function argy_top_level:new_arg_table(name,arg_type,name_type, index_func) 
    self[name] = setmetatable ({
        args = {},
        arg_type = arg_type,
        name_type = name_type,
        len = 0
    }, argy_methods)
    return self[name]
end

function argy_top_level:check_tables(value) 
    local arg_type = type(value)
    for key,table in pairs(self) do
        if type(table) == "table" and table.name_type==arg_type and table.args[value] then
            return table
        end
    end
end

setmetatable(argy.inputs, argy_top_level)
setmetatable(argy.outputs, argy_top_level)

argy.inputs:new_arg_table("positional_args","positional_arg","number")
argy.inputs:new_arg_table("args","arg","string")
argy.inputs:new_arg_table("flags","flag","string")
argy.outputs:new_arg_table("unused_args","unused_arg","number")
argy.outputs:new_arg_table("final_args","final_arg","string")

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

argy.inputs.positional_args:initalizers()
argy.inputs.args:initalizers(argy.assert_arg)
argy.inputs.flags:initalizers(argy.assert_flag)

function argy:is_string_arg_or_flag(arg_string)
    if self.inputs.args.args[arg_string]~=nil then return self.inputs.args end
    if self.inputs.flags.args[arg_string]~=nil then return self.inputs.flags end
end

function argy:is_index_pos_arg(index) 
    if self.inputs.positional_args.args[index]~=nil then return  self.inputs.positional_args end
end

function argy.inputs:handle_arg_type(arg_type, position)
    local types = {
        [self.args] = {value = arg[position+1]  , skip =2,  table_index = arg[position]},
        [self.flags] =  {value = true, skip = 1,  table_index = arg[position]},
        [self.positional_args] =  {value = arg[position], skip = 1, table_index = position }
    }
    return types[arg_type]
end

function argy:gen_fargs() 
    local position = 1
    while position <= #arg do
        local arg_string = arg[position]
        local arg_table = self:is_index_pos_arg(position) or self:is_string_arg_or_flag(arg_string) -- or error(arg_string .." matched no type")
        if arg_table~=nil then
            local handler = self.inputs:handle_arg_type(arg_table, position)
            local arg_name = arg_table.args[handler.table_index] or error(arg_string .. " did not match a table")
            self.outputs.final_args.args[arg_name].value = handler.value 
            position=position+handler.skip
        else
            self.outputs.unused_args:set(position,arg_string) 
            position=position+1
        end

    end
end

return argy --this is cool! The parser uses the return