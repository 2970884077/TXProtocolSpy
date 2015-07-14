--[=======[
-------- -------- -------- --------
            txline����
-------- -------- -------- --------
]=======]
--[=======[
��
    txline    txline:new                ( );  --txline�̳�xline������ֻ���޸ĳ�Ĭ�ϴ��
]=======]

txline            = { }
setmetatable(txline, xline);
txline.__index = txline;

function txline:new( )
  local nline = {};
  self = self or txline;

  setmetatable(nline, self);
  self.__index = self;
  
  nline.line            = self.line         or    "";
  nline.net_flag        = self.net_flag     or    true;
  nline.head_size       = self.head_size    or    2;
  nline.head_self       = self.head_self    or    false;
  nline.deal_zero_end   = self.deal_zero_end or   false;

  if nline.net_flag then
    nline.nets = ">";
  else
    nline.nets = "<";
  end

  return nline;
end

--[=======[
    string    txline:get_key            ( );  --��ȡһ��TxKey
    string    txline:set_rand_key       ( );  --����һ�������TxKey
]=======]
function txline:get_key()
  return self:get_ascii_str(TXP.TEAN_Key_Size);
end

function txline:set_rand_key()
  local key = "";
  for k = 1, TXP.TEAN_Key_Size do
      key = key .. string.char(xrand(0xFF) + 1);
  end
  self:set_ascii_str(key);
  return key;
end
--[=======[
    txline.gk       = txline.get_key;
    txline.srk      = txline.set_rand_key;
]=======]
txline.gk       = txline.get_key;
txline.srk      = txline.set_rand_key;


-------- -------- -------- --------
-------- -------- -------- --------
-------- -------- -------- --------
--[=======[
-------- -------- -------- --------
                txspyline����
-------- -------- -------- --------
]=======]
--[=======[
��
    txspyline txspyline:new             ( );  --txspyline�̳�txline���������level��
]=======]
txspyline = { };
setmetatable(txspyline, txline);
txspyline.__index = txspyline;


function txspyline:new(nline)
  local nline = {};
  self = self or txspyline;

  setmetatable(nline, self);
  self.__index = self;
  
  nline.line            = self.line         or    "";
  nline.net_flag        = self.net_flag     or    true;
  nline.head_size       = self.head_size    or    2;
  nline.head_self       = self.head_self    or    false;
  nline.deal_zero_end   = self.deal_zero_end or   false;

  if nline.net_flag then
    nline.nets = ">";
  else
    nline.nets = "<";
  end

  nline.level = self.level or 0;      --������������
  return nline;
end

--[=======[
    txspyline txspyline:level_increase  ( );  --����������
    txspyline txspyline:level_decrease  ( );  --����������
]=======]
function txspyline:level_increase()
  self.level = self.level + 1;
  return self;
end
function txspyline:level_decrease()
  self.level = self.level - 1;
  if self.level < 0 then
      self.level = 0;
  end
  return self;
end

--[=======[
    string    txspyline:print_blanks    ( );  --���������Σ�' '*levle*6
    string    txspyline:print_names     ( );  --�����ʽ�����֣�ǰ�ÿո�
]=======]
function txspyline:print_blanks()
  return string.rep(' ', self.level * 6);
end
function txspyline:print_names(name)
  name  = name or "";
  return self:print_blanks() .. string.format("%-19s", name .. ':');
end
--[=======[
    --�������֣���ȡ�����һ����ʽ�������ͣ�ͬʱ����ֵ
    string, v txspyline:print_get_byte  ( name );
    string, v txspyline:print_get_word  ( name );
    string, v txspyline:print_get_dword ( name );
]=======]
function txspyline:print_get_byte(name)
  local v = self:get_byte();
  return self:print_names(name) .. string.format("%02X [%u]\r\n", v, v), v;
end
function txspyline:print_get_word(name)
  local v = self:get_word();
  return self:print_names(name) .. string.format("%04X [%u]\r\n", v, v), v;
end
function txspyline:print_get_dword(name)
  local v = self:get_dword();
  return self:print_names(name) .. string.format("%08X [%u]\r\n", v, v), v;
end
--[=======[
    string    txspyline:print_head      ( int size ); --���һ����ʽ����head
]=======]
function txspyline:print_head(size)
  return string.format("%0" .. self.head_size .. "X", size);
end
--[=======[
    stirng, string txspyline:print_hexs ( string name, int size );
        --��ȡ�����һ��hexs, ͬʱ����hexs��
    string, string txspyline:print_head_hexs( string name );
        --��ȡ�����һ����ͷ��hexs, ͬʱ����hexs��
]=======]
function txspyline:print_hexs(name, size)
  local str = self:get_ascii_str(size);
  local ds = self:print_names(name) .. '[' .. self:print_head(#str) .. ']';

  self:level_increase();
  local tab = "\r\n" .. self:print_blanks();
  self:level_decrease();

  local i = 1;
  local h;
  for k = 1, #str do
    if i == 1 then
      ds = ds .. tab;
    end
    h = string.format("%02X ", str:byte(k, k));
    i = i + 1;
    if i > 0x10 then
      i  = 1;
    end
    ds = ds .. h;
  end
  return ds .. "\r\n", str;
end
function txspyline:print_head_hexs(name)
  local str = self:get_head_ascii();
  local ds = self:print_names(name) .. '(' .. self:print_head(#str) .. ')';

  self:level_increase();
  local tab = "\r\n" .. self:print_blanks();
  self:level_decrease();

  local i = 1;
  local h;
  for k = 1, #str do
    if i == 1 then
      ds = ds .. tab;
    end
    h = string.format("%02X ", str:byte(k, k));
    i = i + 1;
    if i > 0x10 then
      i  = 1;
    end
    ds = ds .. h;
  end
  return ds .. "\r\n", str;
end
--[=======[
    string, string txspyline:print_head_ascii( string name );
        --���ASCII"..."��ͬʱ�����ַ���
    string, string txspyline:print_head_utf8( string name );
        --���UTF8"..."��ͬʱ����ת������ַ���
]=======]
function txspyline:print_head_ascii(name)
  local str = self:get_head_ascii();
  return self:print_names(name) .. '(' .. self:print_head(#str) .. ")ASCII\"" ..
          str ..
          "\"\r\n",
          str;
end
function txspyline:print_head_utf8(name)
  local str = self:get_head_ascii();
  str = utf82s(str);
  return self:print_names(name) .. '(' .. self:print_head(#str) .. ")UTF8\"" ..
          str ..
          "\"\r\n",
          str;
end
--[=======[
    string    txspyline:print_ip        ( string name );
        --���IP��ֵ��IP��ʽ��ͬʱ����IP��ֵ
    string    txspyline:print_time      ( string name );
        --���ʱ����ֵ��ʱ���ʽ��ͬʱ����ʱ����ֵ
    string    txspyline:print_key       ( string name );
        --���KEY��ͬʱ����KEY��
    string    txspyline:print_head_line_only_head( string name );
        --��ȡ��ͷ�����ݣ���ֻ���ͷ��ʽ��ͬʱ��������
    string    txspyline:print_remain    ( string name );
        --��hex2show���ʣ������
    string    txspyline:print_tlv       ( TXData td );
        --���TLV��ʽ
        --��ѯTXP.TLVSpy�Ƿ����Ŀ��TLV�ű���������ڣ�����ýű������������ڣ���Ĭ�����
]=======]
function txspyline:print_ip(name)
  local ip = self:get_dword();
  return self:print_names(name) ..
          string.format("%08X [%d.%d.%d.%d]\r\n",
            ip,
            string.unpack("BBBB", string.pack(">I4", ip))),
          ip;
end
function txspyline:print_time(name)
  local time = self:get_dword();
  return self:print_names(name) ..
          string.format("%08X [%s]\r\n", time,
                      os.date("%Y/%m/%d %H:%M:%S",time)),
          time;
end
function txspyline:print_key(name)
  return self:print_hexs(name, TXP.TEAN_Key_Size);
end
function txspyline:print_head_line_only_head(name)
  local nline = self:ghl();
  return self:print_names(name) .. '(' .. self:print_head(#nline.line) .. ")\r\n",
           nline;
end
function txspyline:print_remain()
  if #self.line == 0 then
    return "";
  end
  return hex2show(self.line);
end
function txspyline:print_tlv(td)
  local ds = "";
  local tag = self:get_word();
  local len = self:get_word();
  local codec = TXP.TLVSpy[tag];
  if codec == nil then
    self:level_increase();
    ds = "\r\n" .. 
          self:print_names(string.format("UNKNOW TLV_%04X", tag)) ..
          string.format("   %04X:(%04X)\r\n", tag, len);
    self:level_increase();
    ds = ds .. self:print_hexs("VALUE", len);
    self:level_decrease();
    self:level_decrease();
    return ds;
  end
  local data = self:get_line(len);
  local name = TXP.TLVName[tag]
  data:level_increase();
  ds = "\r\n" ..
        data:print_names(string.format("%s", name)) ..
        string.format("   %04X:(%04X)\r\n", tag, #data.line);
  data:level_increase();
  
    local b, dsds = pcall(codec, td, data);
    if not b then
      dsds = string.format("\r\nTLV%04X����ʧ��:%s\r\n", tag, dsds);
    end

  ds = ds .. dsds .. data:print_remain();
  return ds;
end

-------- -------- -------- --------
--[=======[
    txspyline.inc     = txspyline.level_increase;
    txspyline.dec     = txspyline.level_decrease;
    txspyline.pk      = txspyline.print_blanks;
    txspyline.pn      = txspyline.print_names;
    txspyline.pb      = txspyline.print_get_byte;
    txspyline.pw      = txspyline.print_get_word;
    txspyline.pd      = txspyline.print_get_dword;
    txspyline.ph      = txspyline.print_head;
    txspyline.phs     = txspyline.print_hexs;
    txspyline.phhs    = txspyline.print_head_hexs;
    txspyline.pha     = txspyline.print_head_ascii;
    txspyline.ph8     = txspyline.print_head_utf8;
    txspyline.pip     = txspyline.print_ip;
    txspyline.ptm     = txspyline.print_time;
    txspyline.pkey    = txspyline.print_key;
    txspyline.phloh   = txspyline.print_head_line_only_head;
    txspyline.pr      = txspyline.print_remain;
    txspyline.ptlv    = txspyline.print_tlv;
]=======]
txspyline.inc     = txspyline.level_increase;
txspyline.dec     = txspyline.level_decrease;
txspyline.pk      = txspyline.print_blanks;
txspyline.pn      = txspyline.print_names;
txspyline.pb      = txspyline.print_get_byte;
txspyline.pw      = txspyline.print_get_word;
txspyline.pd      = txspyline.print_get_dword;
txspyline.ph      = txspyline.print_head;
txspyline.phs     = txspyline.print_hexs;
txspyline.phhs    = txspyline.print_head_hexs;
txspyline.pha     = txspyline.print_head_ascii;
txspyline.ph8     = txspyline.print_head_utf8;
txspyline.pip     = txspyline.print_ip;
txspyline.ptm     = txspyline.print_time;
txspyline.pkey    = txspyline.print_key;
txspyline.phloh   = txspyline.print_head_line_only_head;
txspyline.pr      = txspyline.print_remain;
txspyline.ptlv    = txspyline.print_tlv;