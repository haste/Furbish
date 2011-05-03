for _, name in next, {
	'FurbishPlayerBuffs',
	'FurbishPlayerDebuffs',
} do
	local header = CreateFrame('Frame', name, UIParent, 'SecureAuraHeaderTemplate')
	header:SetAttribute('template', 'FurbishAuraTemplate')
	header:SetAttribute('unit', 'player')
	header:SetAttribute('xOffset', -35)

	local wrap
	local width, height = string.split('x', GetCVar'gxResolution')
	if(width/height > 4/3) then
		wrap = 12
	else
		wrap = 8
	end

	header:SetAttribute('minHeight', 35)
	header:SetAttribute('minWidth', wrap * 35)
	header:SetAttribute('wrapAfter', wrap)

	header:SetSize(30, 30)
end

FurbishPlayerBuffs:SetPoint('TOPRIGHT', UIParent, -158, -13)
FurbishPlayerBuffs:SetAttribute('filter', 'HELPFUL')
FurbishPlayerBuffs:Show()

FurbishPlayerDebuffs:SetPoint('TOP', FurbishPlayerBuffs, 'BOTTOM', 0, -35)
FurbishPlayerDebuffs:SetAttribute('filter', 'HARMFUL')
FurbishPlayerDebuffs:Show()

do
	for _, frame in ipairs{
		TemporaryEnchantFrame,
		BuffFrame,
		ConsolidatedBuffs,
	} do
		frame.Show = frame.Hide
		frame:UnregisterAllEvents()
		frame:Hide()
	end
end
