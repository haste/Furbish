local name, namespace = ...
local Furbish = CreateFrame('Frame', 'Furbish')

local OnUpdate = function(self, elapsed)
	local timeLeft = self.timeLeft - elapsed
	self.timeLeft = timeLeft

	-- Handle refreshing of temporary enchants.
	if(self.offset) then
		local expiration = select(self.offset, GetWeaponEnchantInfo())
		if(expiration) then
			self.timeLeft = expiration / 1e3
		else
			self.timeLeft = 0
		end
	end

	if(timeLeft <= 0) then
		-- Kill the tracker so we don't end up with stuck timers.
		self.timeLeft = nil

		self.Duration:SetText''
		return self:SetScript('OnUpdate', nil)
	elseif(timeLeft < 3600) then
		local m = math.floor(timeLeft / 60)
		if(m == 0) then
			local animation = self.Animation
			if(timeLeft < 31) then
				if(not animation:IsPlaying()) then
					animation:Play()
				end
			elseif(animation:IsPlaying()) then
				animation:Stop()
			end

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

local UpdateAura = function(self, index)
	local name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(self:GetParent():GetAttribute'unit', index, self.filter)
	if(name) then
		if(duration > 0 and expirationTime) then
			local timeLeft = expirationTime - GetTime()
			if(not self.timeLeft) then
				self.timeLeft = timeLeft
				self:SetScript('OnUpdate', OnUpdate)
			else
				self.timeLeft = timeLeft
			end

			-- We do the check here as well, that way we don't have to check on
			-- every single OnUpdate call.
			if(timeLeft < 31) then
				if(not self.Animation:IsPlaying()) then
					self.Animation:Play()
				end
			elseif(self.Animation:IsPlaying()) then
				self.Animation:Stop()
			end
		else
			self.Animation:Stop()
			self.timeLeft = nil
			self.Duration:SetText''
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

local UpdateTempEnchant = function(self, slot)
	self.Icon:SetTexture(GetInventoryItemTexture('player', slot))
	self.Overlay:SetVertexColor(136/255, 57/255, 184/255)

	-- I'm afraid we'll need to use... MATH!
	local offset = 3 * (slot - 16) + 2
	local expiration = select(offset, GetWeaponEnchantInfo())
	if(expiration) then
		self.offset = offset
		self:SetScript('OnUpdate', OnUpdate)
	else
		self.offset = nil
		self.timeLeft = nil
		self:SetScript('OnUpdate', nil)
	end
end

local OnAttributeChanged = function(self, attribute, value)
	if(attribute == 'index') then
		return UpdateAura(self, value)
	elseif(attribute == 'target-slot') then
		return UpdateTempEnchant(self, value)
	end
end

local Skin = function(self)
	local proxy = self:GetName():sub(-11) == 'ProxyButton'
	local Icon = self:CreateTexture(nil, 'BORDER')
	Icon:SetTexCoord(.07, .93, .07, .93)
	Icon:SetAllPoints(self)
	self.Icon = Icon

	local Count = self:CreateFontString(nil, 'OVERLAY')
	Count:SetFontObject(NumberFontNormal)
	Count:SetPoint('TOP', self, 1, -4)
	self.Count = Count

	if(not proxy) then
		local Duration = self:CreateFontString(nil, 'OVERLAY')
		Duration:SetFontObject(SystemFont_Outline_Small)
		Duration:SetPoint('BOTTOM', 1, 1)
		self.Duration = Duration

		-- Use the default overlay texture until I can figure out something
		-- that looks... less shit
		local Overlay = self:CreateTexture(nil, 'OVERLAY')
		Overlay:SetTexture[[Interface\Buttons\UI-Debuff-Overlays]]
		Overlay:SetPoint'CENTER'
		Overlay:SetSize(33, 32)
		Overlay:SetTexCoord(.296875, .5703125, 0, .515625)
		self.Overlay = Overlay

		local Animation = self:CreateAnimationGroup()
		Animation:SetLooping'BOUNCE'

		local FadeOut = Animation:CreateAnimation'Alpha'
		FadeOut:SetChange(-.7)
		FadeOut:SetDuration(.7)
		FadeOut:SetSmoothing'IN_OUT'

		self.Animation = Animation

		-- Kinda meh way to piggyback on the secure aura headers update loop.
		self:SetScript('OnAttributeChanged', OnAttributeChanged)

		self.filter = self:GetParent():GetAttribute'filter'
	else
		local Overlay = self:CreateTexture(nil, 'OVERLAY')
		Overlay:SetTexture[[Interface\Buttons\BuffConsolidation]]
		Overlay:SetPoint'CENTER'
		Overlay:SetSize(64, 64)
		Overlay:SetTexCoord(0, .5, 0, 1)
		self.Overlay = Overlay
	end
end

Furbish:SetScript('OnEvent', function(self, event, ...)
	self[event](self, event, ...)
end)

function Furbish:PLAYER_ENTERING_WORLD()
	for _, header in next, namespace do
		local child = header:GetAttribute'child1'
		local i = 1
		while(child) do
			UpdateAura(child, child:GetID())

			i = i + 1
			child = header:GetAttribute('child' .. i)
		end
	end
end
Furbish:RegisterEvent'PLAYER_ENTERING_WORLD'

-- Expose ourselves:
for name, func in next, {
	Skin = Skin,
	Update = Update,
} do
	Furbish[name] = func
end
