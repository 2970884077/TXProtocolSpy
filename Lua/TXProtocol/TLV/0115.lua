local tag = 0x0115;
local name = "SSO2::TLV_PacketMd5_0x115";


TXP.TLVName[tag] = name;

TXP.TLVAnalyzer[tag] = function(td, data)
    --��������������
end

TXP.TLVSpy[tag] = function(td, data)
  return
  data:pkey("bufPacketMD5");
end