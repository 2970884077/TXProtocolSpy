local tag = 0x0102;
local name = "SSO2::TLV_Official_0x102";
local subver = 0x0001;


TXP.TLVName[tag] = name;

-------- -------- -------- --------
local function CreateOfficial(tzm, OffKey, bufSigPicNew, bufTGTGT)
  local MD5InfoCount = 0x4;       --MD5��Ϣ����
  local round = 0x100;            --��λ�㷨����
  local TmOffMod = 0x13;          --���Լ����һ����Ϣ���ٴμ�������
  local TmOffModAdd = 0x5;

  local MD5Info = md5(OffKey);    --��һ��
  --print("off1:\r\n" .. hex2show(MD5Info));
  MD5Info = MD5Info .. md5(bufSigPicNew); --�ڶ���
  --print("off2:\r\n" .. hex2show(MD5Info));

  local keyround = (tzm % TmOffMod) + TmOffModAdd;
  --print("keyround:" .. keyround);

  local seq = {};                      --���ܻ���
  local ls = {};                       --bufLoginSig��MD5����N��
  --���ܻ����ʼ��00-FF��ls�а�bufLoginSig��MD5����N��д��
  for k = 1, round do
    seq[k] = k - 1;
    local i = TXP.TEAN_Key_Size + ((k - 1) % TXP.TEAN_Key_Size) + 1;
    ls[k] = MD5Info:byte(i, i);
  end
    
  --print("off3 seq:\r\n" .. hex2show(string.char(unpack(seq))));
  --print("off3 ls:\r\n" .. hex2show(string.char(unpack(ls))));
  --���ls��λ
  local x = 0;
  for k = 1, round do
    x  = (x + seq[k] + ls[k]) % round;  --�����ls�ó�xֵ��ָ����λ
    seq[x + 1], seq[k] = seq[k], seq[x + 1];
  end
  --print("off4 seq:\r\n" .. hex2show(string.char(unpack(seq))));
  --��λ���ٴ����OffKey��MD5����
  --MD5Info��������LS_KEY
  x = 0;
  for k = 1, TXP.TEAN_Key_Size do
    x = (x + seq[k + 1]) % round;
    seq[x + 1], seq[k + 1] = seq[k + 1], seq[x + 1];
    local v = (seq[x + 1] + seq[k + 1]) % round + 1;
    MD5Info = MD5Info .. string.char(seq[v] ~ MD5Info:byte(k,k));
  end
  --print("off5:\r\n" .. hex2show(MD5Info));
  --MD5Info���Ķ���bufTGTGT��MD5
  MD5Info = MD5Info .. md5(bufTGTGT);
  --print("off6:\r\n" .. hex2show(MD5Info));

  local MD5MD5Info = md5(MD5Info);
  local m0 = MD5MD5Info;
  for k = 1, keyround do
    m0 = md5(m0);
  end
  --�滻��һ��
  MD5Info = m0 .. MD5Info:sub(TXP.TEAN_Key_Size + 1);
  --print("off7:\r\n" .. hex2show(MD5Info));
  --��ʼ���ܵ�MD5����official
  local t1 = MD5MD5Info:sub(1, TXP.TEAN_Key_Size / 2);
  local t2 = MD5MD5Info:sub(TXP.TEAN_Key_Size / 2 + 1, TXP.TEAN_Key_Size);
  local off = {};
  for k = 1,TXP.TEAN_Key_Size do
    off[k] = 0;
  end
  for k = 1, MD5InfoCount do
    local lp = (k - 1) * TXP.TEAN_Key_Size + 1;
    local l = TXP.TEAN_Key_Size;
    local prekey = MD5Info:sub(lp, lp + l);
    --print("prekey:\r\n" .. hex2show(prekey));
    local key = xline:newline(prekey);
    local a = key:gd();
    local b = key:gd();
    local c = key:gd();
    local d = key:gd();
    key = txline:new();
    key:sd(a);
    key:sd(b);
    key:sd(c);
    key:sd(d);
    key = key.line;
    --print("key:\r\n" .. hex2show(key));
        
    local v = TeanEncipher(t1, key);
    --print("off8:\r\n" .. hex2show(v));
    v =  v .. TeanEncipher(t2, key);
    --print("off8:\r\n" .. hex2show(v));
    v = {v:byte(1,-1)};

    for j = k, TXP.TEAN_Key_Size do
      off[j] = off[j] ~ v[j];
    end
    --print("off:\r\n" .. hex2show(string.char(unpack(off))));
    --print("===========\r\n");
  end
  off = string.char(table.unpack(off));
  off = md5(off);
  --print("off9:\r\n" .. hex2show(off));

  local c32 = crc32(off);
  local bufOfficial = xline:new();
  bufOfficial:sa(off);
  bufOfficial:sd(c32);
  return bufOfficial.line;
end
-------- -------- -------- --------

TXP.TLVBuilder[tag] = function(td)
  local tlv = txline:new();
  local data = txline:new();
  local wSubVer = td[TXP.CreateTLVSubVerName(tag)] or subver;
  data:sw(wSubVer);
  if wSubVer == 0x0001 then
    local bufKey = data:srk();
    if td.bufSigPic == nil then
      local bufSig = "";
      for k = 1, 0x38 do
        bufSig = bufSig .. string.char(xrand(0xFF) + 1);
      end
      td.bufSigPic = bufSig;
    end
    data:sha(td.bufSigPic);
    data:sha(CreateOfficial(td.wTimeZoneoffsetMin, bufKey, td.bufSigPic, td.bufTGTGT));
  else
    error(name .. "�޷�ʶ��İ汾��" .. wSubVer);
  end
  tlv:sw(tag);
  tlv:shl(data);
  return tlv;
end

TXP.TLVSpy[tag] = function(td, data)
  local ds = data:pw("wSubVer");
  local bufk, key = data:pkey("bufOfficialKey");
  local bufs, sig = data:phhs("bufSigPic");
  local bufo, off = data:phhs("bufOfficial&CRC32");
  local oc = CreateOfficial(td.wTimeZoneoffsetMin, key, sig, td.SpybufTGTGT);
  local bufchk = data:pk() .. "    check offical : ";
  if oc == off then
    bufchk = bufchk .. "ok";
  else
    bufchk = bufchk .. "** no equ ** : " .. hex2str(oc)
        .. "\r\nkey:" .. hex2str(key)
        .. "\r\nsig:" .. hex2str(sig)
        .. "\r\ntgtgt:" .. hex2str(td.SpybufTGTGT);
  end
  bufchk = bufchk .. "\r\n";
  return ds .. bufk .. bufs .. bufo ..  bufchk;
end