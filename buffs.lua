local b, d = 1, 1

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
		if(b ~= BUFF_MAX_DISPLAY) then
			while(updateIcon('BuffButton', b)) do
				b = b + 1
			end
		end

		if(d ~= DEBUFF_MAX_DISPLAY) then
			while(updateIcon('DebuffButton', d)) do
				d = d + 1
			end
		end
	end

	if(b == BUFF_MAX_DISPLAY and d == DEBUFF_MAX_DISPLAY) then
		self:UnregisterEvent'UNIT_AURA'
		self.UNIT_AURA = nil
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
