string.split = function(value,pattern,f)
	local out = {}
	for v in string.gmatch(value,pattern) do
		out[#out + 1] = (f and f(v) or v)
	end
	return out
end

table.find = function(list,value)
	for k,v in next,list do
		if v == value then
			return true,k
		end
	end
	return false
end

table.random = function(t)
	return (type(t) == "table" and t[math.random(#t)] or math.random())
end

deactivateAccents=function(str)
	local letters = {a = {"á","â","à","å","ã","ä"},e = {"é","ê","è","ë"},i = {"í","î","ì","ï"},o = {"ó","ô","ò","õ","ö"},u = {"ú","û","ù","ü"}}
	for k,v in next,letters do
		for i = 1,#v do
			str = string.gsub(str,v[i],tostring(k))
		end
	end
	return str:gsub("%p*","")
end

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep("\t", depth)

    if name then tmp = tmp .. (type(name) == "number" and string.format("[%s]",name) or string.format('["%s"]',name)) .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep("\t", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    end

    return tmp
end
