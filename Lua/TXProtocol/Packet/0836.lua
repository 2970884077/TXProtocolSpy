
--[=======[
-------- -------- -------- --------
          0836 CheckTGTGT��
-------- -------- -------- --------
]=======]
local cscmd = 0x0836;
TXP.PacketName[cscmd] = "CheckTGTGT";

-------- -------- -------- --------
--[=======[
    string    TXP.PacketBuilder[0x0836] ( TXData td );
        --ָ�����ݻ���������0836 Send���ݷ��
]=======]
TXP.PacketBuilder[cscmd] = function(td)
  local data = txline:new();

  data:sw(cscmd);
  td.wCsIOSeq = td.wCsIOSeq + 1;
  data:sw(td.wCsIOSeq);
  data:sd(td.dwUin);

  data:sa("\x03\x00\x00");
  data:sd(td.dwClientType);
  data:sd(td.dwPubNo);
  data:sd(0);

  data:sw(td.wSubVer);
  data:sw(td[TXP.CreateTLVSubVerName(0x0114)]);

  local pubkey = td.bufDHPublicKey;
  data:sha(pubkey);
  data:sd(0x10);
  local bufCsCmdCryptKey = data:srk();
    
  local tlv_table =
      {
      0x0112,
      0x030F,
      0x0004,
      0x0005,
      0x0006,
      0x0015,
      0x001A,
      0x0008,
      0x0018,
      0x0103,
      --0x110,
      0x0032,
      0x0313,
      0x0312,
      0x0102,
      };
        
  local tlvs = txline:new();
  for k = 1, #tlv_table do
    local func = TXP.TLVBuilder[tlv_table[k]];
    if func == nil then
      error(string.format("TLV-%04X-�����ڹ�������", tlv_table[k]));
    end
    tlvs:sl( func(td) );
  end

  local encode = TeanEncrypt(tlvs.line, td.bufDHShareKey);
    
  if (encode == nil) or (#encode == 0) then
      error("����ʧ��");
      return ds;
  end
  td.Key[TXP.CreateKeyName(cscmd, td.wCsIOSeq)] = bufCsCmdCryptKey;
  td.Key["bufDHShareKey"] = td.bufDHShareKey;
    
  data:sa(encode);
    
  return TXP.PacketBuilderFix(td, data);
end


-------- -------- -------- --------
--[=======[
    TXP.PacketResultName[0x0836]        --0836������ؽ����Ӧ˵������
]=======]
TXP.PacketResultName[cscmd] = {};
local name = TXP.PacketResultName[cscmd];


name[0x00] = "CheckTGTGT�ɹ�";
name[0x01] = "��Ҫ����TGTGT";
name[0x33] = "�ʺű�����";
name[0x34] = "�������";
name[0x3F] = "��Ҫ��֤�ܱ�";
name[0xFA] = "��Ҫ����CheckTGTGT";
name[0xFB] = "��Ҫ��֤��";

-------- -------- -------- --------
--[=======[
    string    TXP.PacketAnalyzer[0x0836]( TXData td, string data | txline data );
        --ָ�����ݻ�����Recv���������֮
]=======]
TXP.PacketAnalyzer[cscmd] = TXP.PacketAnalyzer[0x0825];

-------- -------- -------- --------
--[=======[
    string    TXP.PacketSendSpy[0x0836]( TXData td, txspyline data );
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
  data:pk() .. string.format("wCsSenderSeq:                          --- %04X ---\r\n",                          wCsSenderSeq);
    
  local bufUin, dwUin = data:pd("dwUin");
  ds = ds .. bufUin;
data:dec();

ds = ds ..
data:phs("UNKNOW", 3);

ds = ds ..
data:pd("dwClientType") ..
data:pd("dwPubNo") ..
data:pd("UNKNOW");

ds = ds ..
data:pw("wSubVer?") ..
data:pw("wDHVer") ..
data:phhs("bufDHPublicKey") .. 
data:pd("dwCsCmdCryptKeySize?");

  local bufkey, bufCsCmdCryptKey = data:pkey("bufkey");
ds = ds .. bufkey;
  td.Key[TXP.CreateSpyKeyName(wCsCmdNo, wCsSenderSeq)] = bufCsCmdCryptKey;
  td.Key["SpybufDHShareKey"] = td.bufDHShareKey;
    
  td.bufPsSaltMD5 = TXP.CreatePsSaltMD5(dwUin, td.bufPsMD5);
  td.Key["SpybufPsSaltMD5"] = td.bufPsSaltMD5;
    
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
    string    TXP.PacketRecvSpy[0x0836] ( TXData td, txspyline data );
        --ָ�����ݻ�����Recv���(ȥͷȥβ��txspyline)������֮
]=======]
TXP.PacketRecvSpy[cscmd] = TXP.PacketRecvSpy[0x0825];