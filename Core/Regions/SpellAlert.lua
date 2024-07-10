--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Core\Regions\SpellAlert.lua
	* Author.: StormFX

	'SpellAlert' Region

]]

local _, Core = ...

----------------------------------------
-- Lua API
---

local error, ipairs, type = error, ipairs, type

----------------------------------------
-- WoW API
---

local ActionButton_HideOverlayGlow = ActionButton_HideOverlayGlow

----------------------------------------
-- Internal
---

-- @ Core\Utility
local GetColor, GetScale, GetSize = Core.GetColor, Core.GetScale, Core.GetSize

----------------------------------------
-- Locals
---

-- Classic Spell Alerts
local Overlays = {
	Circle = {
		Glow = [[Interface\AddOns\Masque\Textures\Circle\SpellAlert-Glow]],
		Ants = [[Interface\AddOns\Masque\Textures\Circle\SpellAlert-Ants]],
	},
	Square = {
		Glow = [[Interface\SpellActivationOverlay\IconAlert]],
		Ants = [[Interface\SpellActivationOverlay\IconAlertAnts]],
	},
}

-- Modern Spell Alerts
local DEFAULT_COLOR = {1, 0.9, 0.5}
local DEFAULT_SIZE = 64

local FlipBooks = {
	["Circle"] = {
		LoopTexture = [[Interface\AddOns\Masque\Textures\Circle\SpellAlert-Loop]],
		Color = DEFAULT_COLOR,
		FrameHeight = DEFAULT_SIZE,
		FrameWidth = DEFAULT_SIZE,
	},
	["Hexagon"] = {
		LoopTexture = [[Interface\AddOns\Masque\Textures\Hexagon\SpellAlert-Loop]],
		Color = DEFAULT_COLOR,
		FrameHeight = DEFAULT_SIZE,
		FrameWidth = DEFAULT_SIZE,
	},
	["Hexagon-Rotated"] = {
		LoopTexture = [[Interface\AddOns\Masque\Textures\Hexagon-Rotated\SpellAlert-Loop]],
		Color = DEFAULT_COLOR,
		FrameHeight = DEFAULT_SIZE,
		FrameWidth = DEFAULT_SIZE,
	},
	["Modern"] = {
		LoopTexture = [[Interface\AddOns\Masque\Textures\Modern\SpellAlert-Loop]],
		Color = DEFAULT_COLOR,
		FrameHeight = DEFAULT_SIZE,
		FrameWidth = DEFAULT_SIZE,
	},
	["Square"] = {
		LoopTexture = [[Interface\AddOns\Masque\Textures\Square\SpellAlert-Loop]],
		Color = DEFAULT_COLOR,
		FrameHeight = DEFAULT_SIZE,
		FrameWidth = DEFAULT_SIZE,
	},
}

----------------------------------------
-- Utility
---

-- Returns the FlipBook animation from an animation group and sets the parent key.
local function GetFlipBook(...)
	local Animations = {...}

	for _, Animation in ipairs(Animations) do
		if Animation:GetObjectType() == "FlipBook" then
			Animation:SetParentKey("FlipAnim")
			return Animation
		end
	end
end

-- Applies style settings to a FlipBook animation.
local function UpdateFlipBook(Animation, Style)
	-- Custom
	if Style then
		Animation:SetFlipBookFrameHeight(Style.FrameHeight or 0)
		Animation:SetFlipBookFrameWidth(Style.FrameWidth or 0)
		Animation:SetFlipBookFrames(Style.Frames or 30)
		Animation:SetFlipBookRows(Style.Rows or 6)
		Animation:SetFlipBookColumns(Style.Columns or 5)

	-- Default
	else
		Animation:SetFlipBookFrameHeight(0)
		Animation:SetFlipBookFrameWidth(0)
		Animation:SetFlipBookFrames(30)
		Animation:SetFlipBookRows(6)
		Animation:SetFlipBookColumns(5)
	end
end

-- Updates the Start animation.
local function UpdateStartAnimation(Region)
	local Start_Group = Region.ProcStartAnim
	local Start_Animation = Start_Group.FlipAnim or GetFlipBook(Start_Group:GetAnimations())

	-- Disable the start animation.
	if Region.__Skip_Start or Region.__Loop_Only then
		Start_Animation:SetDuration(0)
		Region.ProcStartFlipbook:Hide()

	-- Enable the start animation.
	else
		Start_Animation:SetDuration(0.7)
		Region.ProcStartFlipbook:Show()
	end
end

----------------------------------------
-- Overlay
---

-- Skins Spell Alert Overlays.
local function SkinOverlay(Region, Button, Skin)
	local Button_Shape = Button.__MSQ_Shape

	-- Update the skin if the shape has changed.
	if Region.__MSQ_Shape ~= Button_Shape then
		local Square_Paths = Overlays.Square
		local Shape_Paths = (Button_Shape and Overlays[Button_Shape]) or Square_Paths

		local Ants_Texture = (Skin and Skin.Ants) or Shape_Paths.Ants or Square_Paths.Ants
		local Glow_Texture = (Skin and Skin.Glow) or Shape_Paths.Glow or Square_Paths.Glow

		Region.ants:SetTexture(Ants_Texture)
		Region.innerGlow:SetTexture(Glow_Texture)
		Region.innerGlowOver:SetTexture(Glow_Texture)
		Region.outerGlow:SetTexture(Glow_Texture)
		Region.outerGlowOver:SetTexture(Glow_Texture)
		Region.spark:SetTexture(Glow_Texture)

		Region.__MSQ_Shape = Button_Shape
	end
end

----------------------------------------
-- FlipBook
---

-- Skins Spell Alert FlipBooks.
local function SkinFlipBook(Region, Button, Skin, xScale, yScale)
	-- Start Animation
	local Start_Group = Region.ProcStartAnim
	local Start_Animation = Start_Group.FlipAnim or GetFlipBook(Start_Group:GetAnimations())
	local Start_Flipbook = Region.ProcStartFlipbook

	-- Loop Animation
	local Loop_Group = Region.ProcLoop
	local Loop_Animation = Loop_Group.FlipAnim or GetFlipBook(Loop_Group:GetAnimations())
	local Loop_Flipbook = Region.ProcLoopFlipbook

	if Skin then
		-- [ Alert Frame ]

		-- Get the skin size relative to scaling.
		local Skin_Width, Skin_Height = GetSize(Skin.Width, Skin.Height, xScale, yScale, Button)

		-- Set the frame size relative to the button.
		Skin_Width = Skin_Width * 1.4
		Skin_Height = Skin_Height * 1.4

		Region:SetSize(Skin_Width, Skin_Height)

		-- [ Animations ]

		local Button_Shape = Button.__MSQ_Shape
		local FlipBook_Style = Button_Shape and FlipBooks[Button_Shape]

		if FlipBook_Style then
			local Loop_Texture = FlipBook_Style.LoopTexture

			-- [ Start Animation ]

			local Start_Texture = FlipBook_Style.StartTexture

			if not Start_Texture then
				Start_Texture = Loop_Texture
				Region.__Loop_Only = true
			else
				Region.__Loop_Only = nil
			end

			Start_Flipbook:SetTexture(Start_Texture)
			Start_Flipbook:SetVertexColor(GetColor(FlipBook_Style.Color))

			Start_Flipbook:ClearAllPoints()
			Start_Flipbook:SetAllPoints()

			UpdateFlipBook(Start_Animation, FlipBook_Style)
			UpdateStartAnimation(Region)

			-- [ Loop Animation ]

			Loop_Flipbook:SetTexture(Loop_Texture)
			Loop_Flipbook:SetVertexColor(GetColor(FlipBook_Style.Color))

			UpdateFlipBook(Loop_Animation, FlipBook_Style)

		-- Default
		else
			Region.__Loop_Only = nil

			-- [ Start Animation ]

			Start_Flipbook:SetAtlas("UI-HUD-ActionBar-Proc-Start-Flipbook")
			Start_Flipbook:SetVertexColor(1, 1, 1)

			Start_Flipbook:ClearAllPoints()
			Start_Flipbook:SetPoint("CENTER")

			-- Texture size relative to the button size.
			local Scale_Width, Scale_Height = Button:GetSize()
			local Width = 160 * (Skin_Width / (Scale_Width * 1.4))
			local Height = 160 * (Skin_Height / (Scale_Height * 1.4))

			Start_Flipbook:SetSize(Width, Height)

			UpdateFlipBook(Start_Animation)
			UpdateStartAnimation(Region)

			-- [ Loop Animation ]

			Loop_Flipbook:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
			Loop_Flipbook:SetVertexColor(1, 1, 1)

			UpdateFlipBook(Loop_Animation)
		end

	-- Default
	else
		Region.__Loop_Only = nil

		-- [ Alert Frame ]

		local Width, Height = Button:GetSize()

		Region:SetSize(Width * 1.4, Height * 1.4)

		-- [ Start Animation ]

		Start_Flipbook:SetAtlas("UI-HUD-ActionBar-Proc-Start-Flipbook")
		Start_Flipbook:SetVertexColor(1, 1, 1)

		Start_Flipbook:ClearAllPoints()
		Start_Flipbook:SetPoint("CENTER")

		-- Defaults to 150 x 150, causing visual scaling-up on transition.
		Start_Flipbook:SetSize(160, 160)

		UpdateFlipBook(Start_Animation)
		UpdateStartAnimation(Region)

		-- [ Loop Animation ]

		Loop_Flipbook:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
		Loop_Flipbook:SetVertexColor(1, 1, 1)

		UpdateFlipBook(Loop_Animation)
	end

	Region.__MSQ_Skin = Skin or true
	Region.__MSQ_Scale = Button.__MSQ_Scale
end

----------------------------------------
-- Update/Hook
---

-- Hook to update Spell Alerts.
local function UpdateSpellAlert(Button)
	local Region = Button.SpellActivationAlert or Button.overlay

	if not Region then return end

	local Button_Skin = Button.__MSQ_Skin
	local Region_Skin = Button_Skin and Button_Skin.SpellAlert

	-- Modern Spell Alerts
	if Region.ProcStartAnim then
		-- Get the Spell Alert animation setting.
		local Alert_Setting = Core.db.profile.Effects.SpellAlert

		-- Skips the Start animation. Must be set before the skin is applied.
		Region.__Skip_Start = (Alert_Setting == 2 and true) or nil

		local Active_Skin = Region.__MSQ_Skin

		-- Update the skin if the skin or scale has changed.
		if (not Active_Skin) or (Active_Skin ~= Region_Skin) or (Region.__MSQ_Scale ~= Button.__MSQ_Scale) then
			SkinFlipBook(Region, Button, Region_Skin, GetScale(Button))

		-- Update the Start animation.
		else
			UpdateStartAnimation(Region)
		end

		-- Prevent the Loop texture from being visible during the Start animation.
		Region.ProcLoopFlipbook:SetAlpha(0)

		-- Disables Spell Alerts completely. Must be set after the skin is applied.
		if Alert_Setting == 0 then
			ActionButton_HideOverlayGlow(Button)
			return
		end

	-- Classic Spell Alerts
	elseif Region.spark then
		SkinOverlay(Region, Button, Region_Skin)
	end
end

-- @ FrameXML\ActionButton.lua
hooksecurefunc("ActionButton_ShowOverlayGlow", UpdateSpellAlert)

----------------------------------------
-- Core
---

Core.UpdateSpellAlert = UpdateSpellAlert

----------------------------------------
-- API
---

local API = Core.API

-- API wrapper for the UpdateSpellAlert function.
function API:UpdateSpellAlert(Button)
	if type(Button) ~= "table" then
		return
	end

	UpdateSpellAlert(Button)
end

----------------------------------------
-- Overlays
---

-- Adds an overlay texture set.
function API:AddSpellAlert(Shape, Glow, Ants)
	if type(Shape) ~= "string" or Overlays[Shape] then
		if Core.Debug then
			error("Bad argument to API method 'AddSpellAlert'. 'Shape' must be a unique string.", 2)
		end
		return
	elseif Glow and type(Glow) ~= "string" then
		if Core.Debug then
			error("Bad argument to API method 'AddSpellAlert'. 'Glow' must be a string.", 2)
		end
		return
	elseif Ants and type(Ants) ~= "string" then
		if Core.Debug then
			error("Bad argument to API method 'AddSpellAlert'. 'Ants' must be a string.", 2)
		end
		return
	end

	local Shape_Paths = {}

	Shape_Paths.Glow = Glow
	Shape_Paths.Ants = Ants

	Overlays[Shape] = Shape_Paths
end

-- Returns an overlay texture set.
function API:GetSpellAlert(Shape)
	if type(Shape) ~= "string" then
		if Core.Debug then
			error("Bad argument to API method 'GetSpellAlert'. 'Shape' must be a string.", 2)
		end
		return
	end

	local Shape_Paths = Overlays[Shape]

	if Shape_Paths then
		return Shape_Paths.Glow, Shape_Paths.Ants
	end
end

----------------------------------------
-- FlipBooks
---

-- Adds a custom FlipBook style.
function API:AddSpellAlertFlipBook(Shape, Data)
	if type(Shape) ~= "string" or FlipBooks[Shape] then
		if Core.Debug then
			error("Bad argument to API method 'AddSpellAlertFlipBook'. 'Shape' must be a unique string.", 2)
		end
		return
	elseif type(Data) ~= "table" then
		if Core.Debug then
			error("Bad argument to API method 'AddSpellAlertFlipBook'. 'Data' must be a table.", 2)
		end
		return
	end

	FlipBooks[Shape] = Data
end

-- Returns a FlipBook style table.
function API:GetSpellAlertFlipBook(Shape)
	if type(Shape) ~= "string" then
		if Core.Debug then
			error("Bad argument to API method 'GetSpellAlertFlipBook'. 'Shape' must be a string.", 2)
		end
		return
	end

	return FlipBooks[Shape]
end
