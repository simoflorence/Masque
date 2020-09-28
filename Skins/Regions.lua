--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Skins\Regions.lua
	* Author.: StormFX

	Regions Settings

]]

local _, Core = ...

----------------------------------------
-- Region Settings

-- * Key - The string button key that holds the region reference.
-- * Func - The string name of the button method that returns the region reference.
-- * Name - The string suffix of the global key that holds the region reference.
-- * Type - Must match the game's internal type, for validation.

-- * UseColor - Use :SetColorTexture() if the skin provides a color but no texture.
-- * Hide - Region will be hidden if it exists.
-- * CanHide - Allow the region to be hidden.
-- * CanMask - Allow the region to be masked.
-- * NoColor - Do not allow color changes.
-- * NoTexture - Do not allow texture changes.

-- * Ignore - Ignore when looking for regions. @ Core\Group
-- * Iterate - Include in iteration. @ Core\Button
---

local Legacy = {
	-- BACKGROUND -1
	Backdrop = {
		Name = "FloatingBG",
		Type = "Texture",
		CanHide = true,
		CanMask = true,
		UseColor = true,
	},
	-- BACKGROUND 0
	Icon = {
		Key = "icon",
		Name = "Icon",
		Type = "Texture",
		CanMask = true,
		NoColor = true,
		NoTexture = true,
		Aura = {
			Key = "Icon",
			Name = "Icon",
			Type = "Texture",
			CanMask = true,
			NoColor = true,
			NoTexture = true,
		},
		Item = {
			Key = "icon",
			Name = "IconTexture",
			Type = "Texture",
			CanMask = true,
			NoColor = true,
			NoTexture = true,
		},
	},
	-- ARTWORK -1
	Shadow = {
		Ignore = true,
		CanHide = true,
	},
	-- ARTWORK 0
	Normal = {
		--Key = "NormalTexture", -- Conflicts with some add-ons.
		Func = "GetNormalTexture",
		Name = "NormalTexture",
		Type = "Texture",
		CanHide = true,
		Pet = {
			--Key = "NormalTexture",
			Func = "GetNormalTexture",
			Name = "NormalTexture2",
			Type = "Texture",
			CanHide = true,
		},
	},
	Disabled = {
		Func = "GetDisabledTexture",
		Type = "Texture",
		Iterate = true,
		Hide = true,
	},
	Pushed = {
		Func = "GetPushedTexture",
		Type = "Texture",
		CanMask = true,
		Iterate = true,
		UseColor = true,
	},
	-- ARTWORK 1
	Flash = {
		-- Key = "Flash", -- Conflics with item buttons.
		Name = "Flash",
		Type = "Texture",
		CanMask = true,
		Iterate = true,
		UseColor = true,
	},
	-- ARTWORK
	HotKey = {
		Key = "HotKey",
		Name = "HotKey",
		Type = "FontString",
		Iterate = true,
		NoColor = true,
	},
	Count = {
		Key = "Count",
		Name = "Count",
		Type = "FontString",
		Iterate = true,
		NoColor = true,
		Aura = {
			Key = "count",
			Name = "Count",
			Type = "FontString",
			Iterate = true,
			NoColor = true,
		},
		Item = {
			Key = "count",
			Name = "Count",
			Type = "FontString",
			Iterate = true,
			NoColor = true,
		},
	},
	Duration = {
		Key = "duration",
		Name = "Duration",
		Type = "FontString",
		Iterate = true,
		NoColor = true,
	},
	-- OVERLAY 0
	Checked = {
		Func = "GetCheckedTexture",
		Type = "Texture",
		Iterate = true,
	},
	Border = {
		Key = "Border",
		Name = "Border",
		Type = "Texture",
		Iterate = true,
		NoColor = true,
		Aura = {
			Name = "Border",
			Type = "Texture",
			Iterate = true,
			NoColor = true,
		},
		Enchant = {
			Key = "Border",
			Name = "Border",
			Type = "Texture",
			Iterate = true,
		},
	},
	IconBorder = {
		Key = "IconBorder",
		Type = "Texture",
		NoColor = true,
	},
	SlotHighlight = {
		Key = "SlotHighlightTexture",
		Type = "Texture",
		Iterate = true,
	},
	Gloss = {
		Ignore = true,
		CanHide = true,
	},
	-- OVERLAY 1
	AutoCastable = { -- Only used by Pet buttons.
		--Key = "AutoCastable", -- Causes issues with Pet bars.
		Name = "AutoCastable",
		Type = "Texture",
		Iterate = true,
	},
	NewAction = {
		Key = "NewActionTexture",
		Type = "Texture",
		Iterate = true,
	},
	SpellHighlight = {
		Key = "SpellHighlightTexture",
		Type = "Texture",
		Iterate = true,
	},
	IconOverlay = {
		Key = "IconOverlay",
		Type = "Texture",
		Iterate = true,
		NoColor = true,
		NoTexture = true,
	},
	-- OVERLAY 2
	NewItem = {
		Key = "NewItemTexture",
		Type = "Texture",
		NoColor = true,
	},
	-- OVERLAY 4
	SearchOverlay = {
		Key = "searchOverlay",
		Name = "SearchOverlay",
		Type = "Texture",
		CanMask = true,
		Iterate = true,
		UseColor = true,
	},
	-- OVERLAY
	Name = {
		Key = "Name",
		Name = "Name",
		Type = "FontString",
		Iterate = true,
		NoColor = true,
	},
	-- HIGHLIGHT 0
	Highlight = {
		Func = "GetHighlightTexture",
		Type = "Texture",
		CanMask = true,
		Iterate = true,
		UseColor = true,
	},
	-- FRAME
	AutoCastShine = { -- Only used by Pet buttons.
		--Key = "AutoCastShine", -- Causes issues with Pet bars.
		Name = "Shine",
		Type = "Frame",
	},
	Cooldown = {
		Key = "cooldown",
		Name = "Cooldown",
		Type = "Cooldown",
	},
	ChargeCooldown = {
		Key = "chargeCooldown",
		Type = "Cooldown",
	},
}

----------------------------------------
-- Retail Only
---

if Core.WOW_RETAIL then
	-- OVERLAY 4
	Legacy.ContextOverlay = {
		Key = "ItemContextOverlay",
		Type = "Texture",
		CanMask = true,
		Iterate = true,
		UseColor = true,
	}
end

----------------------------------------
-- "Action" Type
---

local Action = {
	Backdrop = Legacy.Backdrop,
	Icon = Legacy.Icon,
	Normal = Legacy.Normal,
	Disabled = Legacy.Disabled, -- Unused
	Pushed = Legacy.Pushed,
	Flash = Legacy.Flash,
	HotKey = Legacy.HotKey,
	Count = Legacy.Count,
	Checked = Legacy.Checked,
	Border = Legacy.Border,
	AutoCastable = Legacy.AutoCastable,
	NewAction = Legacy.NewAction,
	SpellHighlight = Legacy.SpellHighlight,
	Name = Legacy.Name,
	Highlight = Legacy.Highlight,
	AutoCastShine = Legacy.AutoCastShine,
	Cooldown = Legacy.Cooldown,
	ChargeCooldown = Legacy.ChargeCooldown,
}

----------------------------------------
-- "Pet" Type
---

local Pet = {
	Backdrop = Legacy.Backdrop,
	Icon = Legacy.Icon,
	Normal = Legacy.Normal.Pet,
	Disabled = Legacy.Disabled, -- Unused
	Pushed = Legacy.Pushed,
	Flash = Legacy.Flash,
	HotKey = Legacy.HotKey,
	Count = Legacy.Count,
	Checked = Legacy.Checked,
	Border = Legacy.Border,
	AutoCastable = Legacy.AutoCastable,
	NewAction = Legacy.NewAction,
	SpellHighlight = Legacy.SpellHighlight,
	Name = Legacy.Name,
	Highlight = Legacy.Highlight,
	AutoCastShine = Legacy.AutoCastShine,
	Cooldown = Legacy.Cooldown,
	ChargeCooldown = Legacy.ChargeCooldown,
}

----------------------------------------
-- "Item" Type
---

local Item = {
	Icon = Legacy.Icon,
	Normal = Legacy.Normal,
	Disabled = Legacy.Disabled,
	Pushed = Legacy.Pushed,
	IconBorder = Legacy.IconBorder,
	Border = Legacy.Border, -- Backwards-Compatibility
	SlotHighlight = Legacy.SlotHighlight,
	IconOverlay = Legacy.IconOverlay,
	-- JunkIcon = Legacy.JunkIcon,
	-- UpgradeIcon = Legacy.UpgradeIcon,
	-- QuestIcon = Legacy.QuestIcon,
	NewItem = Legacy.NewItem,
	SearchOverlay = Legacy.SearchOverlay,
	ContextOverlay = Legacy.ContextOverlay,
	Count = Legacy.Count,
	Highlight = Legacy.Highlight,
	Cooldown = Legacy.Cooldown,
	ChargeCooldown = Legacy.ChargeCooldown,
}

----------------------------------------
-- "Aura" Type
---

local Aura = {
	Icon = Legacy.Icon.Aura,
	Normal = Legacy.Normal, -- Unused
	Disabled = Legacy.Disabled, -- Unused
	Pushed = Legacy.Pushed, -- Unused
	Border = Legacy.Border.Aura,
	Count = Legacy.Count.Aura,
	Duration = Legacy.Duration,
	Highlight = Legacy.Highlight, -- Unused
	Cooldown = Legacy.Cooldown,
	ChargeCooldown = Legacy.ChargeCooldown,
}

----------------------------------------
-- "Debuff" Type
---

local Debuff = {
	Icon = Legacy.Icon.Aura,
	Normal = Legacy.Normal, -- Unused
	Disabled = Legacy.Disabled, -- Unused
	Pushed = Legacy.Pushed, -- Unused
	Border = Legacy.Border,
	Count = Legacy.Count.Aura,
	Duration = Legacy.Duration,
	Highlight = Legacy.Highlight, -- Unused
	Cooldown = Legacy.Cooldown,
	ChargeCooldown = Legacy.ChargeCooldown,
}

----------------------------------------
-- "Enchant" Type
---

local Enchant = {
	Icon = Legacy.Icon.Aura,
	Normal = Legacy.Normal, -- Unused
	Disabled = Legacy.Disabled, -- Unused
	Pushed = Legacy.Pushed, -- Unused
	Border = Legacy.Border.Enchant,
	Count = Legacy.Count.Aura,
	Duration = Legacy.Duration,
	Highlight = Legacy.Highlight, -- Unused
	Cooldown = Legacy.Cooldown,
	ChargeCooldown = Legacy.ChargeCooldown,
}

----------------------------------------
-- Types Table
---

local Types = {
	Legacy = Legacy,
	Action = Action,
	Pet = Pet,
	Item = Item,
	Aura = Aura,
	Buff = Aura,
	Debuff = Debuff,
	Enchant = Enchant,
}

----------------------------------------
-- Core
---

Core.RegTypes = Types

----------------------------------------
-- API
---

-- Adds a custom button type.
function Core.API:AddType(Type, List)
	if type(Type) ~= "string" or Types[Type] then
		if Core.Debug then
			error("Bad argument to API method 'AddType'. 'Type' must be a unique string.", 2)
		end
		return
	elseif type(List) ~= "table" or #List < 1 then
		if Core.Debug then
			error("Bad argument to API method 'AddType'. 'List' must be an indexed table.", 2)
		end
		return
	end

	local Cache = {}

	for i = 1, #List do
		local Key = List[i]
		Cache[Key] = Legacy[Key]
	end

	Types[Type] = Cache
end
