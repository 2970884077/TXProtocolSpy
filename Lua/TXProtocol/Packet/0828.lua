--[=======[
-------- -------- -------- --------
         0828 PreLogin��
-------- -------- -------- --------
]=======]
local cscmd = 0x0828;
TXP.PacketName[cscmd] = "PreLogin";
--[=======[
    string    TXP.PacketBuilder[0x0828] ( TXData td );
        --ָ�����ݻ���������0828 Send���ݷ��
]=======]
TXP.PacketBuilder[cscmd] = function(td)
  local data = txline:new();

  data:sw(cscmd);
  td.wCsIOSeq = td.wCsIOSeq + 1;
  data:sw(td.wCsIOSeq);
  data:sd(td.dwUin);
    
  data:sa("\x02\x00\x00");
  data:sd(td.dwClientType);
  data:sd(td.dwPubNo);
  data:sd(0x0030003A);

  data:sha(td.bufSigSession);
    
  local tlv_table =
    {
    0x0007,
    0x000C,
    0x0015,
    0x0036,
    0x0018,
    0x001F,
    0x0105,
    0x010B,
    0x002D,
    };
        
  local tlvs = txline:new();
  for k = 1, #tlv_table do
    local func = TXP.TLVBuilder[tlv_table[k]];
    if func == nil then
      error(string.format("TLV-%04X-�����ڹ�������", tlv_table[k]));
    end
    tlvs:sl( func(td) );
  end

  local encode = TeanEncrypt(tlvs.line, td.Key.bufSessionKey);

  if (encode == nil) or (#encode == 0) then
    error(string.format("Packet-%04X-����ʧ��", cscmd));
  end

  data:sa(encode);
    
  return TXP.PacketBuilderFix(td, data);
end


-------- -------- -------- --------
--[=======[
    TXP.PacketResultName[0x0828]        --0828������ؽ����Ӧ˵������
]=======]
TXP.PacketResultName[cscmd] = {};
local name = TXP.PacketResultName[cscmd];

name[0x00] = "0828�ɹ�";

-------- -------- -------- --------
--[=======[
    string    TXP.PacketAnalyzer[0x0828]( TXData td, string data | txline data );
        --ָ�����ݻ�����Recv���������֮
]=======]
TXP.PacketAnalyzer[cscmd] = TXP.PacketAnalyzer[0x0825];

-------- -------- -------- --------
--[=======[
    string    TXP.PacketSendSpy[0x0828] ( TXData td, txspyline data );
        --ָ�����ݻ�����Send���(ȥͷȥβ��txspyline)������֮
]=======]
TXP.PacketSendSpy[cscmd] = function(td, data)
  local cMainVer = data:gb();
  local cSubVer = data:gb();
  local wCsCmdNo = data:gw();
  local wCsSenderSeq = data:gw();

  local ds =
string.format("bufPacketHeader [%02X]\r\n", 0xA);
data:inc();
ds = ds ..
  data:pk() .. string.format("cMainVer��cSubVer:  %02X %02X\r\n", cMainVer, cSubVer) ..
  data:pk() .. string.format("wCsCmdNo:                                          *** %04X ***\r\n",              wCsCmdNo) ..
  data:pk() .. string.format("wCsSenderSeq:                          --- %04X ---\r\n",                          wCsSenderSeq) ..
  data:pd("dwUin");
data:dec();
ds = ds ..
data:phs("UNKNOW", 3);

ds = ds ..
data:pd("dwClientType") ..
data:pd("dwPubNo") ..
data:pd("UNKNOW") ..
data:phhs("bufSigSession");

  local encode;
  local buf = data.line;
  for k,v in pairs(td.Key) do
    if k:sub(1,3) == "Spy" then
      encode = TeanDecrypt(buf, v);
      if (encode ~= nil) and (#encode > 0) then
        buf = "    with " .. k;
        break;
      end
    end
  end
  if (encode == nil) or (#encode <= 0) then
    return ds .. string.format("Packet-%04X-����ʧ��\r\n", wCsCmdNo);
  end


ds = ds ..
string.format("GeneralCodec_Request [%04X] >> [%04X]%s\r\n", #data.line, #encode, buf);

  data.line = encode;

  while #data.line > 0 do
    ds = ds .. data:ptlv(td);
  end

  return ds;
end

-------- -------- -------- --------
--[=======[
    string    TXP.PacketRecvSpy[0x0828] ( TXData td, txspyline data );
        --ָ�����ݻ�����Recv���(ȥͷȥβ��txspyline)������֮
]=======]
TXP.PacketRecvSpy[cscmd] = TXP.PacketRecvSpy[0x0825];