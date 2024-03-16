script_name("DTime")
script_author("Devil")

require 'lib.moonloader'
require 'lib.sampfuncs'
local font_flag = require('moonloader').font_flag
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding' -- загружаем библиотеку
encoding.default = 'CP1251' -- указываем кодировку по умолчанию, она должна совпадать с кодировкой файла. CP1251 - это Windows-1251
u8 = encoding.UTF8 -- и создаём короткий псевдоним для кодировщика UTF-8
local my_font = renderCreateFont('Comic Sans MS', 30)
local my_font1 = renderCreateFont('Impact', 25)
local my_font2 = renderCreateFont('Impact', 25)

wx, wy = getScreenResolution()
local mainIni=
({
	all=
	{
		iniFont = 'Courier New',
		iniHeight = 30,
		iniVar = 5,
		color= "{FF0000}",
		isRainbow = false,
		isEnable = true,
		isEnable1 = false,
		translate = true,
		rainbowSpeed = 2,
		timePosX = wx / 10,
		timePosY = wy / 2,
		datePosX = wx / 10,
		datePosY = wy -200,
		MSK = false
	}
})
inicfg.load(mainIni, "timesettings")
local buf = imgui.ImBuffer(4)
local fontbuf = imgui.ImBuffer(256)
local iniHeight = imgui.ImFloat(mainIni.all.iniHeight)
local state = imgui.ImBool(false)
local rainbowSpeed = imgui.ImFloat(mainIni.all.rainbowSpeed)
local isEnable = imgui.ImBool(mainIni.all.isEnable)
local isEnable1 = imgui.ImBool(mainIni.all.isEnable1)
local timePosX = imgui.ImFloat(mainIni.all.timePosX)
local timePosY = imgui.ImFloat(mainIni.all.timePosY)
local datePosX = imgui.ImFloat(mainIni.all.datePosX)
local datePosY = imgui.ImFloat(mainIni.all.datePosY)
local translate = imgui.ImBool(mainIni.all.translate)
local redTime = 0
local redDate = 0
local MSK = imgui.ImBool(mainIni.all.MSK)

function fontUpdate()
	customFont = renderCreateFont(mainIni.all.iniFont, mainIni.all.iniHeight, mainIni.all.iniVar)
end

fontUpdate()

function main()
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("dtime", test)
	lua_thread.create(alltime)
	apply_custom_style()
	while true do
		local unix_time = os.time(os.date('!*t'))
		moscow_time = unix_time + 3 * 60 * 60
		imgui.Process = state.v
		if mainIni.all.isRainbow then
			local r,g,b = rainbow(rainbowSpeed.v, 255)
			local clr = join_argb(0, r , g , b)
			mainIni.all.color = "{"..('%06X'):format(clr).."}"
		end

		if redTime == 1 then
			imgui.Process = false
			showCursor(true)
			mouseX, mouseY = getCursorPos()
			renderFontDrawText(customFont, os.date(mainIni.all.color.."%H:%M:%S"), mouseX, mouseY, 0xFFFFFFFF)
			if isKeyJustPressed(VK_LBUTTON) then redTime = 0 mainIni.all.timePosX = mouseX mainIni.all.timePosY = mouseY timePosX.v = mouseX timePosY.v = mouseY inicfg.save(mainIni, "timesettings")
				imgui.Process = true
			end
		end

		if redDate == 1 then
			imgui.Process = false
			showCursor(true)
			mouseX, mouseY = getCursorPos()
			thatDate = os.date("%A")
			if translate.v then
				if thatDate == "Sunday" then thatDate = "Воскресенье" end
				if thatDate == "Monday" then thatDate = "Понедельник" end
				if thatDate == "Tuesday" then thatDate = "Вторник" end
				if thatDate == "Wednesday" then thatDate = "Среда" end
				if thatDate == "Thursday" then thatDate = "Четверг" end
				if thatDate == "Friday" then thatDate = "Пятница" end
				if thatDate == "Saturday" then thatDate = "Суббота" end
			end
			renderFontDrawText(customFont, mainIni.all.color..thatDate, mouseX, mouseY, 0xFFFFFFFF)
			if isKeyJustPressed(VK_LBUTTON) then redDate = 0 mainIni.all.datePosX = mouseX mainIni.all.datePosY = mouseY datePosX.v = mouseX datePosY.v = mouseY inicfg.save(mainIni, "timesettings")
				imgui.Process = true
			end
		end
		wait(0)
	end
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

local color = imgui.ImFloat3(1.0, 1.0, 1.0)

function test()
	if state.v then state.v = false showCursor(false) else state.v = true showCursor(true) end
end

function rainbow(speed, alpha)
  local r = math.floor(math.sin(os.clock() * speed) * 127 + 128)
  local g = math.floor(math.sin(os.clock() * speed + 2) * 127 + 128)
  local b = math.floor(math.sin(os.clock() * speed + 4) * 127 + 128)
return r,g,b,alpha
end

function imgui.OnDrawFrame()
	imgui.SetNextWindowPos(imgui.ImVec2(wx / 2, wy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver)
	imgui.Begin(" ", 0,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
	imgui.InputText(u8"Стиль: "..mainIni.all.iniVar, buf)
	imgui.SameLine()
	if imgui.Button("+1") then if mainIni.all.iniVar ~= 64 then mainIni.all.iniVar = mainIni.all.iniVar + 1 fontUpdate() end end
	imgui.SameLine()
	if imgui.Button("-1") then if mainIni.all.iniVar ~= 0 then mainIni.all.iniVar = mainIni.all.iniVar - 1 fontUpdate() end end
	imgui.SameLine()
	if imgui.Button(u8"Поставить стиль") then if tonumber(buf.v) then mainIni.all.iniVar = buf.v fontUpdate() end end
	imgui.Text(u8"Всего стилей: 64")
	if imgui.ColorEdit3(u8'Цвет', color) then
        local clr = join_argb(0, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
        print(('%06X'):format(clr))
				mainIni.all.color = "{"..('%06X'):format(clr).."}"
  end
	imgui.Separator()
	if imgui.Button(u8"Режим радуги") then
		if mainIni.all.isRainbow then mainIni.all.isRainbow = false else mainIni.all.isRainbow = true end
	end
	imgui.SliderFloat(u8"Скорость радуги", rainbowSpeed, 0.2, 20, 0, 1)
	mainIni.all.rainbowSpeed = rainbowSpeed.v
	imgui.Separator()
	imgui.Checkbox(u8"Время МСК", MSK)
	imgui.SliderFloat(u8"Размер", iniHeight, 10, 100, 0, 1)
	imgui.SameLine()
	if imgui.Button(u8("Поставить размер")) then mainIni.all.iniHeight = iniHeight.v fontUpdate() end
	imgui.Checkbox(u8"Включить показ времени", isEnable)
	if isEnable.v then
		if imgui.Button(u8"Задать позицию времени мышкой", 75, 20) then redTime = 1 end
		imgui.SliderFloat(u8"Позиция X", timePosX, 0, wx, 0, 1)
		imgui.SliderFloat(u8"Позиция Y", timePosY, 0, wy, 0, 1)
	end
	imgui.Checkbox(u8"Включить показ дня недели", isEnable1)
	if isEnable1.v then
		if imgui.Button(u8"Задать позицию дня недели мышкой", 75, 20) then redDate = 1 end
		imgui.SliderFloat(u8"Позиция X ", datePosX, 0, wx, 0, 1)
		imgui.SliderFloat(u8"Позиция Y ", datePosY, 0, wy, 0, 1)
	end
	imgui.Checkbox(u8"Русские дни-недели", translate)
	imgui.Separator()
	imgui.InputText(" ", fontbuf)
	imgui.SameLine()
	if imgui.Button(u8"Поставить шрифт") then mainIni.all.iniFont = fontbuf.v fontUpdate() end
	imgui.Text(u8"Если шрифт ставится стандартный, возможно в регистре он записан не так или же он вовсе не установлен")
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 175) / 2);
	if imgui.Button(u8"Сохранить все изменения", imgui.ImVec2(175, 20)) then mainIni.all.datePosX = datePosX.v mainIni.all.datePosY = datePosY.v mainIni.all.timePosX = timePosX.v mainIni.all.timePosY = timePosY.v mainIni.all.isEnable1 = isEnable1.v mainIni.all.MSK = MSK.v mainIni.all.translate = translate.v inicfg.save(mainIni, "timesettings") end
	imgui.Text(" ")
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 300) / 2)
	imgui.Text(u8"Буду рад если подкинете немножко на покушать) ")
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 300) / 2)
	imgui.Text(u8"Киви - 79044632755, Карта - 5469 6700 2657 7356 ")
	imgui.End()
end

function alltime()
	while true do
		wait(0)
		if isEnable.v and redTime == 0 and not MSK.v then
			renderFontDrawText(customFont, os.date(mainIni.all.color.."%H:%M:%S"), timePosX.v, timePosY.v, 0xFFFFFFFF)
		end
		if isEnable.v and MSK.v then
			renderFontDrawText(customFont, os.date(mainIni.all.color..'%H:%M:%S', moscow_time), timePosX.v, timePosY.v, 0xFFFFFFFF)
		end
		if isEnable1.v and redDate == 0 then
			thatDate = os.date("%A")
			if translate.v then
				if thatDate == "Sunday" then thatDate = "Воскресенье" end
				if thatDate == "Monday" then thatDate = "Понедельник" end
				if thatDate == "Tuesday" then thatDate = "Вторник" end
				if thatDate == "Wednesday" then thatDate = "Среда" end
				if thatDate == "Thursday" then thatDate = "Четверг" end
				if thatDate == "Friday" then thatDate = "Пятница" end
				if thatDate == "Saturday" then thatDate = "Суббота" end
			end
			renderFontDrawText(customFont, mainIni.all.color..thatDate, datePosX.v, datePosY.v, 0xFFFFFFFF)
		end
	end
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
