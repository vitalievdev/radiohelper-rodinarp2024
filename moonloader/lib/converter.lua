-- Название библиотеки: Переводчик систем счисления и цвета v0.1
-- Автор: qwertyMAN
-- P.S. Можно переводить нестандартные системы счисления, с другими алфавитами и прочее.
-- Возможности безграничны, пополнять таблицу можно сколько угодно.
-- Примечание: lua, число формата 0x000000 (hex) будет автоматически переведить в десятичную систему счисления, без каких либо функций


local conv = {}

-- вспомогательная таблица
local table={}
table[10] = "A"
table[11] = "B"
table[12] = "C"
table[13] = "D"
table[14] = "E"
table[15] = "F"
table.A = 10
table.B = 11
table.C = 12
table.D = 13
table.E = 14
table.F = 15

-- Переводит десятичный вид в N-систему счисления
function conv.aEngine(input, n)
	local output=""
	while true do
		local cheloe = math.modf(input/n)	-- найдём целое число
		if cheloe == 0 then					--   END   --выход из цикла если вычисление завершено
			if table[input] then			-- THE END -- записывает последний символ в строку и возвращает значение
				return  table[input]..output
			else
				return  input..output
			end
		else
			local ost = tonumber(input) - cheloe*n	-- найдём остаток от деления
			if table[ost] then						-- запишем остаток как первый символ в последовательности
				output = table[ost]..output
			else
				output = ost..output
			end
			input = cheloe
		end
	end
end

-- Переводит N-систему счисления в десятичную
function conv.Engine(input, n)
	if n>11 then input=string.upper(input) end
	local sum = 0							-- Сумма
	local num = string.len(input)			-- Количество цифр в введённом числе
	for i=1, num do
		local number = string.sub(input, -i, -i)
		if table[number] then
			sum = sum + table[number]*n^(i-1)
		else
			sum = sum + tonumber(number)*n^(i-1)
		end
	end
	return sum
end

function conv.bin(input)
	return conv.Engine(input, 2)
end

function conv.oct(input)
	return conv.Engine(input, 8)
end

function conv.hex(input) -- принимает string. Не использовать для значения вида 0x000000
	return conv.Engine(input, 16)
end

function conv.abin(input)
	return conv.aEngine(input, 2)
end

function conv.aoct(input)
	return conv.aEngine(input, 8)
end

function conv.ahex(input) -- возвращает string
	return conv.aEngine(input, 16)
end

function conv.getThreeColor(input) -- принимает как текстовый HEX формат, так и числовой 0x000000, в том числе и простые цифры.
	if type(input)=="string" then input=conv.hex(input) end
	local r = math.modf(input/65536)
	input = input-r*65536
	local g = math.modf(input/256)
	b = input-g*256
	return r, g, b
end

function conv.getColor(r, g, b) -- принимает как текст, так и числа. Выводит числа.
	if type(r)=="string" then r=conv.hex(r) end
	if type(g)=="string" then g=conv.hex(g) end
	if type(b)=="string" then b=conv.hex(b) end
	local output = r*65536+g*256+b
	return output
end

function conv.invertColor(input)
	return 0xffffff-input
end

function conv.sumColor(color_1, color_2)
	local r1,g1,b1 = conv.getThreeColor(color_1)
	local r2,g2,b2 = conv.getThreeColor(color_2)
	local r = math.modf((r1+r2)/2)
	local g = math.modf((g1+g2)/2)
	local b = math.modf((b1+b2)/2)
	return conv.getColor(r, g, b)
end

return conv