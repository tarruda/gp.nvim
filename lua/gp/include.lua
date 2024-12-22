local M = {}

-- Split a context insertion command into its component parts
M.cmd_split = function(cmd)
	return vim.split(cmd, ":", { plain = true })
end

local function read_file(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end
	local content = file:read("*all")
	file:close()
	return content
end

-- Process includes in a single line
local function process_line_includes(line)
	local file_path = line:match("^@file:(.+)$")
	if file_path then
		local content = read_file(file_path)
		if type(content) == 'string' then
			return ('file:%s\n```\n%s\n```'):format(file_path, content), true
		else
			error("Unable to read file " .. file_path)
		end
	end
	return line, false
end

M.process_includes = function(msg)
	local count = 0
	local lines = vim.split(msg, "\n", { plain = true, trimempty = true })
	local result = {}

	for _, line in ipairs(lines) do
		local replacement, processed = process_line_includes(line)
		table.insert(result, replacement)
		if processed then
			count = count + 1
		end
	end

	if count > 0 then
		return table.concat(result, "\n")
	else
		return msg
	end
end

return M
