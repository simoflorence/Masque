--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For license information,
	please see the included License.txt file.

	* File...: Skins\Skins.lua
	* Author.: StormFX

	Skin API

]]

local _, Core = ...

----------------------------------------
-- Lua
---

local error, setmetatable, type = error, setmetatable, type

----------------------------------------
-- Locals
---

local C_API = Core.API

----------------------------------------
-- Skins
---

-- Skin Data
local Skins = {}

----------------------------------------
-- Core
---

do
	-- Skin List
	local SkinList = {}

	-- Layers
	local Layers = {
		"Backdrop",
		"Icon",
		"Flash",
		"Pushed",
		--"Shadow",
		"Normal",
		"Disabled",
		"Checked",
		"Border",
		"IconBorder",
		"IconOverlay",
		"Gloss",
		"AutoCastable",
		"Highlight",
		"Name",
		"Count",
		"HotKey",
		"Duration",
		"Cooldown",
		"ChargeCooldown",
		"Shine",
	}

	-- Hidden
	local Hidden = {
		Hide = true,
	}

	-- Adds data to the skin tables.
	function Core:AddSkin(SkinID, SkinData, Default)
		-- Layer Validation
		for i = 1, #Layers do
			local Layer = Layers[i]
			if type(SkinData[Layer]) ~= "table" then
				if Layer == "Shine" and type(SkinData.AutoCast) == "table" then
					SkinData[Layer] = SkinData.AutoCast
				else
					SkinData[Layer] = Hidden
				end
			end
		end

		-- Skin Addition
		SkinData.SkinID = SkinID
		Skins[SkinID] = SkinData
		SkinList[SkinID] = SkinID

		-- Default Skin
		if Default then
			self.DEFAULT_SKIN = SkinID
		end
	end

	Core.Skins = setmetatable(Skins, {
		__index = function(self, s)
			if s == "Blizzard" then
				return self.Classic
			end
		end
	})
	Core.SkinList = SkinList
end

----------------------------------------
-- API
---

-- Wrapper for the AddSkin function.
function C_API:AddSkin(SkinID, SkinData, Replace)
	local Debug = Core.Debug

	-- Validation
	if type(SkinID) ~= "string" then
		if Debug then
			error("Bad argument to API method 'AddSkin'. 'SkinID' must be a string.", 2)
		end
		return
	end
	if Skins[SkinID] and not Replace then
		return
	end
	if type(SkinData) ~= "table" then
		if Debug then
			error("Bad argument to API method 'AddSkin'. 'SkinData' must be a table.", 2)
		end
		return
	end

	-- Template Vaidation
	local Template = SkinData.Template
	if Template then
		if type(Template) ~= "string" then
			if Debug then
				error(("Invalid template reference by skin '%s'. 'Template' must be a string."):format(SkinID), 2)
			end
			return
		end
		local Parent = Skins[Template]
		if type(Parent) ~= "table"  then
			if Debug then
				error(("Invalid template reference by skin '%s'. Template '%s' does not exist or is not a table."):format(SkinID, Template), 2)
			end
			return
		end

		-- Automatically group skins with their template.
		local Group = Parent.Group or Template
		Parent.Group = Group

		setmetatable(SkinData, {__index = Parent})
	end

	Core:AddSkin(SkinID, SkinData)
end

-- API method for returning the default skin.
function C_API:GetDefaultSkin()
	return Core.DEFAULT_SKIN
end

-- API method returning a specific skin.
function C_API:GetSkin(SkinID)
	return SkinID and Skins[SkinID]
end

-- API method for returning the skins table.
function C_API:GetSkins()
	return Skins
end
