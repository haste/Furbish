local buff, debuff = 1, 1

local updateIcon = function(name, id)
	local base = _G[('%s%d'):format(name, id)]
	local icon = _G[('%s%dIcon'):format(name, id)]
	local duration = _G[('%s%dDuration'):format(name, id)]
	local count = _G[('%s%dCount'):format(name, id)]
	local border = _G[('%s%dBorder'):format(name, id)]

	if(icon) then
		icon:SetTexCoord(.07, .93, .07, .93)

		local font, size = duration:GetFont()
		duration:SetFont(font, size, 'OUTLINE')
		duration:ClearAllPoints()
		-- We use x:1, due to my font
		duration:SetPoint('BOTTOM', 1, 1)

		-- We use y:-2, as the text is larger...
		count:ClearAllPoints()
		count:SetPoint('TOP', 1, -2)

		-- Let's outsmart it!
		if(border) then
			border:SetWidth(border:GetHeight())
			border:SetTexture(1, 1, 1)
			border:SetBlendMode'MOD'
		end

		return true
	end
end

-- Env. proxy, it's here to make the aura duration white, without hooking or
-- changing the real global.
local env = setmetatable({
	NORMAL_FONT_COLOR = {r = 1, g = 1, b = 1}
}, {__index = _G})

setfenv(BuffFrame_UpdateDuration, env)

local addon = CreateFrame'Frame'

function addon:UNIT_AURA(unit)
	if(unit == 'player') then
		if(buff ~= BUFF_MAX_DISPLAY) then
			while(updateIcon('BuffButton', buff)) do
				buff = buff + 1
			end
		end

		if(debuff ~= DEBUFF_MAX_DISPLAY) then
			while(updateIcon('DebuffButton', debuff)) do
				debuff = debuff + 1
			end
		end
	end

	if(buff == BUFF_MAX_DISPLAY and debuff == DEBUFF_MAX_DISPLAY) then
		self:UnregisterEvent'UNIT_AURA'
		self.UNIT_AURA = nil
		self:SetScript('OnEvent', nil)
		updateIcon = nil
	end
end

function addon:PLAYER_ENTERING_WORLD()
	self:UNIT_AURA'player'

	-- Do the temp enchants
	updateIcon('TempEnchant', 1)
	updateIcon('TempEnchant', 2)

	local r, g, b = 136/255, 57/255, 184/255
	TempEnchant1Border:SetTexture(1, 1, 1)
	TempEnchant1Border:SetVertexColor(r, g, b)
	TempEnchant1Border:SetBlendMode'MOD'
	TempEnchant1Duration:SetDrawLayer"OVERLAY"

	TempEnchant2Border:SetTexture(1, 1, 1)
	TempEnchant2Border:SetVertexColor(r, g, b)
	TempEnchant2Border:SetBlendMode'MOD'
	TempEnchant2Duration:SetDrawLayer"OVERLAY"

	self:UnregisterEvent'PLAYER_ENTERING_WORLD'
	self.PLAYER_ENTERING_WORLD = nil
end

addon:SetScript('OnEvent', function(self, event, unit)
	self[event](self, unit)
end)

addon:RegisterEvent'UNIT_AURA'
addon:RegisterEvent'PLAYER_ENTERING_WORLD'
