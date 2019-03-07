--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For license information,
	please see the included License.txt file.

	* File...: Skins\Zoomed.lua
	* Author.: StormFX, JJSheets

	'Zoomed' Skin

]]

local _, Core = ...

do
	local L = Core.Locale

	-- Skin
	Core:AddSkin("Zoomed", {
		Shape = "Square",
		Masque_Version = 80100,

		-- Info
		Description = L["A square skin with zoomed icons and a semi-transparent background."],
		Version = Core.Version,
		Authors = Core.Authors,
		Websites = Core.Websites,

		-- Data
		Backdrop = {
			Width = 36,
			Height = 36,
			Color = {0, 0, 0, 0.5},
			Texture = [[Interface\Tooltips\UI-Tooltip-Background]],
		},
		Icon = {
			Width = 36,
			Height = 36,
			TexCoords = {0.07,0.93,0.07,0.93},
		},
		Flash = {
			Width = 36,
			Height = 36,
			Texture = [[Interface\Buttons\UI-QuickslotRed]],
		},
		Pushed = {
			Width = 36,
			Height = 36,
			Texture = [[Interface\Buttons\UI-Quickslot-Depress]],
		},
		-- Shadow = {Hide = true},
		-- Normal = {Hide = true},
		-- Disabled = {Hide = true},
		Checked = {
			Width = 38,
			Height = 38,
			BlendMode = "ADD",
			Texture = [[Interface\Buttons\CheckButtonHilight]],
		},
		Border = {
			Width = 66,
			Height = 66,
			OffsetX = 0.5,
			OffsetY = 0.5,
			BlendMode = "ADD",
			Texture = [[Interface\Buttons\UI-ActionButton-Border]],
		},
		IconBorder = {
			Width = 37,
			Height = 37,
		},
		IconOverlay = {
			Width = 37,
			Height = 37,
		},
		-- Gloss = {Hide = true},
		AutoCastable = {
			Width = 66,
			Height = 66,
			OffsetX = 0.5,
			OffsetY = -0.5,
			Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
		},
		Highlight = {
			Width = 36,
			Height = 36,
			BlendMode = "ADD",
			Texture = [[Interface\Buttons\ButtonHilight-Square]],
		},
		Name = {
			Width = 36,
			Height = 10,
			OffsetY = 3,
		},
		Count = {
			Width = 36,
			Height = 10,
			OffsetX = -2,
			OffsetY = 4,
		},
		HotKey = {
			Width = 36,
			Height = 10,
			OffsetX = -2,
			OffsetY = -4,
		},
		Duration = {
			Width = 36,
			Height = 10,
			OffsetY = -3,
		},
		Cooldown = {
			Width = 36,
			Height = 36,
		},
		ChargeCooldown = {
			Width = 36,
			Height = 36,
		},
		Shine = {
			Width = 34,
			Height = 34,
			OffsetX = 0.5,
			OffsetY = -0.5
		},
	})
end
