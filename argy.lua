--- @module argy
argy = {
    inputs = {},
    outputs = {}
}
-- cmd -a "b"    -c "d"

argy_methods = {}
argy_methods.__index = argy_methods


--- Gets a arg from a argy io subtable's args table
--- @param name The Name of the argument
--- @return Value of the argument

function argy_methods:get(name) 
    return self.args[name]
end

--- Sets a arg from a argy io subtable's args table
--- @param name The Name of the argument to set
--- @param value The new Value of the argument
--- @return The Previous Value of the argument

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

--- Retruns a argument initalizer for whatever argy io subtable you call it with
--- This is a funciton generator
--- @param[opt = function() end] assert_callback The assert function to run whenever a argument is created
--- ,this function is provided the arg_string and the type of the io subtable in that order  
--- @param[opt = argy.outputs.final_args.args] push_val_where The table to push a arguments content.
--- @return The Generated function as function(self,name,arg_ident, input_type, description)

function argy_methods:initalizers(assert_callback, push_val_where )
    local assert_callback = assert_callback or function() end
    local push_val_where = push_val_where or argy.outputs.final_args.args
    self[self.arg_type] = function(self,name,arg_ident, input_type, description) -- fix for the ":" funciton calls which pass self as first arg
        assert_callback(arg_ident,self.arg_type)
        self:set(arg_ident,name)
        push_val_where[name] = {type = input_type, arg_table = arg_table, description = description, value = nil}
    end
end

function string:strip_suffix(s, suffix)
    assert(string.sub(s,-#suffix) == suffix, suffix.." is not in string "..s)
    return string.sub(s, 1, -#suffix - 1)
end

--- Sets up metetable for a argy io subtable's arguments i.e. argy.inputs.my_agry_type.args
function argy_methods:setup_inner_args()
    setmetatable (self.args, {
        __newindex = function (table,key,value)
        assert( type(key)==self.name_type , key.." is not of type "..self.name_type)
        rawset(table, key, value)
    end
    })
end

argy_top_level = {}
argy_top_level.__index = argy_top_level

--- Creates a new arg table in either the input or output of argy
--- @param name the name of the table
--- @param arg_type the argument type of the table 
--- @param name_type the type of the argument string identifier
--- @param arg_parser   the parser function for every argument
--- @return the argument table
function argy_top_level:new_arg_table(name,arg_type,name_type,arg_parser) 
    self[name] = setmetatable ({
        args = {},
        arg_type = arg_type or string:strip_suffix (name, "s"),
        name_type = name_type,
        arg_parser = arg_parser,
        len = 0
    }, argy_methods)
    self[name]:setup_inner_args()
    return self[name]
end

--- Applys a function to every field in a argy io subtable
--- if a match is found the current key, table and function's return are returned 
--- @param check_func function to apply to each table recives key and table
--- @return key,table,func_match
function argy_top_level:apply_func_to_tables(check_func, ...) 
    for key,table in pairs(self) do
        local func_match = check_func(key,table, ...)
        if func_match  then return key,table,func_match end
    end
end


--- A Wrapper around argy_top_level:apply_func_to_tables(check_func, ...),
--- that checks each table for a argument and return the key,table and argument value if found
--- @param arg
--- @return key,table,arg_value
--- @see argy_top_level:apply_func_to_tables
function argy_top_level:which_table_has_arg(arg) 
    return self:apply_func_to_tables(function(_,table,_) return table:get(arg) end)
end

function parser_template(value,skip,use_position_as_key)
    return function (position)
        local value= value or arg[position+skip-1]
        local index = arg[position]
        if use_position_as_key then index = position end
        return  value,skip,index
    end
end

setmetatable(argy.inputs, argy_top_level)
setmetatable(argy.outputs, argy_top_level)

argy.inputs:new_arg_table("positional_args","positional_arg","number",parser_template(nil,1,true))
argy.inputs:new_arg_table("args","arg","string",parser_template(nil,2,nil))
argy.inputs:new_arg_table("flags","flag","string",parser_template(true,1,nil))
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

-- function string:to_type(string, totype)
--     assert(type(string)== "string", string.." is not of tpye string")
--     return ({
--         ["string"] = function(string) return string end,
--         ["number"] = function(string) return tonumber(string) end,
--         ["boolean"] = function(string) 
--             return ({["1"] = true, ["0"] = false, ["true"] = true, ["false"] = false})[string] 
--         end
--     })[totype](string)
-- end


--- Generate final argument's in self.outputs.final_args
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
            self.outputs.final_args:get(arg_value).value = value
            position=position+skip
        else
            self.outputs.unused_args:set(position,arg_string) 
            position=position+1
        end

    end
end

return argy --this is cool! The parser uses the return