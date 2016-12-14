local classcolours = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

local class = select(2, UnitClass("player"))
local r, g, b = classcolours[class].r, classcolours[class].g, classcolours[class].b

local ot = ObjectiveTrackerFrame
local BlocksFrame = ot.BlocksFrame

--  [[ API ]]

local StripesThin = "Interface\\Addons\\!ObjectiveTracker\\Media\\StripesThin"
local Texture = "Interface\\Addons\\!ObjectiveTracker\\Media\\Statusbar"
local glowTex = "Interface\\Addons\\!ObjectiveTracker\\Media\\glowTex"
local gloss = "Interface\\Addons\\!ObjectiveTracker\\Media\\gloss"

local CreateBD = function(f, a)
	f:SetBackdrop({
		bgFile = [[Interface\ChatFrame\ChatFrameBackground.blp]], 
		edgeFile = [[Interface\AddOns\!ObjectiveTracker\Media\glowTex.tga]], 
		edgeSize = 1,
	})
	f:SetBackdropColor(.06, .06, .06, a or .8)
	f:SetBackdropBorderColor(0, 0, 0)

	if not a then
		f.tex = f.tex or f:CreateTexture(nil, "BACKGROUND", nil, 1)
		f.tex:SetTexture([[Interface\AddOns\!ObjectiveTracker\Media\StripesThin]], true, true)
		f.tex:SetAlpha(.45)
		f.tex:SetAllPoints()
		f.tex:SetHorizTile(true)
		f.tex:SetVertTile(true)
		f.tex:SetBlendMode("ADD")
	else
		f:SetBackdropColor(0, 0, 0, .8)
	end
end

local CreateBG = function(frame)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
	bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
	bg:SetVertexColor(0, 0, 0)

	return bg
end

local CreateSD = function(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = 4
	sd.offset = offset or -1
	sd:SetBackdrop({
		edgeFile = [[Interface\AddOns\!ObjectiveTracker\Media\glowTex]], 
		edgeSize = 4,
	})
	sd:SetPoint("TOPLEFT", -3, 3)
	sd:SetPoint("BOTTOMRIGHT", 3, -3)
	sd:SetBackdropBorderColor(.03, .03, .03)
	sd:SetAlpha(alpha or .6)
end


local CreateSDD = function(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = 5
	sd.offset = offset or -5
	sd:SetBackdrop({
		edgeFile = [[Interface\AddOns\!ObjectiveTracker\Media\glowTex.tga]], 
		edgeSize = 4,
	})
	sd:SetPoint("TOPLEFT", -4, 4)
	sd:SetPoint("BOTTOMRIGHT", 4, -4)
	sd:SetBackdropBorderColor(0, 0, 0)
	sd:SetAlpha(alpha or 1)
end

local CreateBDFrame = function(f, a)
	local frame
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	CreateBD(bg, a or .5)

	return bg
end

local ReskinIcon = function(icon)
	icon:SetTexCoord(.08, .92, .08, .92)
	return CreateBG(icon)
end



-- [[ Difficulty color for ObjectiveTrackerFrame lines ]]

hooksecurefunc(QUEST_TRACKER_MODULE, "Update", function()
	for i = 1, GetNumQuestWatches() do
		local questID, _, questIndex = GetQuestWatchInfo(i)
		if not questID then
			break
		end
		local _, level = GetQuestLogTitle(questIndex)
		local col = GetQuestDifficultyColor(level)
		local block = QUEST_TRACKER_MODULE:GetExistingBlock(questID)
		if block then
			block.HeaderText:SetTextColor(col.r, col.g, col.b)
			block.HeaderText.col = col
		end
	end
end)

hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block)
	if block.module == ACHIEVEMENT_TRACKER_MODULE then
		block.HeaderText:SetTextColor(0.75, 0.61, 0)
		block.HeaderText.col = nil
	end
end)

hooksecurefunc("ObjectiveTrackerBlockHeader_OnLeave", function(self)
	local block = self:GetParent()
	if block.HeaderText.col then
		block.HeaderText:SetTextColor(block.HeaderText.col.r, block.HeaderText.col.g, block.HeaderText.col.b)
	end
end)


-- [[ Header ]]

-- Header

ot.HeaderMenu.Title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

	-- [[  Blocks and lines  ]]

for _, headerName in pairs({"QuestHeader", "AchievementHeader", "ScenarioHeader"}) do
	local header = BlocksFrame[headerName]
	
	header.Text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")  --任务栏标题文字
end

do
	local header = BONUS_OBJECTIVE_TRACKER_MODULE.Header
	
	header.Text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")  --世界任务标题文字
end
	
for _, headerName in next, {"QuestHeader", "AchievementHeader", "ScenarioHeader"} do  --任务 标题背景 美化
	local header = _G.ObjectiveTrackerFrame.BlocksFrame[headerName]
	header.Background:Hide()

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture([[Interface\LFGFrame\UI-LFG-SEPARATOR]])
	bg:SetTexCoord(0, 0.6640625, 0, 0.3125)
	bg:SetVertexColor(r * 0.7, g * 0.7, b * 0.7)
	bg:SetPoint("BOTTOMLEFT", -30, -4)
	bg:SetSize(210, 30)
end

ScenarioStageBlock:HookScript("OnShow", function()
	if not ScenarioStageBlock.skinned then
		ScenarioStageBlock.NormalBG:SetAlpha(.6)
	--	ScenarioStageBlock.NormalBG:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
	--	ScenarioStageBlock.NormalBG:SetVertexColor(0, 0, 0, 1)
		ScenarioStageBlock.FinalBG:SetAlpha(.6)
		ScenarioStageBlock.GlowTexture:SetTexture(nil)
		ScenarioStageBlock.Stage:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
		ScenarioStageBlock.Stage:SetTextColor(1, 1, 1)
		ScenarioStageBlock.Name:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		ScenarioStageBlock.CompleteLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
		ScenarioStageBlock.CompleteLabel:SetTextColor(1, 1, 1)
		ScenarioStageBlock.skinned = true
	end
end)

do  --世界任务 标题背景 美化
	local header = WORLD_QUEST_TRACKER_MODULE.Header
	header.Background:Hide()
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture([[Interface\LFGFrame\UI-LFG-SEPARATOR]])
	bg:SetTexCoord(0, 0.6640625, 0, 0.3125)
	bg:SetVertexColor(r * 0.7, g * 0.7, b * 0.7)
	bg:SetPoint("BOTTOMLEFT", -30, -4)
	bg:SetSize(210, 30)
	header.Text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

	local header_bonus = BONUS_OBJECTIVE_TRACKER_MODULE.Header
	header_bonus.Background:Hide()
	local bg = header_bonus:CreateTexture(nil, "ARTWORK")
	bg:SetTexture([[Interface\LFGFrame\UI-LFG-SEPARATOR]])
	bg:SetTexCoord(0, 0.6640625, 0, 0.3125)
	bg:SetVertexColor(170 * 0.7, 211 * 0.7, 114 * 0.7)
	bg:SetPoint("BOTTOMLEFT", -30, -4)
	bg:SetSize(210, 30)
	header_bonus.Text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
end

hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "SetBlockHeader", function(_, block)
    if not block.headerStyled then
        block.HeaderText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        block.headerStyled = true
    end
end)

	  
hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
	if not block.headerStyled then
		block.HeaderText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		block.headerStyled = true
	end

	local itemButton = block.itemButton

	if itemButton and not itemButton.styled then
		itemButton:SetNormalTexture("")
		itemButton:SetPushedTexture("")

		itemButton.HotKey:ClearAllPoints()
		itemButton.HotKey:SetPoint("CENTER", itemButton, 1, 0)
		itemButton.HotKey:SetJustifyH("CENTER")
		itemButton.HotKey:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

		itemButton.Count:ClearAllPoints()
		itemButton.Count:SetPoint("TOP", itemButton, 2, -1)
		itemButton.Count:SetJustifyH("CENTER")
		itemButton.Count:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

		itemButton.icon:SetTexCoord(.08, .92, .08, .92)
		CreateBG(itemButton)
		CreateSDD(itemButton)

		itemButton.styled = true
	end
end)

hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", function(_, block)
	local itemButton = block.itemButton
	if itemButton and not itemButton.styled then
		itemButton:SetNormalTexture("")
		itemButton:SetPushedTexture("")

		itemButton.HotKey:ClearAllPoints()
		itemButton.HotKey:SetPoint("CENTER", itemButton, 1, 0)
		itemButton.HotKey:SetJustifyH("CENTER")
		itemButton.HotKey:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

		itemButton.Count:ClearAllPoints()
		itemButton.Count:SetPoint("TOP", itemButton, 2, -1)
		itemButton.Count:SetJustifyH("CENTER")
		itemButton.Count:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

		itemButton.icon:SetTexCoord(.08, .92, .08, .92)
		CreateBG(itemButton)
		CreateSDD(itemButton)

		itemButton.styled = true
	end
end)

hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block)
	if block.module == QUEST_TRACKER_MODULE or block.module == ACHIEVEMENT_TRACKER_MODULE then
		local line = block.currentLine

		local p1, a, p2, x, y = line:GetPoint()
		line:SetPoint(p1, a, p2, x, y - 4)
	end
end)

local function fixBlockHeight(block)
	if block.shouldFix then
		local height = block:GetHeight()

		if block.lines then
			for _, line in pairs(block.lines) do
				if line:IsShown() then
					height = height + 4
				end
			end
		end

		block.shouldFix = false
		block:SetHeight(height + 5)
		block.shouldFix = true
	end
end

hooksecurefunc("ObjectiveTracker_AddBlock", function(block)
	if block.lines then
		for _, line in pairs(block.lines) do
			if not line.styled then
				if GetLocale() == "zhCN" or GetLocale() == "zhTW" then
					line.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
				else
					line.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
				end
				line.Text:SetSpacing(2)

				if line.Dash then
					line.Dash:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
				end

				line:SetHeight(line.Text:GetHeight())

				line.styled = true
			end
		end
	end

	if not block.styled then
		block.shouldFix = true
		hooksecurefunc(block, "SetHeight", fixBlockHeight)
		block.styled = true
	end
end)

-- [[ Bonus objective progress bar ]]

hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", function(self, block, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar
	local icon = bar.Icon
	if not progressBar.styled then
		local bg = CreateBDFrame(bar)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 0, -2)
		CreateSD(bg)

		bar.BarBG:Hide()
		bar.BarFrame:Hide()
		bar:SetStatusBarTexture(C.media.backdrop)
		-- bar:SetStatusBarColor(237/255, 82/255, 46/255)
		bar:SetHeight(14)

		icon:SetMask(nil)
		icon:SetSize(24, 24)
		icon:SetDrawLayer("BACKGROUND", 1)
		icon:ClearAllPoints()
		icon:SetPoint("RIGHT", 30, 0)
		bar.newIconBg = ReskinIcon(icon)

		bar.Label:ClearAllPoints()
		bar.Label:SetPoint("CENTER")
		bar.Label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

		progressBar.styled = true
	end

	bar.IconBG:Hide()
	bar.newIconBg:SetShown(icon:IsShown())
end)

-- [[ World quest objective progress bar ]]

hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", function(self, block, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar
	local icon = bar.Icon
	if not progressBar.styled then
		local bg = CreateBDFrame(bar)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		CreateSD(bg)

		bar.BarBG:Hide()
		bar.BarFrame:Hide()
		bar:SetStatusBarTexture([[Interface\AddOns\!ObjectiveTracker\Media\gloss.tga]])
		bar:SetStatusBarColor(237/255, 82/255, 46/255)
		bar:SetHeight(16)

		icon:SetMask(nil)
		icon:SetSize(24, 24)
		icon:SetDrawLayer("BACKGROUND", 1)
		icon:ClearAllPoints()
		icon:SetPoint("RIGHT", 30, 0)
		bar.newIconBg = ReskinIcon(icon)

		bar.Label:ClearAllPoints()
		bar.Label:SetPoint("CENTER")
		bar.Label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

		progressBar.styled = true
	end

	bar.IconBG:Hide()
	bar.newIconBg:SetShown(icon:IsShown())
end)

-- [[ scenario progress bar ]]

hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", function(self, block, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar
	if not progressBar.styled then
		local bg = CreateBDFrame(bar)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		CreateSD(bg)

		bar.BarBG:Hide()
		bar.BarFrame:Hide()
		bar:SetStatusBarTexture([[Interface\AddOns\!ObjectiveTracker\Media\gloss.tga]])
		bar:SetStatusBarColor(237/255, 82/255, 46/255)
		bar:SetHeight(16)

		bar.Label:ClearAllPoints()
		bar.Label:SetPoint("CENTER")
		bar.Label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

		progressBar.styled = true
	end
end)
