--[=======[
-------- -------- -------- --------
           TX Packet
-------- -------- -------- --------

    TXP.PacketName                      --���ݰ���
    TXP.PacketBuilder                   --���ݰ�����������
    TXP.PacketAnalyzer                  --���ݰ�����������
    TXP.PacketResultName                --���ݰ���Ӧ���������
    TXP.PacketSendSpy                   --��������������
    TXP.PacketRecvSpy                   --�հ�����������

    TXP.Packet_PreFix                   --���ݰ�ǰ׺ "\x02"
    TXP.Packet_SufFix                   --���ݰ���׺ "\x03"
    TXP.TEAN_Key_Size                   --TEAN Key��С 0x10
]=======]
TXP.PacketName              = {};
TXP.PacketBuilder           = {};
TXP.PacketAnalyzer          = {};
TXP.PacketResultName        = {};
TXP.PacketSendSpy           = {};
TXP.PacketRecvSpy           = {};

TXP.Packet_PreFix           = "\x02";
TXP.Packet_SufFix           = "\x03";
TXP.TEAN_Key_Size           = 0x10;
--[=======[
    string    TXP.CreateKeyName         ( int cscmd, int csseq );
        --ָ��ָ��š�ָ����ţ�����"%04X-%04X"�������ַ���
]=======]
function TXP.CreateKeyName( cscmd, csseq )
  return string.format("%04X-%04X", cscmd, csseq);
end
--[=======[
    stirng    TXP.CreateSpyKeyName      ( int cscmd, int csseq );
        --ָ��ָ��š�ָ����ţ�����"Spy%04X-%04X"�������ַ���
]=======]
function TXP.CreateSpyKeyName( cscmd, csseq )
  return string.format("Spy%04X-%04X", cscmd, csseq);
end
--[=======[
    string    TXP.PacketBuilderFix      ( TXData td, string data );
        --ָ�����ݻ������Ѿ���֯�õķ��
          ǰ׺���Packet_PreFix��cMainVer��cSubVer
          ��׺���Packet_SufFix
          ��ʹ��tcpģʽͨѶ���Զ��������ͷ
          data����Ϊstring��txline
]=======]
function TXP.PacketBuilderFix( td, data )
  if type(data) == "table" then
    data = data.line;
  end
  local packet = txline:new();
  packet:sa(TXP.Packet_PreFix);
  packet:sb(td.cMainVer);
  packet:sb(td.cSubVer);
  packet:sa(data);
  packet:sa(TXP.Packet_SufFix);
  local tcpsize = "";
  if td.istcp then
    local buf = txline.new();
    buf:sh(#packet.line);
    tcpsize = buf.line;
  end
  return tcpsize .. packet.line;
end
--[=======[
    bool      TXP.IsTXPacket            ( TXData data | string data );
        --���ָ������Ƿ�TXProtocol�����data����Ϊstring��txline
]=======]
function TXP.IsTXPacket( data )
  if type(data) == "table" then
    data = data.line;
  end
  return
  (data:sub(1, #TXP.Packet_PreFix) == TXP.Packet_PreFix) and
  (data:sub(-1, 0-#TXP.Packet_SufFix) == TXP.Packet_SufFix);
end
--[=======[
    string    TXP.PacketAnalyzerFix            ( TXData data | string data );
        --���ָ������Ƿ�TXProtocol���������ǣ�����ȥ��ǰ��׺������
          data����Ϊstring��txline
]=======]
function TXP.PacketAnalyzerFix( data )
  if type(data) == "table" then
    data = data.line;
  end
  if not TXP.IsTXPacket(data) then
    return "";
  end
  return data:sub(1 + #TXP.Packet_PreFix, -1 - #TXP.Packet_SufFix);
end
--[=======[
    string, string TXP.PacketSpy(
        TXData  td,
        string  ip,
        string  data,
        bool    send_or_recv
        );
      --ָ�����ݻ�����IP��Ϣ����������ͻ���գ���ʽ�����
      --���ؼ�Ҫ��Ϣ����ϸ�����ʽ����Ϣ
]=======]
function TXP.PacketSpy( td, ip, data, send_or_recv )
  local nf,nff;
  if send_or_recv then
    nf = "��";
    nff = nf .. " SEND " .. nf;
  else
    nf = "��";
    nff = nf .. " RECV " .. nf;
  end
  if not TXP.IsTXPacket(data) then
    return "��TXЭ��" .. nf,
      "\r\n" .. ip:hex2show() .. "\r\n" .. data:hex2show();
  end

  local data = TXP.PacketAnalyzerFix(data);
  
  local buf = txspyline:newline(data:sub(1,6));
  
  local cMainVer = buf:gb();
  local cSubVer = buf:gb();
  local wCsCmdNo = buf:gw();
  local wCsIOSeq = buf:gw();
  
  local ins = string.format("-%02X%02X-", cMainVer, cSubVer);

  local func;
  if send_or_recv then
    func = TXP.PacketSendSpy[wCsCmdNo];
  else
    func = TXP.PacketRecvSpy[wCsCmdNo];
  end

  local cmdname = TXP.PacketName[wCsCmdNo];

  if cmdname ~= nil then
    ins = ins .. cmdname;
  end
  ins = ins .. string.format("(%04X)  @ %04X", wCsCmdNo, wCsIOSeq);

  buf = txspyline:newline(data);
  local ds = "";

  if func ~= nil then
    local b, dsds = pcall(func, td, buf);
    if b then
      ds = dsds;
    else
      ds = "\r\n����ʧ��:" .. dsds .. "\r\n" .. data:hex2show() .. "\r\n";
    end
  end

  ds = "\r\n" .. ds .. buf.pr(buf);

  return nf .. ins,
    '\r\n' ..
    "                                                             " ..
    nf .. ip .. "\r\n" ..
    "----------------------" .. nff .. "------------------------------" ..
    ds ..
    "--------------------------------------------------------------";
end
--[=======[
    string    TXP.CreatePsMD5           ( string password )
        --ָ�������ַ���������md5

    string    TXP.CreatePsSaltMD5       ( string uin | int uin, string psmd5 )
        --ָ���ʺš�����md5������passaltmd5
]=======]
function TXP.CreatePsMD5( password )
  local password = password or "";
  return password:md5();
end

function TXP.CreatePsSaltMD5( uin, psmd5 )
  if type(uin) == "string" then
    uin = tonumber(uin);
  end
  local pssaltmd5 = txline:new();
  pssaltmd5:sa(psmd5);
  pssaltmd5:sd(0);
  pssaltmd5:sd(uin);
  return pssaltmd5.line:md5();
end

require "TXProtocol/Packet/0825";
require "TXProtocol/Packet/0836";
require "TXProtocol/Packet/0828";