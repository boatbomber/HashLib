local Alphabet = {}
local Indexes = {}

-- A-Z
for Index = 65, 90 do
	table.insert(Alphabet, Index)
end

-- a-z
for Index = 97, 122 do
	table.insert(Alphabet, Index)
end

-- 0-9
for Index = 48, 57 do
	table.insert(Alphabet, Index)
end

table.insert(Alphabet, 43) -- +
table.insert(Alphabet, 47) -- /

for Index, Character in ipairs(Alphabet) do
	Indexes[Character] = Index
end

local Base64 = {}

local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift
local bit32_band = bit32.band

--[[**
	Encodes a string in Base64.
	@param [t:string] Input The input string to encode.
	@returns [t:string] The string encoded in Base64.
**--]]
function Base64.Encode(Input: string): string
	local InputLength = #Input
	local Output = table.create(4 * math.floor((InputLength - 1) / 3) + 4) -- Credit to AstroCode for finding the formula.
	local Length = 0

	for Index = 1, InputLength, 3 do
		local C1, C2, C3 = string.byte(Input, Index, Index + 2)

		local A = bit32_rshift(C1, 2)
		local B = bit32_lshift(bit32_band(C1, 3), 4) + bit32_rshift(C2 or 0, 4)
		local C = bit32_lshift(bit32_band(C2 or 0, 15), 2) + bit32_rshift(C3 or 0, 6)
		local D = bit32_band(C3 or 0, 63)

		Output[Length + 1] = Alphabet[A + 1]
		Output[Length + 2] = Alphabet[B + 1]
		Output[Length + 3] = C2 and Alphabet[C + 1] or 61
		Output[Length + 4] = C3 and Alphabet[D + 1] or 61
		Length += 4
	end

	local Preallocate = math.ceil(Length / 4096)
	if Preallocate == 1 then
		return string.char(table.unpack(Output, 1, math.min(4096, Length)))
	else
		local NewOutput = table.create(Preallocate)
		local NewLength = 0

		for Index = 1, Length, 4096 do
			NewLength += 1
			NewOutput[NewLength] = string.char(table.unpack(Output, Index, math.min(Index + 4096 - 1, Length)))
		end

		return table.concat(NewOutput)
	end
end

--[[**
	Decodes a string from Base64.
	@param [t:string] Input The input string to decode.
	@returns [t:string] The newly decoded string.
**--]]
function Base64.Decode(Input: string): string
	local InputLength = #Input
	local Output = table.create(InputLength / 3 * 4)
	local Length = 0

	for Index = 1, InputLength, 4 do
		local C1, C2, C3, C4 = string.byte(Input, Index, Index + 3)

		local I1 = Indexes[C1] - 1
		local I2 = Indexes[C2] - 1
		local I3 = (Indexes[C3] or 1) - 1
		local I4 = (Indexes[C4] or 1) - 1

		local A = bit32_lshift(I1, 2) + bit32_rshift(I2, 4)
		local B = bit32_lshift(bit32_band(I2, 15), 4) + bit32_rshift(I3, 2)
		local C = bit32_lshift(bit32_band(I3, 3), 6) + I4

		Length += 1
		Output[Length] = A
		if C3 ~= 61 then
			Length += 1
			Output[Length] = B
		end

		if C4 ~= 61 then
			Length += 1
			Output[Length] = C
		end
	end

	local Preallocate = math.ceil(Length / 4096)
	if Preallocate == 1 then
		return string.char(table.unpack(Output, 1, math.min(4096, Length)))
	else
		local NewOutput = table.create(Preallocate)
		local NewLength = 0

		for Index = 1, Length, 4096 do
			NewLength += 1
			NewOutput[NewLength] = string.char(table.unpack(Output, Index, math.min(Index + 4096 - 1, Length)))
		end

		return table.concat(NewOutput)
	end
end

return Base64
