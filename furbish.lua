local Furbish = CreateFrame('Frame', 'Furbish')

local OnUpdate = function(self, elapsed)
	local timeLeft = self.timeLeft - elapsed
	self.timeLeft = timeLeft

	if(timeLeft <= 0) then
		return self.Duration:SetText''
	elseif(timeLeft < 3600) then
		local m = math.floor(timeLeft / 60)
		if(m == 0) then
			self.Duration:SetFormattedText('%d', timeLeft % 60)
		else
			self.Duration:SetFormattedText('%d:%02d', m, timeLeft % 60)
		end
	else
		self.Duration:SetFormattedText(
			'%d.%2d h',
			math.floor(timeLeft / 3600),
			math.floor((timeLeft % 3600) / 60)
		)
	end
end

local Update = function(self, index)
	local name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura('player', index, self.filter)
	if(name) then
		if(duration > 0 and expirationTime) then
			if(not self.timeLeft) then
				self.timeLeft = expirationTime - GetTime()
				self:SetScript('OnUpdate', OnUpdate)
			else
				self.timeLeft = expirationTime - GetTime()
			end
		else
			self:SetScript('OnUpdate', nil)
		end

		if(count > 1) then
			self.Count:SetText(count)
		else
			self.Count:SetText''
		end

		self.Overlay:Hide()
		if(self.filter == 'HARMFUL') then
			local color = DebuffTypeColor[dtype or 'none']
			self.Overlay:SetVertexColor(color.r, color.g, color.b)
			self.Overlay:Show()
		end

		self.Icon:SetTexture(texture)
	end
end

local OnAttributeChanged = function(self, attribute, value)
	if(attribute == 'index') then
		return Update(self, value)
	end
end

local Skin = function(self)
	local Icon = self:CreateTexture(nil, 'BORDER')
	Icon:SetTexCoord(.07, .93, .07, .93)
	Icon:SetAllPoints(self)
	self.Icon = Icon

	local Duration = self:CreateFontString(nil, 'OVERLAY')
	Duration:SetFontObject(SystemFont_Outline_Small)
	Duration:SetPoint('BOTTOM', 1, 1)
	self.Duration = Duration

	local Count = self:CreateFontString(nil, 'OVERLAY')
	Count:SetFontObject(NumberFontNormal)
	Count:SetPoint('TOP', self, 1, -4)
	self.Count = Count

	-- Use the default overlay texture until I can figure out something
	-- that looks... less shit
	local Overlay = self:CreateTexture(nil, 'OVERLAY')
	Overlay:SetTexture[[Interface\Buttons\UI-Debuff-Overlays]]
	Overlay:SetPoint'CENTER'
	Overlay:SetSize(33, 32)
	Overlay:SetTexCoord(.296875, .5703125, 0, .515625)
	self.Overlay = Overlay

	-- Kinda meh way to piggyback on the secure aura headers update loop.
	self:SetScript('OnAttributeChanged', OnAttributeChanged)

	self.filter = self:GetParent():GetAttribute'filter'
end

-- Expose ourselves:
for name, func in next, {
	Skin = Skin,
	Update = Update,
} do
	Furbish[name] = func
end
