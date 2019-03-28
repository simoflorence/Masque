--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For license information,
	please see the included License.txt file.

	* File...: Core\Groups.lua
	* Author.: StormFX, JJSheets

	Group API

]]

-- GLOBALS:

local MASQUE, Core = ...

----------------------------------------
-- Lua
---

local error, pairs, setmetatable, type = error, pairs, setmetatable, type

----------------------------------------
-- Locals
---

local C_API = Core.API
local Skins, SkinButton = Core.Skins, Core.SkinButton

-- @ Core\Utility: Size, Points, Color, Coords
local _, _, GetColor = Core.Utility()

----------------------------------------
-- Groups
---

-- Group Storage
local Groups = {}
local GMT

local GetID, GetGroup

do
	-- Creates and returns a simple ID for a group.
	function GetID(Addon, Group, StaticID)
		local ID = MASQUE
		if Addon then
			ID = Addon
			if Group then
				if StaticID then
					ID = ID.."_"..StaticID
				else
					ID = ID.."_"..Group
				end
			end
		end
		return ID
	end

	-- Creates and returns a new group.
	local function NewGroup(ID, Addon, Group, IsActionBar, StaticID)
		-- Build the group object.
		local obj = {
			ID = ID,
			Addon = Addon,
			Group = Group,
			Buttons = {},
			SubList = (not Group and {}) or nil,
			StaticID = (Group and StaticID) or nil,
			IsActionBar = IsActionBar,
		}

		setmetatable(obj, GMT)
		Groups[ID] = obj

		local Parent
		if Group then
			Parent = GetGroup(Addon)
		elseif Addon then
			Parent = GetGroup()
		end

		if Parent then
			Parent.SubList[ID] = obj
			obj.Parent = Parent
		end

		obj:Update(true)
		return obj
	end

	-- Returns an existing or new group.
	function GetGroup(Addon, Group, IsActionBar, StaticID)
		local ID = GetID(Addon, Group, StaticID)
		return Groups[ID] or NewGroup(ID, Addon, Group, IsActionBar, StaticID)
	end

	----------------------------------------
	-- Core
	---

	Core.GetGroup = GetGroup

	----------------------------------------
	-- API
	---

	-- Wrapper for the GetGroup function.
	function C_API:Group(Addon, Group, IsActionBar, StaticID)
		-- Validation
		if type(Addon) ~= "string" or Addon == MASQUE then
			if Core.Debug then
				error("Bad argument to API method 'Group'. 'Addon' must be a string.", 2)
			end
			return
		elseif Group and type(Group) ~= "string" then
			if Core.Debug then
				error("Bad argument to API method 'Group'. 'Group' must be a string.", 2)
			end
			return
		elseif StaticID and type(StaticID) ~= "string" then
			if Core.Debug then
				error("Bad argument to API method 'Group'. 'StaticID' must be a string.", 2)
			end
			return
		end

		return GetGroup(Addon, Group, IsActionBar, StaticID)
	end
end

----------------------------------------
-- Group Metatable
---

do
	GMT = {
		__index = {

			-- Adds or reassigns a button to the group.
			AddButton = function(self, Button, ButtonData)
				if type(Button) ~= "table" then
					if Core.Debug then
						error("Bad argument to group method 'AddButton'. 'Button' must be a button object.", 2)
					end
					return
				end
				local Parent = Group[Button]
				if Parent then
					if Parent == self then
						return
					else
						ButtonData = ButtonData or Parent.Buttons[Button]
						Parent.Buttons[Button] = nil
					end
				end
				Group[Button] = self
				if type(ButtonData) ~= "table" then
					ButtonData = {}
				end
				for Layer, Type in pairs(Layers) do
					if ButtonData[Layer] == nil then
						if Layer == "Shine" then
							ButtonData[Layer] = ButtonData.AutoCast or GetRegion(Button, Layer, Type)
						else
							ButtonData[Layer] = GetRegion(Button, Layer, Type)
						end
					end
				end
				self.Buttons[Button] = ButtonData

				local db = self.db
				if not db.Disabled and not self.Queued then
					SkinButton(Button, ButtonData, db.SkinID, db.Backdrop, db.Shadow, db.Gloss, db.Colors, self.IsActionBar)
				end
			end,

			-- Removes a button from the group and applies the default skin.
			RemoveButton = function(self, Button)
				if Button then
					local ButtonData = self.Buttons[Button]
					Group[Button] = nil
					if ButtonData then
						SkinButton(Button, ButtonData, "Classic")
					end
					self.Buttons[Button] = nil
				end
			end,

			-- Deletes the group and applies the default skin to its buttons.
			Delete = function(self)
				local Subs = self.SubList
				if Subs then
					for _, Sub in pairs(Subs) do
						Sub:Delete()
					end
				end

				local Buttons = self.Buttons
				for Button in pairs(Buttons) do
					Group[Button] = nil
					SkinButton(Button, Buttons[Button], "Classic")
					Buttons[Button] = nil
				end

				local Parent = self.Parent
				if Parent then
					Parent.SubList[self.ID] = nil
				end

				Core:UpdateSkinOptions(self, true)
				Groups[self.ID] = nil
			end,

			-- Reskins the group with its current settings.
			ReSkin = function(self, Silent)
				if not self.db.Disabled then
					local db = self.db
					for Button in pairs(self.Buttons) do
						SkinButton(Button, self.Buttons[Button], db.SkinID, db.Backdrop, db.Shadow, db.Gloss, db.Colors, self.IsActionBar)
					end
					if not Silent then
						if self.Callback then
							Callback(self.ID, self.Group, db.SkinID, db.Gloss, db.Backdrop, db.Colors)
						elseif self.Addon then
							Callback(self.Addon, self.Group, db.SkinID, db.Gloss, db.Backdrop, db.Colors)
						end
					end
				end
			end,

			-- Returns a button layer.
			GetLayer = function(self, Button, Layer)
				if Button and Layer then
					local ButtonData = self.Buttons[Button]
					if ButtonData then
						return ButtonData[Layer]
					end
				end
			end,

			-- Returns a layer color.
			GetColor = function(self, Layer)
				local Skin = Skins[self.db.SkinID] or Skins["Classic"]
				return GetColor(self.db.Colors[Layer] or Skin[Layer].Color)
			end,

			-- Renames the group.
			SetName = function(self, Name)
				if not self.StaticID then
					return
				elseif type(Name) ~= "string" then
					if Core.Debug then
						error("Bad argument to group method 'SetName'. 'Name' must be a string.", 2)
					end
					return
				end
				self.Group = Name
				Core:UpdateSkinOptions(self)
			end,

			-- Sets a callback for the group.
			SetCallback = function(self, func, arg)
				if self.ID == MASQUE then return end

				-- Validation
				if type(func) ~= "function" then
					if Core.Debug then
						error("Bad argument to Group method 'SetCallback'. 'func' must be a function.", 2)
					end
					return
				elseif arg and type(arg) ~= "table" then
					if Core.Debug then
						error("Bad argument to Group method 'SetCallback'. 'arg' must be a table or nil.", 2)
					end
					return
				end

				Callback:Register(self.ID, func, arg or false)
				self.Callback = true
			end,

			----------------------------------------
			-- Internal Methods
			---

			-- Disables the group.
			Disable = function(self)
				self.db.Disabled = true
				for Button in pairs(self.Buttons) do
					SkinButton(Button, self.Buttons[Button], "Classic")
				end
				local db = self.db

				-- Fire the callback.
				if self.Callback then
					Callback(self.ID, self.Group, db.SkinID, db.Gloss, db.Backdrop, db.Colors, true)
				elseif self.Addon then
					Callback(self.Addon, self.Group, db.SkinID, db.Gloss, db.Backdrop, db.Colors, true)
				end

				local Subs = self.SubList
				if Subs then
					for _, Sub in pairs(Subs) do
						Sub:Disable()
					end
				end
			end,

			-- Enables the group.
			Enable = function(self)
				self.db.Disabled = false
				self:ReSkin()

				local Subs = self.SubList
				if Subs then
					for _, Sub in pairs(Subs) do
						Sub:Enable()
					end
				end
			end,

			-- Validates and sets a skin option.
			SetOption = function(self, Option, Value)
				if Option == "SkinID" then
					if Value and Skins[Value] then
						self.db.SkinID = Value
					end
				elseif Option == "Gloss" then
					if type(Value) ~= "number" then
						Value = (Value and 1) or 0
					end
					self.db.Gloss = Value
				elseif Option == "Backdrop" then
					self.db.Backdrop = (Value and true) or false
				elseif Option == "Shadow" then
					self.db.Shadow = (Value and true) or false
				else
					return
				end
				self:ReSkin()
				local Subs = self.SubList
				if Subs then
					for _, Sub in pairs(Subs) do
						Sub:SetOption(Option, Value)
					end
				end
			end,

			-- Sets the specified layer color.
			SetColor = function(self, Layer, r, g, b, a)
				if not Layer then return end
				if r then
					self.db.Colors[Layer] = {r, g, b, a}
				else
					self.db.Colors[Layer] = nil
				end
				self:ReSkin()
				local Subs = self.SubList
				if Subs then
					for _, Sub in pairs(Subs) do
						Sub:SetColor(Layer, r, g, b, a)
					end
				end
			end,

			-- Resets the group's skin back to its defaults.
			Reset = function(self)
				self.db.Backdrop = false
				self.db.Shadow = false
				self.db.Gloss = 0

				for Layer in pairs(self.db.Colors) do
					self.db.Colors[Layer] = nil
				end
				self:ReSkin()
				local Subs = self.SubList
				if Subs then
					for _, Sub in pairs(Subs) do
						Sub:Reset()
					end
				end
			end,

			-- Updates the group on profile activity.
			Update = function(self, IsNew)
				local db = Core.db.profile.Groups[self.ID]

				-- Only update on profile change or group creation.
				if db == self.db then return end

				-- Update the DB the first time StaticID is used.
				if self.StaticID and not db.Upgraded then
					-- Get the old DB.
					local o_id = GetID(self.Addon, self.Group)
					local o_db = Core.db.profile.Groups[o_id]

					-- Make sure it's not a new group.
					if not o_db.Inherit then
						Core.db.profile.Groups[self.ID] = o_db
						db = Core.db.profile.Groups[self.ID]
					end

					-- Remove the old pointer.
					Core.db.profile.Groups[o_id] = nil
					db.Upgraded = true
				end

				self.db = db

				-- Inheritance
				if self.Parent then
					local p_db = self.Parent.db

					-- Inherit the parent's settings on a new db.
					if db.Inherit then
						db.SkinID = p_db.SkinID
						db.Gloss = p_db.Gloss
						db.Backdrop = p_db.Backdrop

						-- Remove any colors.
						for Layer in pairs(db.Colors) do
							db.Colors[Layer] = nil
						end

						-- Duplicate the parent's colors.
						for Layer in pairs(p_db.Colors) do
							local c = p_db.Colors[Layer]
							if type(c) == "table" then
								db.Colors[Layer] = {c[1], c[2], c[3], c[4]}
							end
						end

						db.Inherit = false
					end

					-- Update the disabled state.
					if p_db.Disabled then
						db.Disabled = true
					end
				end

				-- New Group
				if IsNew then
					-- Queue the group if PLAYER_LOGIN hasn't fired and the skin hasn't loaded.
					if Core.Queue and not self.Queued and not Skins[db.SkinID] then
						Core.Queue(self)
					end

					-- Update the options.
					Core:UpdateSkinOptions(self)

				-- Update the skin.
				else
					if db.Disabled then
						for Button in pairs(self.Buttons) do
							SkinButton(Button, self.Buttons[Button], "Classic")
						end
					else
						self:ReSkin()
					end

					-- Update the sub-groups.
					local Subs = self.SubList
					if Subs then
						for _, Sub in pairs(Subs) do
							Sub:Update()
						end
					end
				end
			end,

			-- Returns an Ace3 options table for the group.
			GetOptions = function(self, Order)
				return Core.GetOptions(self, Order)
			end,
		}
	}
end
