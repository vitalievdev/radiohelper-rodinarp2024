script_name('ScoreBoard')
script_version_number(3)
script_version("1.2-beta")
require 'libstd.deps'{
    'fyp:mimgui@1.4.1', 'fyp:samp-lua', 'donhomka:extensions-lite@1.0.3'
}

require 'extensions-lite'
local imgui, ffi = require 'mimgui', require 'ffi'
local SE = require 'samp.events'
local new, str = imgui.new, ffi.string
local vkeys = require 'vkeys'
local encoding = require 'encoding'
local memory = require 'memory'
local bitex = require 'bitex'
local wm = require 'lib.windows.message'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local lockKeys = {
    [vkeys.VK_T] = true,
    [vkeys.VK_RETURN] = true,
    [vkeys.VK_F] = true,
    [vkeys.VK_F6] = true
}

local tBlockChar = {[116] = true, [84] = true}
local bWindow = new.bool()
local szSearch = new.char[24]()
local imgSearch = nil
local closeSearch = false
local searchNow = false

local renderOffset, renderChatAddr, byte = 0x64230, 0x0, 1

local iGamestate = -1

local tScoreboard = {}
local tScoreboardData = {}
local localPlayerId = -1

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end
    renderOffset = sampGetBase() + renderOffset
    renderChatAddr = memory.read(renderOffset, byte, true)
    init()
    while true do
        wait(0)
        local gs = sampGetGamestate()
        if gs ~= iGamestate then
            if gs == 1 and #tScoreboard > 0 then
                tScoreboard = {}
                tScoreboardData = {}
                localPlayerId = -1
            elseif gs == 3 then
                init()
            end
            iGamestate = gs
        end
        displayHud(not bWindow[0])
        displayRadar(not bWindow[0])
    end
end

function init()
    local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if result and localPlayerId == -1 then
        localPlayerId = id
        for i = 0, 999 do
            local data = tScoreboardData[i]
            if (sampIsPlayerConnected(i) or localPlayerId == i) and data == nil then
                table.insert(tScoreboard, i)
                tScoreboardData[i] = {
                    nickname = sampGetPlayerNickname(i),
                    color = sampGetPlayerColor(i)
                }
            end
        end
        table.sort(tScoreboard, function(a, b)
            if a == localPlayerId then
                return true
            elseif b == localPlayerId then
                return false
            else
                return a < b
            end
        end)
    end
end

function onWindowMessage(msg, wparam, lparam)
    if msg == wm.WM_KEYDOWN or msg == wm.WM_KEYUP then
        if bWindow[0] and lockKeys[wparam] then
            consumeWindowMessage(true, true)
        elseif wparam == vkeys.VK_TAB then
            if msg == wm.WM_KEYUP and not sampIsChatInputActive() and
                not sampIsDialogActive() then toggleScoreboard() end
            consumeWindowMessage(true, false)
        elseif wparam == vkeys.VK_ESCAPE and bWindow[0] and
            not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            if msg == wm.WM_KEYUP then
                if closeSearch then
                    closeSearch = false
                else
                    toggleScoreboard(false)
                end
            end
        end
    elseif msg == wm.WM_CHAR then
        if bWindow[0] and tBlockChar[wparam] then
            consumeWindowMessage(true, true)
        end
    end
end
function toggleScoreboard(bool)
    local bool = bool or not bWindow[0]
    bWindow[0] = bool
    if bWindow[0] then
        memory.fill(renderOffset, 0xC3, byte, true)
    else
        memory.write(renderOffset, renderChatAddr, byte, true)
    end
end

function onExitScript() memory.write(renderOffset, renderChatAddr, byte, true) end

function onScriptTerminate(scr)
    if scr == script.this then
        memory.write(renderOffset, renderChatAddr, byte, true)
    end
end

function apply_custom_style()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowRounding = 1.5
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.FrameRounding = 1.0
    style.ItemSpacing = imgui.ImVec2(0.0, 0.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    style.WindowBorderSize = 0.0
    style.WindowPadding = imgui.ImVec2(0.0, 0.0)
    style.FramePadding = imgui.ImVec2(2.5, 3.5)
    style.ButtonTextAlign = imgui.ImVec2(0.02, 0.4)

    -- local mainc = imgui.ImVec4(0.0, 0.55, 0.0, 1.0)
    local mainc = imgui.ImVec4(0.0, 0.46, 0.69, 1.0)
    -- local mainc = imgui.ImVec4(0.33, 0.0, 0.74, 1.0)

    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg] = imgui.ImVec4(0.0, 0.0, 0.0, 0.6)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border] = imgui.ImVec4(0.0, 0.56, 0.60, 0.4)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
    colors[clr.FrameBgHovered] = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
    colors[clr.FrameBgActive] = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
    colors[clr.TitleBg] = imgui.ImVec4(0.15, 0.55, 0.43, 1.0)
    colors[clr.TitleBgActive] = imgui.ImVec4(0.15, 0.55, 0.43, 1.0)
    colors[clr.TitleBgCollapsed] = ImVec4(0.05, 0.05, 0.05, 0.79)
    colors[clr.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab] = imgui.ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.28, 0.28, 0.28, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.35, 0.35, 0.35, 1.00)
    colors[clr.Button] = imgui.ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
    colors[clr.ButtonHovered] = imgui.ImVec4(mainc.x, mainc.y, mainc.z, 0.63)
    colors[clr.ButtonActive] = imgui.ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
    colors[clr.Header] = imgui.ImVec4(0.0, 0.56, 0.60, 1.0)
    colors[clr.HeaderHovered] = ImVec4(0.0, 0.56, 0.60, 0.89)
    colors[clr.HeaderActive] = ImVec4(0.0, 0.56, 0.60, 0.94)
    colors[clr.Separator] = colors[clr.Border]
    colors[clr.SeparatorHovered] = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip] = imgui.ImVec4(0.15, 0.55, 0.43, 1.0)
    colors[clr.ResizeGripHovered] = imgui.ImVec4(0.15, 0.55, 0.43, 0.63)
    colors[clr.ResizeGripActive] = imgui.ImVec4(0.15, 0.55, 0.43, 1.0)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
end

function SE.onPlayerJoin(id, color, npc, nickname)
    print(id, color)
    local exists = tScoreboardData[id]
    if exists == nil and localPlayerId > -1 then
        table.insert(tScoreboard, id)
        table.sort(tScoreboard, function(a, b)
            if a == localPlayerId then
                return true
            elseif b == localPlayerId then
                return false
            else
                return a < b
            end
        end)
        -- local r, g, b, a = explode_argb(sampGetPlayerColor(id))
        -- local ncolor = join_argb(a, r, g, b)
        tScoreboardData[id] = {
            nickname = nickname,
            color = sampGetPlayerColor(id)
        }
    end
end

function SE.onPlayerQuit(id)
    local exists = tScoreboardData[id]
    if exists and localPlayerId > -1 then
        local key = table.getIndexOf(tScoreboard, id)
        if key then
            table.remove(tScoreboard, key)
            table.sort(tScoreboard, function(a, b)
                if a == localPlayerId then
                    return true
                elseif b == localPlayerId then
                    return false
                else
                    return a < b
                end
            end)
            tScoreboardData[id] = nil
        end
    end
end

function SE.onSetPlayerColor(id, color)
    local exists = tScoreboardData[id]
    if exists and localPlayerId > -1 then
        local r, g, b, a = explode_argb(color)
        local ncolor = join_argb(a, r, g, b)
        tScoreboardData[id].color = ncolor
    end
end

function SE.onSetPlayerName(id, name)
    local exists = tScoreboardData[id]
    if exists and localPlayerId > -1 then
        tScoreboardData[id].nickname = name
    end
end

local fonts, loadFonts = {}, false
imgui.OnInitialize(function()
    local x, y = getScreenResolution()
    apply_custom_style()
    local defGlyph = imgui.GetIO().Fonts.ConfigData.Data[0].GlyphRanges
    imgui.GetIO().Fonts:Clear()
    local font_config = imgui.ImFontConfig()
    -- font_config.OversampleH = 1;
    -- font_config.OversampleV = 1;
    -- font_config.PixelSnapH = true;
    font_config.SizePixels = 14.0
    font_config.GlyphExtraSpacing.x = 0.1
    local def = imgui.GetIO().Fonts:AddFontFromFileTTF(
                    getFolderPath(0x14) .. '\\arialbd.ttf',
                    font_config.SizePixels, font_config, defGlyph)
    def.DisplayOffset.x = 1.0
    fonts[14] = imgui.GetIO().Fonts:AddFontFromFileTTF(
                    getFolderPath(0x14) .. '\\arialbd.ttf', 14.0, font_config,
                    defGlyph)
    fonts[16] = imgui.GetIO().Fonts:AddFontFromFileTTF(
                    getFolderPath(0x14) .. '\\arialbd.ttf', 16.0, font_config,
                    defGlyph)
    fonts[17] = imgui.GetIO().Fonts:AddFontFromFileTTF(
                    getFolderPath(0x14) .. '\\arialbd.ttf', 17.0, font_config,
                    defGlyph)
    fonts[18] = imgui.GetIO().Fonts:AddFontFromFileTTF(
                    getFolderPath(0x14) .. '\\arialbd.ttf', 18.0, font_config,
                    defGlyph)

    imgSearch = imgui.CreateTextureFromFileInMemory(
                    new('const char*', search_data), #search_data)
end)

imgui.OnFrame(function() return bWindow[0] end, function()
    local w, h = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(0, 0))
    imgui.SetNextWindowSize(imgui.ImVec2(w, h))
    imgui.Begin('##main', bWindow,
                imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove +
                    imgui.WindowFlags.NoResize +
                    imgui.WindowFlags.NoBringToFrontOnFocus)
    local gDrawList = imgui.GetWindowDrawList()

    local pos = imgui.GetCursorScreenPos()
    local mainwidth = w / 2.7
    local height = 30.0
    gDrawList:AddRectFilled(pos, imgui.ImVec2(w, pos.y + 20.0), 0xcc000000)
    gDrawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y + 20.0), imgui.ImVec2(w, pos.y + 22.0), 0xFF000000)
    imgui.PushFont(fonts[18])
    gDrawList:AddText(imgui.ImVec2(pos.x + 34.0, pos.y + 2.0), 0xFFFFFFFF, u8(sampGetCurrentServerName()))
    gDrawList:AddText(imgui.ImVec2(pos.x + w - 104.0, pos.y + 2.0), 0xFFFFFFFF, "Online: " .. sampGetPlayerCount())
    imgui.PopFont()
    local idsize = imgui.CalcTextSize("ID")
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + w / 3.3, pos.y + 90))
    local pos = imgui.GetCursorScreenPos()
    gDrawList:AddRectFilled(pos, imgui.ImVec2(pos.x + mainwidth, pos.y + height), 0xFa030303)
    imgui.PushFont(fonts[16])
    local scoresize, pingsize = imgui.CalcTextSize("SCORE"), imgui.CalcTextSize("PING")
    gDrawList:AddText(imgui.ImVec2(pos.x + 22.0 - idsize.x / 2, pos.y + height / 2.0 - 1.0 - 7.0), 0xFFFFFFFF, "ID")
    gDrawList:AddText(imgui.ImVec2(pos.x + 44.0, pos.y + height / 2.0 - 1.0 - 7.0), 0xFFFFFFFF, "NICKNAME")
    gDrawList:AddText(imgui.ImVec2(pos.x + (mainwidth - 150.0) - (scoresize.x / 2.0) - (xOff or 0), pos.y + height / 2.0 - 1.0 - 7.0), 0xFFFFFFFF, "SCORE")
    gDrawList:AddText(imgui.ImVec2(pos.x + (mainwidth - 60.0) - (pingsize.x / 2.0) - (xOff or 0), pos.y + height / 2.0 - 1.0 - 7.0), 0xFFFFFFFF, "PING")
    imgui.PopFont()
    local pos = imgui.GetCursorScreenPos()
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + height + 2.0))
    imgui.BeginChild("##main", imgui.ImVec2(mainwidth, h - 180.0 - height))
    
    xOff = imgui.GetScrollMaxY() > 0.0 and imgui.GetStyle().ScrollbarSize + 2 or 0
    mainwidth = mainwidth - xOff
    local DrawList = imgui.GetWindowDrawList()
    local clipper = imgui.ImGuiListClipper(#tScoreboard)
    while #tScoreboard > 0 and clipper:Step() do
        for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
            local id = tScoreboard[i]
            local data = tScoreboardData[id]
            if id and data then
                local pos = imgui.GetCursorScreenPos()
                local a, r, g, b = explode_argb(data.color)
                -- local a, r, g, b = a / 255.0, r / 255.0, g / 255.0, b / 255.0
                local col32 = join_argb(255, b, g, r)
                local height = 24.0
                local idsize = imgui.CalcTextSize(tostring(id))
                local hovered = imgui.IsMouseHoveringRect(pos, imgui.ImVec2(pos.x + mainwidth, pos.y + height))
                local score, ping = tostring(sampGetPlayerScore(id)), tostring(sampGetPlayerPing(id))
                local scoresize, pingsize = imgui.CalcTextSize(score), imgui.CalcTextSize(ping)
                DrawList:AddRectFilled(pos, imgui.ImVec2(pos.x + mainwidth, pos.y + height), i % 2 == 0 and 0xcc090909 or 0xcc030303)
                DrawList:AddRectFilled(pos, imgui.ImVec2(pos.x + 5.5, pos.y + height), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 0.8)));
                if hovered then
                    if imgui.IsMouseDoubleClicked(0) then
                        sampSendClickPlayer(id, 1)
                        lua_thread.create(function()
                            wait(150)
                            toggleScoreboard(false)
                        end)
                    end
                    DrawList:AddRectFilledMultiColor(imgui.ImVec2(pos.x + 5.5, pos.y),
                                                        imgui.ImVec2(pos.x + mainwidth, pos.y + height),
                                                        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 0.4)),
                                                        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 0.0, 0.0, 0.0)),
                                                        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 0.0, 0.0, 0.0)),
                                                        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 0.4))
                                                    )
                end
                DrawList:AddText(imgui.ImVec2(pos.x + 24.0 - idsize.x / 2, pos.y + height / 2.0 - 1.0 - 7.0), col32, tostring(id))
                DrawList:AddText(imgui.ImVec2(pos.x + 44.0, pos.y + height / 2.0 - 1.0 - 7.0), col32, tostring(data.nickname))
                DrawList:AddText(imgui.ImVec2(pos.x + (mainwidth - 150.0) - (scoresize.x / 2.0), pos.y + height / 2.0 - 1.0 - 7.0), col32, score)
                DrawList:AddText(imgui.ImVec2(pos.x + (mainwidth - 60.0) - (pingsize.x / 2.0), pos.y + height / 2.0 - 1.0 - 7.0), col32, ping)
                imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + height + 2.0))
            end
        end
    end
    imgui.EndChild()

    imgui.End()
end)

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function join_argb(a, r, g, b)
    local argb = b -- b
    argb = bit.bor(argb, bit.lshift(g, 8)) -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

-- File: 'search.png' (1007 bytes)
-- Exported using binary_to_compressed_lua.cpp
search_data =
    '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x40\x00\x00\x00\x40\x08\x06\x00\x00\x00\xAA\x69\x71\xDE\x00\x00\x00\x04\x73\x42\x49\x54\x08\x08\x08\x08\x7C\x08\x64\x88\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x03\xF4\x00\x00\x03\xF4\x01\x27\x18\xCD\xD6\x00\x00\x00\x19\x74\x45\x58\x74\x53\x6F\x66\x74\x77\x61\x72\x65\x00\x77\x77\x77\x2E\x69\x6E\x6B\x73\x63\x61\x70\x65\x2E\x6F\x72\x67\x9B\xEE\x3C\x1A\x00\x00\x03\x6C\x49\x44\x41\x54\x78\x9C\xED\x9A\x4D\x48\x15\x51\x14\xC7\xCF\xF8\x8C\x0A\x0D\xFB\xB2\x2C\xDD\xD4\xA2\x20\xC8\x3E\xD4\xA0\x16\x41\x41\x9B\x76\x45\xB9\x89\x4A\x6B\x13\x54\x20\xD5\xAE\x4D\x5F\x50\x8B\x48\xA2\x68\x5F\x9B\x16\x11\x2D\xB2\xDA\xD5\xA2\x55\x54\x90\x45\x1F\x42\x1F\xA0\xBD\x34\x17\xF6\x61\x66\x10\xFA\x6B\x31\xA3\x8C\xE7\xCD\xE8\x1B\xBD\x33\x63\xCC\xFD\x81\xE0\x79\xDC\x77\xFE\xFF\x73\xE6\x71\xE7\xCE\xBD\x23\x62\xB1\x58\x2C\x96\xEC\xE2\xA4\x29\x0E\x94\x88\x48\x9D\x88\x6C\x16\x91\x06\x11\x59\x25\x22\x35\x6A\x58\x97\x88\xBC\x11\x91\xA7\x22\xF2\x58\x44\x9E\x3B\x8E\x33\x9C\xA4\x4F\xE3\x00\xD5\xC0\x05\xA0\x8B\xE8\x74\x02\xE7\x81\xA5\x69\xD7\x11\x19\x60\x1E\x70\x19\xF8\x33\x89\xC2\x35\x83\x40\x2B\x30\x37\xED\xBA\x8A\x02\xD8\x05\x7C\x35\x50\xB8\xA6\x07\xD8\x99\x76\x7D\xA1\x00\x33\x80\x6B\xE3\x14\xD0\x07\x5C\x07\xF6\x01\x0D\xC0\x62\xDC\x5F\xCA\x3C\xEF\xFF\x06\x60\x3F\x70\x03\xF8\x36\x4E\x9E\x2B\x40\x69\xDA\xF5\x8E\x01\x28\x03\x1E\x84\x18\x7E\x05\xEC\x01\x66\x46\xC8\x37\x0B\xD8\x0B\xBC\x0E\xC9\x79\x0F\x28\x8B\xB3\xA6\xA2\x01\x4A\x3D\x43\x9A\x5F\xC0\x61\x20\x37\x85\xDC\x39\xE0\x28\x30\x10\x90\xFF\xEE\x54\x72\x1B\x03\xB8\x1A\x60\xEE\x33\xB0\xDE\xA0\x46\x3D\x90\x0F\xD0\x69\x35\xA5\x31\x59\x63\x8D\x01\xA6\xDA\x81\xEA\x18\xB4\x6A\xBC\xDC\x7E\x86\x81\x1D\xA6\xB5\x8A\x35\x34\x1F\xE8\x55\x86\xF2\x71\x14\xEF\xD3\xAC\x02\x3E\x28\xCD\x1E\xD2\xB8\x45\xE2\xCE\xC6\x7E\x7E\x03\xF5\x09\xE8\xD6\x7A\x5A\x7E\x2E\xC5\xAD\xAB\x4D\x54\x53\xB8\xC8\x69\x49\x50\xFF\x64\x40\xF3\xAB\x92\xD2\x17\xDC\x25\xAA\x9F\x77\x24\x78\x6F\xC6\xBD\xED\x7E\x51\x1E\xCE\x25\x25\x9E\xC3\x9D\xE5\xFD\x34\x27\x22\x3E\xD6\xC7\x21\xE5\xA1\x13\xF7\xA1\x2B\x76\xE1\x4D\x4A\xF8\x3B\x30\x3B\x76\xE1\x42\x1F\x65\x40\xBF\xF2\xB2\x21\x6C\xBC\xC9\xCE\x6C\x51\x71\x9B\xE3\x38\x83\x06\xF3\x17\x85\xE3\x38\x03\x22\x72\x5F\x7D\xAC\xBD\x8D\x62\xB2\x01\x75\x2A\x7E\x64\x30\x77\x54\x1E\xAA\x38\xF4\x2E\x64\xB2\x01\x2B\x54\xFC\xD2\x60\xEE\xA8\xB4\xAB\x78\x65\xD8\x40\x93\x0D\x58\xA2\xE2\x4F\x06\x73\x47\xE5\xA3\x8A\xB5\xB7\x51\x4C\x36\xA0\x5C\xC5\x3F\x0D\xE6\x8E\xCA\x0F\x15\xCF\x09\x1B\x68\xB2\x01\x7A\x7F\x11\x83\xB9\x63\xC3\x64\x03\x06\x54\x5C\x61\x30\x77\x54\xB4\x76\x7F\xD8\x40\x93\x0D\xC8\xAB\x78\x99\xC1\xDC\x51\x59\xAE\xE2\xEE\xB0\x81\x26\x1B\xF0\x5E\xC5\xB5\x06\x73\x47\x65\x8D\x8A\x3B\xC2\x06\x9A\x6C\xC0\x13\x15\x87\x2E\x3E\x12\x60\xAB\x8A\x9F\xC5\xAE\x08\x6C\xFC\x1F\x97\xC2\x26\x85\x4B\x80\xEE\xCC\x3E\x0C\x79\xE2\xA7\x94\x78\x76\x1E\x87\x3D\x03\x95\x14\xEE\xD4\x66\x67\x43\xC4\x33\xA1\x77\x83\xB3\xB3\x25\xE6\x19\x59\x18\xF0\x33\xCC\xCE\xA6\xA8\x67\x68\x3B\xEE\xD6\xB4\x9F\x17\x40\x65\x0C\x5A\x8B\xBC\xDC\x7E\xD2\xDB\x16\xF7\x19\x6B\xA3\x90\xB7\xC0\x6A\x83\x1A\xB5\x40\x47\x80\x4E\xEA\x07\x23\x4D\xC0\x50\x80\x31\x70\x8F\xB5\x4F\x33\x85\x33\x3C\xA0\x1C\x38\x4B\xF0\x31\xFB\x2D\xD2\x3C\x1A\x9B\xA0\x78\x3F\x79\xE0\x00\xD1\x0F\x47\x0F\x52\x38\xC7\x8C\x70\x3B\x4A\x3E\xE3\x84\x14\x3F\x84\x7B\x60\xA9\xE7\x84\x11\x82\x8E\xC7\x73\xDE\x5F\xD4\xE3\xF1\x69\x77\xE5\x87\xF0\x56\x83\xC0\x36\xDC\x55\x99\x69\xD2\x7F\x41\x62\xA2\xE2\x7D\xE3\x2A\x80\x8B\x14\xAE\xD5\x27\xC3\xF4\x78\x45\x06\x68\x2E\xA6\x78\xF5\x9D\x05\xC0\x19\xEF\xEA\x45\x65\xFA\xBC\x24\x35\x99\xE2\xD5\xF7\x1D\xDC\x5B\x59\x0B\x70\x07\xF7\x98\xBB\xD7\x97\xB3\xCF\xFB\xEC\x26\x70\x0C\x77\x3E\x48\xE6\xC1\x66\x22\x70\xDF\xF2\xD0\x13\xDB\x5F\xA0\x31\x6D\x6F\xB1\x03\x1C\xB1\xC5\xDB\xE2\xC7\x14\xBF\x3B\x6D\x6F\xB1\x63\x8B\xB7\xC5\xDB\xE2\x33\x57\xFC\x3A\x82\x17\x39\x4D\x69\x7B\x4B\x0C\xE0\x44\xE6\xAE\xBC\x06\x38\x9E\xD9\xE2\x47\x00\xD6\xA6\xED\xC1\x62\xB1\x58\x2C\x16\xF3\xFC\x03\xA3\xE2\xBB\x53\xB7\x97\xC4\xF8\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82'
