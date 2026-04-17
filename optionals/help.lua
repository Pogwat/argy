require "argy"

argy.inputs.flags:flag("help", "-h", "boolean","help")

local program_name = arg[0]
local help = program_name

local exclude_args= {
    args = {__arg_type=true, __index=true ,__index_type=true},
    len=4
}

function argy:gen_desc_lines(arg_table)
    local args_buf = ""
    for arg_string,arg_name in pairs(arg_table.args) do --Order is not deterministic so args are randomly order in help
        if exclude_args.args[arg_string] == nil then
            local description = self.outputs.final_args.args[arg_name].description or ""
            args_buf = args_buf..arg_string.."\n  "..description.."\n\n"
        end
    end
    return args_buf
end

function argy:gen_help()
    arguments_v_exclude_contains, arguments_v_exclude_not_contains = check_table_for_a_tables_keys(self.inputs.args.args, exclude_args)
    flags_v_exclude_contains, flags_v_exclude_not_contains = check_table_for_a_tables_keys(self.inputs.flags.args, exclude_args)
    if arguments_v_exclude_contains.len~=0 then help = help .. " [ARGUMENTS]" end
    if flags_v_exclude_contains.len~=0 then help = help .. " [FLAGS]" end
    
    local flags_buf =  "FLAGS:\n" .. argy:gen_desc_lines(self.inputs.flags) or ""
    local args_buf =  "ARGS:\n" .. argy:gen_desc_lines(self.inputs.args)  or ""
    help = help.."\n".. flags_buf .. args_buf

    if argy.outputs.final_args:get("help").value~=nil then
        print(help)
        os.exit()
    end

end

function check_table_for_a_tables_keys(table_to_check, refrence_table)
    local contains_table = {kv_pairs = {},len = 0}
    local dosent_contains_table = {kv_pairs = {},len = 0}
    for k,v in pairs(refrence_table) do
        
        if table_to_check[k] then 
            contains_table.kv_pairs[k] = table_to_check[k] 
            contains_table.len = contains_table.len+1
        else
            dosent_contains_table.kv_pairs[k] = table_to_check[k] 
            dosent_contains_table.len = dosent_contains_table.len+1
        end

    end
    return contains_table, dosent_contains_table
end




-- cmd [OPTIONS] [FLAGS] [POSITIONAL]

-- arg 
-- arg_description

return argy