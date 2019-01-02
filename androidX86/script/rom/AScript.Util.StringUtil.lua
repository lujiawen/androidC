StringUtil = {};

function StringUtil.utf8_tail(n, k)  
  local u, r=''  
  for i=1,k do  
    n,r = math.floor(n/0x40), n%0x40  
    u = string.char(r+0x80) .. u  
  end  
  return u, n  
end  
   
function StringUtil.to_utf8(a)  
  local n, r, u = tonumber(a)  
  if n<0x80 then                        -- 1 byte  
    return string.char(n)  
  elseif n<0x800 then                   -- 2 byte  
    u, n = StringUtil.utf8_tail(n, 1)  
    return string.char(n+0xc0) .. u  
  elseif n<0x10000 then                 -- 3 byte  
    u, n = StringUtil.utf8_tail(n, 2)  
    return string.char(n+0xe0) .. u  
  elseif n<0x200000 then                -- 4 byte  
    u, n = StringUtil.utf8_tail(n, 3)  
    return string.char(n+0xf0) .. u  
  elseif n<0x4000000 then               -- 5 byte  
    u, n = StringUtil.utf8_tail(n, 4)  
    return string.char(n+0xf8) .. u  
  else                                  -- 6 byte  
    u, n = StringUtil.utf8_tail(n, 5)  
    return string.char(n+0xfc) .. u
  end  
end  
   
function StringUtil.sto_utf8(s)
  return string.gsub(s, '&#(%d+);', StringUtil.to_utf8)  
end

--startIndex can't bigger endIndex
--endIndex can be nil 
local tab = {}
function StringUtil.getTextByIndex( str,startIndex,endIndex)
    if(endIndex and endIndex < startIndex)then
        printRed("error!startIndex can't bigger endIndex")
        return ""
    end

    TableUtility.ArrayClear(tab);
    for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        tab[#tab+1] = uchar 
    end
    
    if(endIndex and endIndex > #tab or not endIndex)then
        endIndex = #tab
    end
    return table.concat(tab, "", startIndex, endIndex)
end

function StringUtil.getTextLen( str)
    -- body
    ----[[ todo xde str 可能为空
    if str == nil then
      redlog('str is nil')
      do return 0 end
    end
    --]]
    local lenInByte = #str
    local len = 0
    local i = 1
    local curByte
    local byteCount = 1
    while (i <= lenInByte) 
    do
        curByte = string.byte(str, i)
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
         
        i = i + byteCount
        len = len + 1                                          
    end
    return len
end

function StringUtil.StringToCharArray( str)
    -- body
    local result = 0
    local _, count = string.gsub(str, "[^\128-\193]", "")
    local tab = {}
    for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        tab[#tab+1] = uchar 
    end
    return tab
end

function StringUtil.SubString( str,startIndex,length)
    -- local result = 0
    -- local _, count = string.gsub(str, "[^\128-\193]", "")
    -- local tab = {}
    -- for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do 
    --     tab[#tab+1] = uchar 
    -- end
    -- local max = math.min(#tab,startIndex + length-1)
    -- local str = ""
    -- for i = startIndex,max do
    --   str = str..tab[i]
    -- end
    local maxIndex = math.max(StringUtil.ChLength(str), startIndex + length-1);
    return StringUtil.Sub(str,startIndex,maxIndex)
end

function StringUtil.Sub(str, startIndex, endIndex)
  local dropping = string.byte(str, endIndex+1)    
  if not dropping then return str end    
  if dropping >= 128 and dropping < 192 then    
    return StringUtil.Sub(str, startIndex, endIndex-1)    
  end
  return string.sub(str, startIndex, endIndex);
end

-- 中文字符串的长度
function StringUtil.ChLength(str)
  return #(string.gsub(str, '[\128-\255][\128-\255]',' '))
end

function StringUtil.AnalyzeDialogOptionConfig(str)
  local optionformat = "(%{([^%{%}]+)%,(%d+)%})";
  local result = {};
  for _,text,id in string.gmatch(str, optionformat) do
    local optionConfig = {};
    optionConfig.id = tonumber(id);
    optionConfig.text = text;
    table.insert(result, optionConfig);
  end
  if(#result==0)then
    local optionConfig = {};
    optionConfig.text = str;
    optionConfig.id = 0;
    table.insert(result, optionConfig);
  end
  return result;
end

function StringUtil.Split(str, delimiter)
  if str==nil or str=='' or delimiter==nil then
    return nil
  end
  
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function StringUtil.Json2Lua( str )
  -- body
  local luaString = LuaUtils.JsonToLua(str)
  if nil ~= luaString then
    luaString = "return "..luaString
    local luaFunc = loadstring(luaString)
    if nil ~= luaFunc then
      local luaObject = luaFunc()
      return luaObject
    end
  else
    print("luaString is nil")
  end
end

function StringUtil.Chsize(char)
    if not char then
        print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如Utf8len("1你好") => 3
function StringUtil.Utf8len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + StringUtil.Chsize(char)
        len = len +1
    end
    return len
end

function StringUtil.Replace(str,searchStr,replaceStr)
    local replaceStr = string.gsub(replaceStr,"%%","%%%%")
    return string.gsub(str,searchStr,replaceStr)
end

function StringUtil.NumThousandFormat(num, deperator)
   if deperator == nil then  
        deperator = ","  
    end  
    deperator = deperator or ","

    local result = "";
    num = math.floor(num);
    local str = tostring( math.abs(num) );
    local slength = string.len(str);
    for i=1, slength do
        result = string.char(string.byte(str, slength + 1 - i))..result;
        if( i % 3 == 0 and i < slength)then
           result = deperator..result; 
        end
    end 
    return num < 0 and "-"..result or result  
end

local RomansMap = {
	{1000, "M"},
	{900, "CM"}, 
	{500, "D"},
	{400, "CD"},
	{100, "C"},
	{90, "XC"},
	{50, "L"},
	{40, "XL"},
	{10, "X"},
	{9, "IX"},
	{5, "V"},
	{4, "IV"},
	{1, "I"} 
}
function StringUtil.IntToRoman(num)
	local k = num;
	local roman, val, let = "";
	for _, v in ipairs(RomansMap) do 
		val, let = v[1], v[2];
		while k >= val do
			k = k - val;
			roman = roman .. let;
		end
	end
	return roman;
end

function StringUtil.FormatTime2TimeStamp( formatTime )
  local t = {};
  local ifs = string.split(formatTime , " ");
  local d1 = string.split(ifs[1], "-");
  t.year, t.month, t.day = tonumber(d1[1]), tonumber(d1[2]), tonumber(d1[3]);
  local d2 = string.split(ifs[2], ":");
  t.hour, t.min, t.sec = tonumber(d2[1]), tonumber(d2[2]), tonumber(d2[3]);
  return os.time(t);
end

function StringUtil.IsEmpty( content )
  -- body
  if(not content or content == "")then
    return true
  end
end

function StringUtil.LastIndexOf( content , findStr )
  local found = content:reverse():find(findStr:reverse(), nil, true)
  if found then
      return content:len() - findStr:len() - found + 2 
  else
      return found
  end
end