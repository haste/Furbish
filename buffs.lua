local buff, debuff = 1, 1

local updateIcon = function(name, id)
	local icon = _G[('%s%dIcon'):format(name, id)]

	if(icon) then
		icon:SetTexCoord(.07, .93, .07, .93)

		return true
	end
end

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

	self:UnregisterEvent'PLAYER_ENTERING_WORLD'
	self.PLAYER_ENTERING_WORLD = nil
end

addon:SetScript('OnEvent', function(self, event, unit)
	self[event](self, unit)
end)

addon:RegisterEvent'UNIT_AURA'
addon:RegisterEvent'PLAYER_ENTERING_WORLD'
