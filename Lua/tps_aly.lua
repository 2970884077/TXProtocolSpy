require "xlua";

--[=======[
    --�������ű�ǰ����������ͬ��ȫ�ֱ�����Ӱ��Ĭ������

    use_data_analyzer
        --����Ϊtrueʱ��ͨ�����緢�����ݣ����������debugview
        --�����Ҫ�Զ������ת��������use_data_analyzerΪfalse��������xlog
        --Ĭ��ͨ�����緢������
    tps_ip
        --����������ݵ�ַ��Ĭ��"127.0.0.1"
    tps_port
        --����������ݶ˿ڣ�Ĭ��"42108"

    --����xlog���ڰ������ű�֮��
]=======]
local use_data_analyzer = use_data_analyzer or true;
local tps_ip = tps_ip or "127.0.0.1";
local tps_port = tps_port or "42108";

-------- -------- -------- --------
-------- -------- -------- --------
-------- -------- -------- --------
local udp;

if use_data_analyzer then
  udp = udp_new();
else
  require "analyzer";
end

--ָ���ڴ��ַ����ȡunicode�ַ���
local function readws( lpws )
  local ws = "";
  while true do
    local wc = readmem(lpws, 2);
    if wc == "" or wc == "\0\0" then
      break;
    end
    lpws = lpws + 2;
    ws = ws .. wc;
  end
  return ws2s(ws);
end

--ָ���ڴ��ַ����ȡunicode�ַ�������-4����ȡ���ܴ��ڵĳ���
local function readnws( lpws )
  local str = readmem(lpws - 4, 4);
  if str == "" then
    str = string.req("\0", 4);
  end
  local len = string.unpack("<i4", str);
  if len > 0 then
    return ws2s(readmem(lpws, len));
  end
  return readws( lpws );
end

--ָ���ڴ��ַ����ȡascii�ַ���
local function reads( lps )
  local s = "";
  while true do
    local ch = readmem(lps, 1);
    if ch == "" or ch == "\0" then
      break;
    end
    lps = lps + 1;
    s = s .. ch;
  end
  return s;
end

--ָ���ڴ��ַ����ȡascii�ַ�������-4����ȡ���ܴ��ڵĳ���
local function readns( lps )
  local str = readmem(lps - 4, 4);
  if str == "" then
    str = string.req("\0", 4);
  end
  local len = string.unpack("<i4", str);
  if len > 0 then
    return readmem(lps, len);
  end
  return reads( lps );
end
-------- -------- -------- --------
-------- -------- -------- --------
-------- -------- -------- --------
local function transfer( msg )
  if use_data_analyzer then
    udp:send(msg, tps_ip, tps_port);
  else
    xlog(analyzer(msg));
  end
end

-------- -------- -------- --------
-------- -------- -------- --------
-------- -------- -------- --------
local TXDataHexBufName = {
  ["bufContent"]              = 2,
  ["bufDestIP"]               = 3,
  ["bufDHPublicKey"]          = 4,
  ["bufDHShareKey"]           = 4,
  ["bufPwd"]                  = 4,
};

--�������ơ����͡����ݣ����н���
local function TXData_Analyzer(name, tp, data)
  local msg = string.format("%-24s", name) .. " = ";
  tp = tp % 0x100;

  ------------------------01
  if tp == 0x01 then
    if (data % 0x100) == 00 then
        msg = msg .. "false";
    else
        msg = msg .. "true";
    end
    msg = msg .. ";";
  ------------------------02
  elseif tp == 0x02 then
    msg = msg .. string.format("%-16s --%u",
      string.format("0x%02X;", data), data);
  ------------------------04
  elseif tp == 0x04 then
    msg = msg .. string.format("%-16s --%u",
      string.format("0x%04X;", data), data);
  ------------------------06
  elseif tp == 0x06 then
    msg = msg .. string.format("%-16s --%u",
      string.format("0x%08X;", data), data);
  ------------------------07
  elseif tp == 0x07 then
    msg = msg .. string.format("%-16s --0x%08X",
      string.format("%u;", data), data);
  ------------------------08
  elseif tp == 0x08 then
    msg = msg .. "L\"" .. readnws(data) .. "\";";
  ------------------------09
  elseif tp == 0x09 then
    local d = readns(data);

    local t = TXDataHexBufName[name];
    if t == 1 then
        msg = msg .. "\"" .. d .. "\";";
    elseif t == 2 then
        msg = msg .. "UTF8\"" .. utf82s(d) .. "\";";
    elseif t == 3 then
        msg = msg .. "L\"" .. ws2s(d) .. "\";";
    elseif t == 4 then
        msg = msg .. "HEXS\"" .. hex2str(d) .. "\";";
    else
        msg =  msg .. "\r\n" .. hex2show(d);
    end
  ------------------------0B
  elseif tp == 0xB then
    local vec_name = mkD(data + 0x1C);
    local vec_data = mkD(data + 0x20);
    local vec_type = mkD(data + 0x24);

    msg = msg .. "\r\n    {\r\n";

    local lpname = mkD(vec_name);
    while lpname ~= 0 do
      msg = msg ..
            "    " ..
            TXData_Analyzer(
                readws(lpname),
                mkB(vec_type),
                mkD(vec_data)) ..
            "\r\n";
      vec_type = vec_type + 1;
      vec_data = vec_data + 4;
      vec_name = vec_name + 4;
      lpname = mkD(vec_name);
    end

    msg = msg .. "    };";
  ------------------------XX
  else
    msg = msg .. " type : " ..
    string.format("%02X", tp) .. " " ..
    string.format("%08X", data);
  end

  return msg;
end

-------- -------- -------- --------
-------- -------- -------- --------
-------- -------- -------- --------

function TXLog_DoTXLogVW(lpname, lpdata)
  transfer("��" .. readws(lpname) .. '=' .. readws(lpdata));
end

function TXDataHook(lpname, tp, data)
  local name = readnws(lpname);
  transfer("��" .. name .. "=" .. TXData_Analyzer(name, tp, data));
end

function CTXUDPDataSender__InternalSendData(lpip, port, size, buf)
  local ip = readnws(lpip);
  ip = ip .. string.format(":%u", port % 0x10000);
  transfer("��" .. ip .. '=' .. readmem(buf, size));
end

function CTXUDPDataSenderInternalRecvData(lpip, port, size, buf)
  local ip = readnws(lpip);
  ip = ip .. string.format(":%u", port % 0x10000);
  transfer("��" .. ip .. '=' .. readmem(buf, size));
end

function uv_udp_send(lpTo, count, lpWSABUF)
  local port = mkWW(lpTo + 2);
  local ip = string.format("%d.%d.%d.%d:%u",
        mkBB(lpTo + 4),
        mkBB(lpTo + 5),
        mkBB(lpTo + 6),
        mkBB(lpTo + 7),
        port);
  local buf = "";
  for k = 1, count do
    local n = mkD(lpWSABUF + (k - 1) * 4 * 2);
    local lp = mkD(lpWSABUF + (k - 1) * 4 * 2 + 4);
    buf = buf .. readmem(lp, n);
  end
  transfer("��" .. ip .. '=' .. buf);
end

function uv_udp_recv(lpFrom, lpsize, lpWSABUF)
  local port = mkWW(lpFrom + 2);
  local ip = string.format("%d.%d.%d.%d:%u",
        mkBB(lpFrom + 4),
        mkBB(lpFrom + 5),
        mkBB(lpFrom + 6),
        mkBB(lpFrom + 7),
        port);
  local buf = "";
  local size = mkD(lpsize);
  for k = 1, 100000 do
    local n = mkD(lpWSABUF + (k - 1) * 4 * 2);
    local lp = mkD(lpWSABUF + (k - 1) * 4 * 2 + 4);
    if size > n then
      buf = buf .. readmem(lp, n);
      size = size - n;
    else
      buf = buf .. readmem(lp, size);
      break;
    end
  end
  transfer("��" .. ip .. '=' .. buf);
end

function acc_pwd(lpdata)
  local lpdata = mkD(lpdata + 0x28);
  while true do
    local lpname = mkD(lpdata + 0);
    if lpname == 0 then
      break;
    end
    local name = reads(lpname);
    local data = mkD(lpdata + 4);
    local tp = mkB(lpdata + 8);

    transfer("��" .. name .. "=" .. TXData_Analyzer(name, tp, data));
    lpdata = lpdata + 9;
  end
end