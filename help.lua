require "argy"

argy:flag("help", "-h", "boolean","help")

local program_name = arg[0]
local help = program_name
local exclude_args={__arg_type=true, __index=true ,__index_type=true, __len=4}
local earg_len = exclude_args["__len"]

function argy:gen_desc_lines(arg_table)
    local args_buf = ""
    for arg_string,arg_name in pairs(arg_table) do --Order is not deterministic so args are randomly order in help
        if exclude_args[arg_string] == nil then
            local description = self.final_args[arg_name].description or ""
            args_buf = args_buf..arg_string.."\n  "..description.."\n\n"
        end
    end
    return args_buf
end

function argy:gen_help()
    local args_len = self.args["__len"]
    local flags_len = self.flags["__len"] 

    local flags_buf =  "FLAGS:\n" .. argy:gen_desc_lines(self.flags) or ""
    local args_buf =  "ARGS:\n" .. argy:gen_desc_lines(self.args)  or ""

    if args_len>earg_len then help = help .. " [ARGUMENTS]" end
    if flags_len>earg_len then help = help .. " [FLAGS]" end
    help = help.."\n".. flags_buf .. args_buf

    if argy:get("help")~=nil then
        print(help)
        os.exit()
    end

end

-- cmd [OPTIONS] [FLAGS] [POSITIONAL]

-- arg 
-- arg_description

return argy