
--[=======[
-------- -------- -------- --------
              TXData
-------- -------- -------- --------

    TXP.Data;                           --TXProtocol�����ݻ���
        --���������ò�ͬ����������new�����и���
]=======]
TXP.Data                    = {};
TXP.Data.__index = TXP.Data;

local td = TXP.Data;

--[=======[
    TXProtocol�����ݻ��������±�Ҫ������Ϣ������Ԥ�趨����������ֵ
      cMainVer                          --QQ���汾��
      cSubVer                           --QQ�ΰ汾��
      dwClientType                      --�ͻ�������
      dwPubNo                           --���а汾��
      wSubVer                           --�Ӱ汾��
      dwSSOVersion                      --SSO�汾��
      dwServiceId
      dwClientVer                       --�ͻ��˰汾��
      cPingType                         --Ping����

      QdPreFix                          --QdDataǰ׺
      QdSufFix                          --QdData��׺
      bufQdKey                          --QdData Key
      dwQdVerion                        --����QQProtect.exe��dll��"��Ʒ�汾"
      cQdProtocolVer                    --QdData�汾��
      wQdCsCmdNo                        --QdDataָ���
      cQdCcSubNo                        --QdData��ָ���
      cOsType                           --ϵͳ����
      bIsWOW64                          --�Ƿ�x64
      dwDrvVersionInfo                  --�����汾��Ϣ
      bufVersion_TSSafeEdit_dat         --TSSafeEdit.dat��"�ļ��汾"
      bufVersion_QScanEngine_dll        --QScanEngine.dll��"�ļ��汾"
      bufQQMd5                          --QQ.exe��md5
]=======]
td.cMainVer                 = 0x36;     --0x35;
td.cSubVer                  = 0x16;     --0x3B;
td.dwClientType             = 0x00010101;
td.dwPubNo                  = 0x00006776; --0x00006717;
td.wSubVer                  = 0x0001;
td.dwSSOVersion             = 0x0000044B; --0x00000445;
td.dwServiceId              = 0x00000001;
td.dwClientVer              = 0x0000152B; --0x000014EF;
td.cPingType                = 0x04;

td.QdPreFix                 = "\x3E";
td.QdSufFix                 = "\x68";
td.bufQdKey                 = "wE7^3img#i)%h12]";
td.dwQdVerion               = 0x04000307; --0x03080202;
td.cQdProtocolVer           = 0x02;
td.wQdCsCmdNo               = 0x0004;
td.cQdCcSubNo               = 0x00;
td.cOsType                  = 0x01;                 --ϵͳ����
td.bIsWOW64                 = 0x00;                 --�Ƿ�x64
td.dwDrvVersionInfo         = 0x00000000;
td.bufVersion_TSSafeEdit_dat = str2hexs"07DE000300060001";  --"07DE000900020001";
                                                    --TSSafeEdit.dat��"�ļ��汾"
td.bufVersion_QScanEngine_dll = str2hexs"0002000400000000";
                                                    --QScanEngine.dll��"�ļ��汾"
td.bufQQMd5                 = str2hexs"DA864B886E555A7B4B3678B8CBB128D4";  --"0E3B8145EF65E7B3D0A9EF0A1EC5C43F";
--[=======[
    TXData    TXP.Data:new              ( string account, string password );
        --�����˺����룬�½����ݻ���
        --accountĬ��0
        --passwordĬ�Ͽմ�

    �µ����ݻ������������µ�������
      dwUin                             --�ʺ���ֵ
      bufPsMD5                          --����md5
      bufPsSaltMD5                      --�������ʺŵ�md5
    ����������Ϣ��Ҫ��ʱ�������ȡ����Ҳ����ʹ�ù̶�ֵ
      dwLocaleID                        --������Ϣ���й���½
      wTimeZoneoffsetMin                --ʱ����ֵ���й���½
      bRememberPwdLogin                 --�Ƿ��ס��½
      bufDHPublicKey                    --����ͨѶ��Կ
      bufDHShareKey                     --����ͨѶ˽Կ
      tlv0114subver                     --ECDH Key�汾��
      dwISP
      dwIDC
    α��������Ϣ��ʹ���˺Ÿ������ݵ�MD5�������˺ŵĹ̶�ֵ
      bufComputerName
      bufComputerID
      bufComputerIDEx
      bufMacGuid
      bufMachineInfoGuid
    ������Ϣ�ǻ�����Ҫ���ݣ����鲻Ҫ�޸�
      RedirectIP                        --�ض���IP��
      Key                               --�ӽ���KEY��
      wCsIOSeq                          --ͨѶ���
]=======]
function TXP.Data:new(account, password)
  local data = {};
  setmetatable(data, self);
  self.__index = self;
    
  --�����ʺ���Ϣ
  account = account or "0";
  if type(account) == "string" then
    data.dwUin            = tonumber(account);
  else
    data.dwUin            = account;
  end
  if (data.dwUin <= 10000) or (data.dwUin > 0xFFFFFFFF) then
    data.dwUin            = 0;
  end
    
  --��������MD5
  password = password or "";
  data.bufPsMD5           = TXP.CreatePsMD5(password);
  data.bufPsSaltMD5       = TXP.CreatePsSaltMD5(data.dwUin, data.bufPsMD5);
    
  --------����������Ϣ��Ҫ��ʱ�������ȡ����Ҳ����ʹ�ù̶�ֵ
  data.dwLocaleID         = 0x00000804;
  data.wTimeZoneoffsetMin = 0x01E0;
  data.bRememberPwdLogin  = 0;
  data.bufDHPublicKey     = str2hexs"025AE2EC20719448656AB942A96C558BD26E808DCD171E985A";
  data.bufDHShareKey      = str2hexs"6CE5431AF838645A665CFB68309291F3623AD05105AA0A9A";
  data.tlv0114subver      = 0x0102;       --ECDH Key�汾��
  data.dwISP              = 0x00000000;
  data.dwIDC              = 0x00000000;
    
  --------α��������Ϣ��ʹ���˺Ÿ������ݵ�MD5�������˺ŵĹ̶�ֵ
  data.bufComputerName    = md5(account .. "ComputerName"):hex2str();
  data.bufComputerID      = md5(account .. "ComputerID");
  data.bufComputerIDEx    = md5(account .. "ComputerIDEx");
  data.bufMacGuid         = md5(account .. "MacGuid");
  data.bufMachineInfoGuid = md5(account .. "MachineInfoGuid");
    
  --------������Ϣ�ǻ�����Ҫ���ݣ����鲻Ҫ�޸�
  data.RedirectIP         = {};
  data.Key                = {};
  data.wCsIOSeq           = xrand(0xFFFF) + 1;

  return data;
end
--[=======[
    TXData    TXP.Data:new_net(
        string    account,              --Ĭ��0
        string    password,             --Ĭ�Ͽմ�
        string    ip,                   --����IP��ַ����Ϊ�գ����д�TXP.Servers��ȡһ����ַ
        string    port,                 --����IP�˿�
        boolean   udp_or_tcp,           --ָ��ͨѶʹ��UDP��TCP��Ĭ��UDP
        int       timeout               --ͨѶ��ʱ����ms�ƣ�Ĭ��5000ms
        );

    �µ����ݻ����̳���TXP.Data:new
    �µ����ݻ��������¶���������
      istcp                             --�Ƿ�ʹ��TCPͨѶ
      link                              --ͨѶsocket
      dwServerIP                        --ͨѶĿ��IP
      wServerPort                       --ͨѶĿ��˿�
]=======]
function TXP.Data:new_net(account, password, ip, port, udp_or_tcp, timeout)
  local data = self:new(account, password);

  --Ĭ��ʹ��udp����
  local udp_or_tcp = udp_or_tcp or true;
  local stype = 0;
  if udp_or_tcp == false then
    stype = 1;
    data.istcp              = true;
  end

  --Ĭ��5�볬ʱ
  local timeout = timeout or 5000;

  --���ipΪ�գ�������ȡһ����ַ
  if ip == nil then
    while true do
      local cfgip = TXP.Servers[ xrand(#TXP.Servers) + 1 ];
      if cfgip.cServerType == stype then
        ip, port = cfgip.strServerAddr, cfgip.wServerPort;
        break;
      end
    end
  end

  if type(port) == "number" then
    port = tostring(port);
  end

  --����sock
  if stype == 0 then
      data.link             = udp_new(ip, port); 
  else
      data.link             = tcp_new(ip, port);
  end
  data.link:settimeout(timeout);
  string.format("TXProtocol����%s:%d", ip, port):xlog();
  local sip, sport, ip, port = data.link:getpeername();
  data.dwServerIP           = ip;
  data.wServerPort          = port;

  return data;
end
--[=======[
    TXP.Servers                         --TXĬ��ͨѶIP���ݿ�
]=======]
TXP.Servers =
{
  { ["strServerAddr"] = "sz.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz2.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz3.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz4.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz5.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz6.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz7.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz8.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "sz9.tencent.com", ["wServerPort"] = 8000, ["cServerType"] = 0 },

  { ["strServerAddr"] = "tcpconn.tencent.com", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "tcpconn2.tencent.com", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "tcpconn3.tencent.com", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "tcpconn4.tencent.com", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "tcpconn5.tencent.com", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "tcpconn6.tencent.com", ["wServerPort"] = 80, ["cServerType"] = 1 },
    
  { ["strServerAddr"] = "112.95.240.180", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "183.60.48.174", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "119.147.45.203", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "112.90.84.10", ["wServerPort"] = 8000, ["cServerType"] = 0 },
  { ["strServerAddr"] = "125.39.205.119", ["wServerPort"] = 8000, ["cServerType"] = 0 },
    
  { ["strServerAddr"] = "112.90.84.112", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "123.151.40.188", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "112.95.240.48", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "183.60.49.183", ["wServerPort"] = 80, ["cServerType"] = 1 },
  { ["strServerAddr"] = "119.147.45.40", ["wServerPort"] = 80, ["cServerType"] = 1 },
};