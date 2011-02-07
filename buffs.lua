-- Some global madness:
hooksecurefunc('BuffFrame_UpdatePositions', function()
	BUFF_ROW_SPACING = 5
end)

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
		duration:SetDrawLayer'OVERLAY'

		-- We use y:-2, as the text is larger...
		count:ClearAllPoints()
		count:SetPoint('TOP', 1, -2)
		count:SetDrawLayer'OVERLAY'

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

local proxy = {
	NORMAL_FONT_COLOR = {r = 1, g = 1, b = 1},
}

-- Handle widescreen correctly.
local width, height = string.split('x', GetCVar'gxResolution')
if(width/height > 4/3) then
	proxy.BUFFS_PER_ROW = 12
else
	proxy.BUFFS_PER_ROW = 8
end

local env = setmetatable(proxy, {__index = _G})
setfenv(AuraButton_UpdateDuration, env)
setfenv(BuffFrame_UpdateAllBuffAnchors, env)
setfenv(DebuffButton_UpdateAnchors, env)

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
	local r, g, b = 136/255, 57/255, 184/255
	for i = 1, 3 do
		updateIcon('TempEnchant', i)

		local fn = _G['TempEnchant' .. i .. 'Border']
		fn:SetTexture(1, 1, 1)
		fn:SetVertexColor(r, g, b)
		fn:SetBlendMode'MOD'
		_G['TempEnchant' .. i .. 'Duration']:SetDrawLayer'OVERLAY'
	end

	self:UnregisterEvent'PLAYER_ENTERING_WORLD'
	self.PLAYER_ENTERING_WORLD = nil
end

addon:SetScript('OnEvent', function(self, event, unit)
	self[event](self, unit)
end)

addon:RegisterEvent'UNIT_AURA'
addon:RegisterEvent'PLAYER_ENTERING_WORLD'
