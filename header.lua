local name, namespace = ...

for _, name in next, {
	'FurbishPlayerBuffs',
	'FurbishPlayerDebuffs',
	'FurbishPlayerConsolidate',
} do
	local header
	if(name == 'FurbishPlayerConsolidate') then
		header = CreateFrame('Frame', name, UIParent, 'SecureFrameTemplate')
	else
		header = CreateFrame('Frame', name, UIParent, 'SecureAuraHeaderTemplate')
	end
	header:SetAttribute('template', 'FurbishAuraTemplate')
	header:SetAttribute('weaponTemplate', 'FurbishAuraTemplate')
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
	header:SetAttribute('wrapYOffset', -35)

	header:SetSize(30, 30)

	-- Swap the unit to vehicle when we enter a vehicle *gasp*.
	RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')

	table.insert(namespace, header)
end

local buffs = FurbishPlayerBuffs
local debuffs = FurbishPlayerDebuffs
local consolidate = FurbishPlayerConsolidate

buffs:SetPoint('TOPRIGHT', UIParent, -358, -13)
buffs:SetAttribute('filter', 'HELPFUL')
buffs:SetAttribute('consolidateProxy', CreateFrame('Frame', buffs:GetName() .. 'ProxyButton', buffs, 'FurbishProxyTemplate'))
buffs:SetAttribute('consolidateHeader', consolidate)
buffs:SetAttribute('consolidateTo', 1)
buffs:SetAttribute('consolidateDuration', -1)
buffs:Show()

local proxy = buffs:GetAttribute'consolidateProxy'
proxy:SetAttribute('_onenter', [[
	local header = self:GetFrameRef'header'
	local background = self:GetFrameRef'background'

	local numChild = 0
	repeat
		numChild = numChild + 1
		local child = header:GetFrameRef('child' .. numChild)
	until not child or not child:IsShown()

	numChild = numChild - 1

	header:SetWidth(35 * numChild)
	header:SetHeight(30)

	background:SetWidth(header:GetWidth() + 8)
	background:SetHeight(header:GetHeight() + 8)

	header:ClearAllPoints()
	header:SetPoint('TOP', self, 'BOTTOM', 0, 4)
	header:Show()
]])

proxy:SetAttribute('_onleave', [[
	local header = self:GetFrameRef'header'
	if(not header:IsUnderMouse()) then
		header:Hide()
	else
		header:RegisterAutoHide(.3)
		local numChild = 1
		local child = header:GetFrameRef('child' .. numChild)
		while(child) do
			header:AddToAutoHide(child)
			numChild = numChild + 1
			child = header:GetFrameRef('child' .. numChild)
		end
	end
]])

consolidate:SetAttribute('point', 'RIGHT')
consolidate:SetAttribute('minHeight', nil)
consolidate:SetAttribute('minWidth', nil)
consolidate:SetParent(proxy)

local background = CreateFrame('Frame', consolidate:GetName() .. 'Background', consolidate)
background:SetPoint('CENTER', 2, 0)
background:SetBackdrop(GameTooltip:GetBackdrop())
background:SetBackdropColor(0, 0, 0)
background:SetBackdropBorderColor(.3, .3, .3)
background:Show()

SecureHandlerSetFrameRef(proxy, 'background', background)
SecureHandlerSetFrameRef(proxy, 'header', consolidate)

debuffs:SetPoint('TOP', buffs, 'BOTTOM', 0, -35)
debuffs:SetAttribute('filter', 'HARMFUL')
debuffs:Show()

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
