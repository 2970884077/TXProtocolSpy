local tag = 0x0105;
local name = "TLV_m_vec0x12c";
local subver = 0x0001;


TXP.TLVName[tag] = name;

TXP.TLVBuilder[tag] = function(td)
  local tlv = txline:new();
  local data = txline:new();
  local wSubVer = td[TXP.CreateTLVSubVerName(tag)] or subver;
  data:sw(wSubVer);
  if wSubVer == 0x0001 then
    data:sb(1);
    data:sb(2);
    data:sw(0x0014);
    data:sd(0x01010010);
    data:srk();
    data:sw(0x0014);
    data:sd(0x01020010);
    data:srk();
  else
    error(name .. "�޷�ʶ��İ汾��" .. wSubVer);
  end
  tlv:sw(tag);
  tlv:shl(data);
  return tlv;
end

TXP.TLVAnalyzer[tag] = function(td, data)
end

TXP.TLVSpy[tag] = function(td, data)
  local ds =
  data:pw("wSubVer") ..
  data:pb("UNKNOW");
  local buf, count = data:pb("Count");
  ds = ds .. buf;
  for k = 1, count do
    ds = ds .. data:phhs("buf" .. k);
  end
  return ds;
end

--[[
0105�����ݹ���:
01 05 //#1-�û��ͻ����ļ���ȫУ��
00 88 //�ܳ���136
00 01 //�汾1
01 02 //�û��浵У������(��������)
00 40 //У������#1���� 64
02 01 //��¼�ļ�У���
03 //У������3��RSA(QQ+��¼ʱ��+�ļ�MD5)
3C //������Ч����60
01 //�汾1
03 //��������3
00 00 //�ָ���,У��ֵ:����56�ֽ�
46 16 DB 8D 71 10 33 5C 0F 51 E5 6E 43 02 C5 1C 
C3 C1 CA CC 3F 59 7A 7B 9C 42 F8 0C 96 F1 A0 17 
C6 21 BE E3 44 97 41 0F 85 1C 85 33 F8 CF EA C1 
CE A3 FD 02 ED 3E DD E2
00 40 //У������#2���� 64
02 02 //�����ļ�У���
03 //У������3��RAS(QQ+��¼ʱ��+�ļ�MD5)
3C //������Ч����60
01 //�汾1
03 //��������3
00 00 //�ָ���,У��ֵ:����56�ֽ�
85 A3 23 E7 5A BB F4 20 95 0C 8A 01 53 C1 46 87 
8A C5 90 CC D5 88 8C 04 61 5C 87 08 EF 13 7F DF 
A5 9D B7 7D B6 81 7F E7 1D C3 0C 32 98 81 EA B2 
74 48 39 59 2C 3A 70 9B
]]--