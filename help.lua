require "argy"

argy:flag("help", "-h")


local program_name = arg[0]
local help = program_name
local help_buf = ""
local exclude_args={__arg_type=true, __index=true ,__index_type=true, __len=4}
local earg_len = exclude_args["__len"]

function argy:gen_help()
    
    local args_len = self.args["__len"]
    local flags_len = self.flags["__len"]
    
    --if #self.args>earg_count then help = help .. "[ARGUMENTS]" end
    --if #self.flags>earg_count then help = help .. "[FLAGS]" end
    local args_buf = ""
    for arg_string,arg_name in pairs(self.args) do
        if exclude_args[arg_string] == nil then
            args_buf = args_buf..arg_string.."\n"
        end
    end


    local flags_buf = ""
    for arg_string,arg_name in pairs(self.flags) do
        if exclude_args[arg_string] == nil then
            flags_buf = flags_buf..arg_string.."\n"
        end
        
    end

    help_buf = "FLAGS:\n" .. flags_buf .. "ARGS:\n" .. args_buf


    if args_len>earg_len then help = help .. " [ARGUMENTS]" end
    if flags_len>earg_len then help = help .. " [FLAGS]" end
    help = help.."\n"
    --print(help .. help_buf)

    if argy:get("help")~=nil then
        print(help .. help_buf)
        os.exit()
    end

end

-- cmd [OPTIONS] [FLAGS] [POSITIONAL]

-- arg 
-- arg_description

return argy