TableUtil = {}
function TableUtil.FindKeyByValue(t,v)
	for key,value in pairs(t) do
		if v == value then
			return key;
		end
	end
    return nil;
end

function TableUtil:GetValue(t,func)
    for k,v in pairs(t) do
        local b = func(v);
        if(b)then
            return v;
        end
    end
    return nil;
end

function TableUtil.ArrayCopy(dest,src)
    for i=1,#src do
        dest[i] = src[i]
    end
end

function TableUtil.HashToArray(hash)
    local arr = {}
    for k,v in pairs(hash) do
        arr[#arr + 1] = v
    end
    return arr
end

function TableUtil.EraseEndZero(num)
    local data1 = math.floor(num)
    local data2 = math.floor(num*10)/10
    if(data2 == data1)then
        return data1
    else
        return num
    end
end

function TableUtil.InsertArray(dest, src)
    if(type(dest)=="table")then
        if(src)then
            if(type(src) == "table")then
                for i=1,#src do
                    table.insert(dest, src[i])
                end
            else
                table.insert(dest, src);
            end
        end
    end
    return dest;
end

function TableUtil.HasValue(t,v)
    local key = TableUtil.FindKeyByValue(t,v)
    return key ~= nil;
end

function TableUtil.IndexOf(tab,obj)
    for _, o in pairs(tab) do
        if o == obj then
            return _
        end
    end
    return 0
end

function TableUtil.ArrayIndexOf(tab,obj)
    for i=1,#tab do
        if tab[i]==obj then
            return i
        end
    end
    return 0
end

function TableUtil.Remove(tab,obj)
    for _, o in pairs(tab) do
        if o == obj then
            table.remove(tab, _)
            return _
        end
    end
    return 0
end

function TableUtil:TableToStr(t)
    local s = ""
    if(t == nil)then
        return "nil".."\n";
    end
    for k, v in pairs(t) do
         if type(v) ~= "table" then
             if v ~= nil then
                s = s..k.."_"..tostring(v).."\n";
             else
                s = s..k.."_".."nil".."\n";
             end
         else
             s = s..k.."_"..TableUtil:TableToStr(v);
         end
    end
    return s
end

function TableUtil.Print222(msg)
--    MyLuaSrv.EnablePrint = true
    if(MyLuaSrv.EnablePrint) then
        local out = {}
        local write = function(value)
            out[#out + 1] = value
        end
        TableUtil.innerPrint(write, msg)
        Debug.Log(table.concat(out))
    end
end

function TableUtil.Print(msg)
end

function TableUtil.innerPrint ( write,t )  
	if(MyLuaSrv.EnablePrint) then
		local print_r_cache={}
		local function sub_print_r(t,indent)
			if t==nil then
				write(indent.."*".."nil")
			elseif (print_r_cache[tostring(t)]) then
				write(indent.."*"..tostring(t))
			else
				print_r_cache[tostring(t)]=true
				if (type(t)=="table") then
					if t.ListFields ~= nil then     
						write(indent..tostring(t).."\n")
					else
						for pos,val in pairs(t) do
							if type(pos)~="table" then
	 
								-- print("pos "..tostring(pos).." val type"..type(val)) 
								-- if type(val)=="table" then
								--     print("table pos "..tostring(pos))
								--     if pos=="class" then 
								--         print("table val "..tostring(val)) 
								--     end
									-- userData class data
								-- end

                                if (type(val)=="table") then
                                    -- if pos == "userData" or pos == "class" or pos == "data" then
                                        write(indent.."["..pos.."] => "..tostring(t).." {".."\n")
                                        sub_print_r(val,indent..string.rep("  ",string.len(pos)+8))
                                        write(indent..string.rep(" ",string.len(pos)+6).."}".."\n")
                                    -- end
                                elseif (type(val)=="string") then
                                    write(indent.."["..pos..'] => "'..val..'"'.."\n")
                                elseif (type(val)~="function") then
                                    write(indent.."["..pos.."] => "..tostring(val).."\n")
                                end
                            end
                        end
                    end
                else
                    write(indent..tostring(t).."\n")
                end
            end
        end

        if t == nil then
            write("nil".."\n")
        elseif (type(t)=="table") then
            if t.ListFields ~= nil then
                write(tostring(t).."\n")
            else
                write(tostring(t).." {".."\n")
                sub_print_r(t,"  ")
                write("}".."\n")
            end
        else
            sub_print_r(t,"  ".."\n")
        end
    end
end

function TableUtil.filter(func, tbl)
     local newtbl= {}
     for i,v in pairs(tbl) do
         if func(v) then
         newtbl[i]=v
         end
     end
     return newtbl
 end

function TableUtil.deepcopy(tDest, tSrc)  
    for key,value in pairs(tSrc) do
        if type(value)=='table' and value["spuer"]==nil then
            tDest[key] = {}
            TableUtil.deepcopy(tDest[key],value)
        else
            tDest[key]=value
        end
    end

end

function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function TableUtil.split(szFullString, szSeparator)  
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
       break
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function innerString(root)
    if(MyLuaSrv.EnablePrint and ApplicationInfo.IsRunOnEditor()) then
        if(type(root) ~= "table")then
            return tostring(root);
        else
            local cache = {[root] = "." }
            local function _dump(t,space,name)
                local temp = {}
                for k,v in pairs(t) do
                    local key = tostring(k)
                    if(cache[v])then
                        local tempStr = string.format("[%s]=> %s", key, cache[v]);
                        table.insert(temp, tempStr)
                    elseif type(v) == "table" then
                        local new_key = name .. "." .. key
                        cache[v] = new_key
                        local space = space..string.rep(" ",#key+5);
                        local tableStr = _dump(v, space, new_key);
                        local tempStr = string.format("[%s]=>\n%s%s", key , space, tableStr);
                        table.insert(temp, tempStr)
                    else
                        local tempStr = string.format("[%s]=> %s", key, tostring(v));
                        table.insert(temp, tempStr)
                    end
                end
                return string.format("%s", table.concat(temp,"\n"..space)); 
            end
           return _dump(root, "","Table")
        end
    end
end

local logParam = {};
function helplog( arg1, arg2, arg3, arg4, arg5 )
    _helplog( "<color=yellow>", arg1, arg2, arg3, arg4, arg5 );
end

function redlog( arg1, arg2, arg3, arg4, arg5 )
    _helplog( "<color=red>", arg1, arg2, arg3, arg4, arg5 );
end

function _helplog( msg, arg1, arg2, arg3, arg4, arg5 )
    if(ROLogger.enable)then
        logParam[1] = arg1
        logParam[2] = arg2
        logParam[3] = arg3
        logParam[4] = arg4
        logParam[5] = arg5

        for i=1,#logParam do
            msg = msg..LogUtility.ToString(logParam[i])
            if(i<#logParam)then
                msg = msg.."  |  "
            else
                msg = msg.."</color>"
            end
        end
        LogUtility.Info( msg )

        TableUtility.ArrayClear(logParam)
    end
end

function xdlog(arg1, arg2, arg3, arg4, arg5 )
    _helplog( "<color=lime>", arg1, arg2, arg3, arg4, arg5 );
end

function printData(key,data) 
    redlog(key)
    -- Debug.Log(data)
    ----[[
	if(MyLuaSrv.EnablePrint) then
        print(innerString(data));   
    end
    --]]
end

function printOrange(data, ...)
    helpPrint(data, "orange", ...);
end

function printRed(data, ...)
    helpPrint(data, "red", ...);
end

function printGreen(data, ...)
    helpPrint(data, "green", ...);
end

function helpPrint(data, color, ...)
    printByColor(data, color);
    local parama = {...};
    for i=1,#parama do
        printByColor(parama[i], color);
    end
end

function printByColor(data, color)
    local dataStr = "";
    if(type(data) == "table")then
        dataStr = innerString(data);
    else
        dataStr = tostring(data)
    end
    dataStr = string.format("<color=%s>%s</color>", color, dataStr);
--    print(dataStr)
    -- Debug.Log(dataStr);
end

function TableUtil.unserialize(lua)  
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

function TableUtil.Array2Vector3(array)
    return LuaVector3(array[1] or 0, array[2] or 0, array[3] or 0)
end

function math.clamp(num,min,max)
    if (num < min) then
        num = min;
    elseif(num > max)then
        num = max
    end
    return num
end

function math.randomFloat(min,max)
    return math.random() * (max - min) + min
end