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
    if value and not old_value then
        self.len = self.len + 1
    elseif not value and old_value then
        self.len = self.len - 1
    end
    self.args[name] = value
    return old_value
end

function argy_methods:initalizers(assert_callback, push_val_where )
    local assert_callback = assert_callback or function() end
    local push_val_where = push_val_where or argy.outputs.final_args.args
    self[self.arg_type] = function(self,name,arg_ident, input_type, description) -- fix for the ":" funciton calls which pass self as first arg
        assert_callback(arg_ident,self.arg_type)
        self:set(arg_ident,name)
        push_val_where[name] = {type = input_type, arg_table = arg_table, description = description, value = nil}
    end
end

function strip_suffix(s, suffix)
    assert(string.sub(s,-#suffix) == suffix, suffix.." is not in string "..s)
    return string.sub(s, 1, -#suffix - 1)
end

function argy_methods:setup_inner_args()
    setmetatable (self.args, {
        __newindex = function (table,key,value)
        --print("name_type: ".. self[name].name_type.. ", arg: "..key)
        assert( type(key)==self.name_type , key.." is not of type "..self.name_type)
        rawset(table, key, value)
    end
    })
end

argy_top_level = {}
argy_top_level.__index = argy_top_level

function argy_top_level:new_arg_table(name,arg_type,name_type) 
    self[name] = setmetatable ({
        args = {},
        arg_type = arg_type or strip_suffix(name, "s"),
        name_type = name_type,
        len = 0
    }, argy_methods)
    self[name]:setup_inner_args()
    return self[name]
end

function argy_top_level:tables_to_func(check_func, ...) 
    local check_func = check_func or function() end
    for key,table in pairs(self) do
        local func_match = check_func(key,table, ...)
        if func_match  then 
            return key,table,func_match end
    end
end

function argy_top_level:which_table_has_arg(arg) 
    local arg_table_name,arg_table,arg_value = self:tables_to_func(
        function(key,table,...) return table:get(arg) end
    )
    return arg_table_name,arg_table,arg_value
end


function argy_top_level:set_arg_parser(name,parser_func)
    self[name].arg_parser = parser_func
end

setmetatable(argy.inputs, argy_top_level)
setmetatable(argy.outputs, argy_top_level)

argy.inputs:new_arg_table("positional_args","positional_arg","number")
argy.inputs:new_arg_table("args","arg","string")
argy.inputs:new_arg_table("flags","flag","string")

function parse_positional(position)
    local value,skip,table_index = arg[position],1,position
    return value,skip,table_index
end

function parse_arg(position)
    local value,skip,table_index = arg[position+1],2,arg[position]
    return value,skip,table_index 
end

function parse_flag(position)
    local value,skip,table_index = true,1,arg[position]
    return value,skip,table_index
end 

argy.inputs:set_arg_parser("positional_args", parse_positional)
argy.inputs:set_arg_parser("args", parse_arg)
argy.inputs:set_arg_parser("flags", parse_flag)
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

function argy.string_to_what(string, totype)
    assert(type(string)== "string", string.." is not of tpye string")
    return ({
        ["string"] = function(string) return string end,
        ["number"] = function(string) return tonumber(string) end,
        ["boolean"] = function(string) 
            return ({["1"] = true, ["0"] = false, ["true"] = true, ["false"] = false})[string] 
        end
    })[totype](string)
end

function argy:gen_fargs() 
    local position = 1
    while position <= #arg do
        local arg_string = arg[position]
        local table_name, table, arg_value = self.inputs:which_table_has_arg(position)
        if not table_name or not table or not arg_value  then
            table_name, table, arg_value = self.inputs:which_table_has_arg(arg_string)
        end
        if table then
            local value,skip,table_index = table.arg_parser(position)
            self.outputs.final_args:get(table:get(table_index)).value = value
            position=position+skip
        else
            self.outputs.unused_args:set(position,arg_string) 
            position=position+1
        end

    end
end

return argy --this is cool! The parser uses the return