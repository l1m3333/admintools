require 'lib.moonloader'
local ffi = require('ffi')
local sampev = require 'lib.samp.events'
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local directIni = 'StreamChatByChapo.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        enabled = true,
        clear_screen = true,
        mode = 1,
        font_name = 'Trebuchet MS',
        font_size = 8,
        font_flag_bold = true,
        font_flag_italic = false,
        font_flag_border = true,
        font_flag_shadow = false,
        font_flag_underline = false,
        font_flag_strikeout = false,
        auto_align = false,

        lines = 5,
        line_space = 13,
    },
    pos = {
        x = select(1, getScreenResolution()) - 300,
        y = select(2, getScreenResolution()) - 400
    }
}, directIni))
inicfg.save(ini, directIni)

local s = {
    auto_align = imgui.new.bool(ini.main.auto_align),
    mode = imgui.new.int(ini.main.mode),
    mode_list = ffi.new('const char *[2]', {u8'���, �����', u8'�����, ���'}),
    enabled = imgui.new.bool(ini.main.enabled),
    font_name = imgui.new.char[128](ini.main.font_name),
    font_size = imgui.new.int(ini.main.font_size),
    font_flag_bold = imgui.new.bool(ini.main.font_flag_bold),
    font_flag_italic = imgui.new.bool(ini.main.font_flag_italic),
    font_flag_border = imgui.new.bool(ini.main.font_flag_border),
    font_flag_shadow = imgui.new.bool(ini.main.font_flag_shadow),
    font_flag_underline = imgui.new.bool(ini.main.font_flag_underline),
    font_flag_strikeout = imgui.new.bool(ini.main.font_flag_strikeout),

    lines = imgui.new.int(ini.main.lines),
    line_space = imgui.new.int(ini.main.line_space),
}
local pos = {
    x = ini.pos.x,
    y = ini.pos.y
}

function updateFont()
    if font then
        renderReleaseFont(font)
    end
    font = renderCreateFont(ffi.string(s.font_name), s.font_size[0], (s.font_flag_bold[0] and 1 or 0) + (s.font_flag_italic[0] and 2 or 0) + (s.font_flag_border[0] and 4 or 0) + (s.font_flag_shadow[0] and 8 or 0) + (s.font_flag_underline[0] and 10 or 0) + (s.font_flag_strikeout[0] and 20 or 0))
end
updateFont()

local renderWindow = imgui.new.bool(false)
local posedit = false

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    white_style()
end)

local chat = {
    {name = 'king', text = '{ff004d}vk.com/king_tools'},
    --'��� ����� ����� ��� ��� ������ ����� �� �����',
    --'������� � �� �� ��� ��� ��� ��� ���� ��� ���������',
    --'����� �����, ��� �������, �����, ������, �������, �����,',
    --'���� ������ ������ ������� � ������ ���� �����('
}

function intToHex(int)
    return '{'..string.sub(bit.tohex(int), 1, 6)..'}'
end

--local list = {
--    '������',
--    '������� ��',
--    '�������',
--    '��������',
--    '�� ����',
--    '�����',
--    '�����',
--    '������'
--}
local NIGGER_LIST_ADD_TEXT = imgui.new.char[128]('')
local NIGGER_LIST_SELCTED = 0
--==[ JSON ]==--
local json_file = getWorkingDirectory()..'\\config\\StreamChatByChapo.json'
local list = {}

function json(filePath)
    local f = {}
    function f:read()
        local f = io.open(filePath, "r+")
        local jsonInString = f:read("*a")
        f:close()
        local jsonTable = decodeJson(jsonInString)
        return jsonTable
    end
    function f:write(t)
        f = io.open(filePath, "w")
        f:write(encodeJson(t))
        f:flush()
        f:close()
    end
    return f
end

function save()
    ini.main.mode = s.mode[0]
    ini.main.font_name = ffi.string(s.font_name)
    ini.main.enabled = s.enabled[0]
    ini.main.font_size = s.font_size[0]
    ini.main.font_flag_bold = s.font_flag_bold[0]
    ini.main.font_flag_italic = s.font_flag_italic[0]
    ini.main.font_flag_border = s.font_flag_border[0]
    ini.main.font_flag_shadow = s.font_flag_shadow[0]
    ini.main.font_flag_underline = s.font_flag_underline[0]
    ini.main.font_flag_strikeout = s.font_flag_strikeout[0]
    ini.main.lines = s.lines[0]
    ini.main.line_space = s.line_space[0]
    ini.pos.x = pos.x
    ini.pos.y = pos.y
    ini.main.auto_align = s.auto_align[0]
    json(json_file):write(list)
    inicfg.save(ini, directIni)
end

function isBlacklisted(text)
    for i = 1, #list do
        local t = string.rlower(list[i])
        if string.rlower(text):find(t) then
            return true
        end
    end
    return false
end

function sampev.onPlayerChatBubble(playerId, color, dist, duration, text)
    --print('{'..string.sub(bit.tohex(sampGetPlayerColor(playerId)), 3, 8)..'}'..sampGetPlayerNickname(playerId)..' ['..playerId..']: '..'{'..string.sub(bit.tohex(color), 1, 6)..'}'..text)
    if not isBlacklisted(text) and sampIsPlayerConnected(playerId) or playerId == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
        
        --if s.mode[0] == 1 then
        --    text = 'MODE 1 {'..string.sub(bit.tohex(color), 1, 6)..'}'..text..' :{'..string.sub(bit.tohex(sampGetPlayerColor(playerId)), 3, 8)..'}'..sampGetPlayerNickname(playerId)..' ['..playerId..']'
        --end
        table.insert(chat, {name = '{'..string.sub(bit.tohex(sampGetPlayerColor(playerId)), 3, 8)..'}'..sampGetPlayerNickname(playerId)..' ['..playerId..']', text = '{'..string.sub(bit.tohex(color), 1, 6)..'}'..text})
    end
end

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 305, 435
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('StreamChat by chapo', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
       
        imgui.Checkbox(u8'���������� ���', s.enabled)
        if imgui.InputInt(u8'������', s.line_space) then updateFont() save() end
        if imgui.InputInt(u8'���-�� �����', s.lines) then updateFont() save() end

        imgui.Combo(u8'������', s.mode, s.mode_list, 2)
        imgui.Checkbox(u8'�������������� ������������', s.auto_align)
        
        imgui.Text(u8'�����:')
        if imgui.InputText(u8'�����', s.font_name, 128) then updateFont() save() end
        if imgui.InputInt(u8'������ ������', s.font_size) then updateFont() save() end
        if imgui.Checkbox(u8'������', s.font_flag_bold) then updateFont() save() end
        if imgui.Checkbox(u8'������', s.font_flag_italic) then updateFont() save() end
        if imgui.Checkbox(u8'�������', s.font_flag_border) then updateFont() save() end
        if imgui.Checkbox(u8'����', s.font_flag_shadow) then updateFont() save() end
        if imgui.Checkbox(u8'�������������', s.font_flag_underline) then updateFont() save() end
        if imgui.Checkbox(u8'�����������', s.font_flag_strikeout) then updateFont() save() end
        imgui.Separator()
        if imgui.Button(u8'�������� ���������', imgui.ImVec2(sizeX - 10, 20)) then
            posedit = not posedit 
            if posedit then
                sampAddChatMessage('��� ���������� ��������� ����� ��� (����� ������ ����)', -1)
            end
        end
        if imgui.Button(u8'������ ������ ����', imgui.ImVec2(sizeX - 10, 20)) then
            imgui.OpenPopup(u8'������ ������ ����')
        end
        imgui.Tooltip(u8'���� ���� �� ���� ����� �� ������ ����� ������� � ���������, �� ��� ����� ��������������� ��������.\n��������� �������� ����� � ������� "������", "������ ���������" � �.�.')
        if imgui.BeginPopupModal(u8'������ ������ ����', _, imgui.WindowFlags.NoResize) then
            local pSize = imgui.ImVec2(300, 500)
            imgui.SetWindowSizeVec2(pSize)
            imgui.Text(u8'�����')
            imgui.SameLine(50)
            imgui.PushItemWidth(pSize.x - 55)
            imgui.InputText(u8'##�����', NIGGER_LIST_ADD_TEXT, 128)
            imgui.PopItemWidth()
            imgui.SetCursorPosX(5)
            if imgui.Button(u8'��������', imgui.ImVec2(pSize.x - 10, 20)) then 
                table.insert(list, u8:decode(ffi.string(NIGGER_LIST_ADD_TEXT)))
                save()
            end
            imgui.SetCursorPosX(5)
            if imgui.Button(u8'������� ���������', imgui.ImVec2(pSize.x - 10, 20)) then 
                table.remove(list, NIGGER_LIST_SELCTED)
                save()
            end

            imgui.SetCursorPos(imgui.ImVec2(5, 100))
            imgui.BeginChild('s', imgui.ImVec2(pSize.x - 10, pSize.y - 35 - 35 - 70), true)
            for i = 1, #list do
                if list[i] ~= nil then
                    if imgui.Selectable(u8(list[i]), NIGGER_LIST_SELCTED == i) then NIGGER_LIST_SELCTED = i save() end
                end
            end
            imgui.EndChild()
            imgui.SetCursorPos(imgui.ImVec2(5, pSize.y - 30))
            if imgui.Button(u8'�������', imgui.ImVec2(pSize.x - 10, 20)) then
                save()
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        local KTO_UDALIT_TOT_GOMOSEK = 'by chapo - vk.com/chaposcripts'
        imgui.SetCursorPosX(sizeX / 2 - imgui.CalcTextSize(KTO_UDALIT_TOT_GOMOSEK).x / 2)
        imgui.TextDisabled(KTO_UDALIT_TOT_GOMOSEK) 
        imgui.End()
    end
)

function renderFontDrawTextAutoAlign(font, text, x, y, color)
    local sw, sh = getScreenResolution()
    if x <= sw/3 then renderFontDrawText(font, text, x, y, color)
    elseif x <= sw/1.5 then renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    else renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
end

function imgui.Tooltip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(text)
        imgui.EndTooltip()
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage('[KingTools] {ffffff}������� ��� ��� �������� �������. ( /stream )', 0x00ffaa)
    sampAddChatMessage('[KingTools] {ffffff}��������� �������: {00ffaa}Chapo. {ffffff}����������� Tools: {00ffaa}King_Agressor', 0x00ffaa)
    if not doesFileExist(json_file) then
        local t = {
            '������',
            '������� ��',
            '�������',
            '��������',
            '�� ����',
            '�����',
            '�����',
            '������',
            '������',
            '�����'
        }
        json(json_file):write(t)
    end
    list = json(json_file):read()
    sampAddChatMessage('list: '..tostring(#list), -1)
    sampRegisterChatCommand('stream', function()
        renderWindow[0] = not renderWindow[0]
    end)
    while true do
        wait(0)
        if not renderWindow[0] and posedit then posedit = false end
        if s.enabled[0] then
            local x, y = pos.x, pos.y
            if posedit then
                x, y = getCursorPos()
                if wasKeyPressed(1) then
                    pos.x, pos.y = x, y
                    posedit = false
                    save()
                end
            end
            if s.auto_align[0] then
                renderFontDrawTextAutoAlign(font, '��� � ���� ������:', x, y, 0x80FFFFFF)
            else
                renderFontDrawText(font, '��� � ���� ������:', x, y, 0x80FFFFFF, 0x90000000)
            end
            y = y + s.line_space[0]
            for i = #chat - s.lines[0] + 1, #chat do
                if chat[i] ~= nil then
                    --
                    local text = chat[i].name..': '..chat[i].text
                    if s.mode[0] == 1 then
                        text = chat[i].text..' :'..chat[i].name
                    end
                    if s.auto_align[0] then
                        renderFontDrawTextAutoAlign(font, text, x, y, 0xFFFFFFFF)
                    else
                        renderFontDrawText(font, text, x, y, 0xFFFFFFFF, 0x90000000)
                    end
                    y = y + s.line_space[0]
                end
            end
        end
    end
end

function white_style()
    local vec2, vec4 = imgui.ImVec2, imgui.ImVec4
   local stl = imgui.GetStyle()
   local clrs, flg = stl.Colors, imgui.Col
    imgui.SwitchContext()
    imgui.GetStyle().WindowRounding        = 5.0
    imgui.GetStyle().ChildRounding        = 5.0
    imgui.GetStyle().FrameRounding        = 5.0
    imgui.GetStyle().FramePadding        = imgui.ImVec2(5, 3)
    imgui.GetStyle().WindowPadding        = imgui.ImVec2(8, 8)
    imgui.GetStyle().ButtonTextAlign    = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().WindowTitleAlign    = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().GrabMinSize        = 7
    imgui.GetStyle().GrabRounding        = 15

    imgui.GetStyle().Colors[imgui.Col.Text]                    = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]            = imgui.ImVec4(1.00, 1.00, 1.00, 0.20)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]                = imgui.ImVec4(0.07, 0.07, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                = imgui.ImVec4(0, 0, 0, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]            = imgui.ImVec4(0.90, 0.90, 0.90, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]        = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]            = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]              = imgui.ImVec4(0, 0, 0, 0.90)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]            = imgui.ImVec4(1, 1, 1, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]     = imgui.ImVec4(1, 1, 1, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]      = imgui.ImVec4(1, 1, 1, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]            = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]        = imgui.ImVec4(0.80, 0.80, 0.80, 0.80)

    imgui.GetStyle().Colors[imgui.Col.Button]                   = imgui.ImVec4(0, 0, 0, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]            = imgui.ImVec4(0, 0, 0, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]             = imgui.ImVec4(0, 0, 0, 1.00)

    imgui.GetStyle().Colors[imgui.Col.TitleBg]                    = imgui.ImVec4(0.07, 0.07, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]              = imgui.ImVec4(0.07, 0.07, 0.09, 1.00)

    imgui.GetStyle().Colors[imgui.Col.FrameBg]                  = imgui.ImVec4(0.3, 0.3, 0.3, 0.1)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]           = imgui.ImVec4(0.3, 0.3, 0.3, 0.1)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]            = imgui.ImVec4(0.3, 0.3, 0.3, 0.1)

    imgui.GetStyle().Colors[imgui.Col.Header]                   = imgui.ImVec4(0, 0, 0, 1)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]            = imgui.ImVec4(0, 0, 0, 1)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]             = imgui.ImVec4(0, 0, 0, 1)
end

local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- �
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end