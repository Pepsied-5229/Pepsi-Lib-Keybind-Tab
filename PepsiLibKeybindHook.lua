task.spawn(function(Library, Window)
	if Library then else
		Library = shared.libraries[1]
		if Library then else
			return warn("Could not find library! Please pass the library as argument #1")
		end
	end

	if Window then else
		for k, v in next, Library.globals do
			if v and v.windowFunctions then
				Window = v.windowFunctions
				break
			end
		end
		if Window then else
			return warn("Could not find window! Please pass the window as argument #2")
		end
	end

	local KeybindsTab = Window:CreateTab({
		Name = "Keybinds"
	})

	local KeybindsSectionL = KeybindsTab:CreateSection({
		Name = "Keybinds",
		Side = "left"
	})

	local KeybindsSectionR = KeybindsTab:CreateSection({
		Name = "Keybinds",
		Side = "right"
	})

	local MayUpdate = true

	local function Sort1Lower(A, B)
		return A[1]:lower() < B[1]:lower()
	end

	local function GetAllBinds()
		local Keybinds = {}
		for Name, Element in next, Library.elements do
			if Element and (Element.Type == "Keybind") and (Element.IsKeybindHook == nil) and (Element.Flag ~= "__Designer.Settings.ShowHideKey") then
				Element.OriginalCallback = Element.OriginalCallback or Element.Callback
				Keybinds[1 + #Keybinds] = {Name, Element}
			end
		end
		table.sort(Keybinds, Sort1Lower)
		return Keybinds
	end

	local function ClearAllBinds()
		for _, Element in next, Library.elements do
			if Element and Element.IsKeybindHook and (Element.Type == "Keybind") then
				Element:Remove()
			end
		end
	end

	local function PopulateBinds()
		MayUpdate = nil
		local Keybinds = GetAllBinds()
		ClearAllBinds()
		local Side = 0
		for _, Data in next, Keybinds do
			local Name, Keybind = Data[1], Data[2]
			local Desc
			if Keybind.ToggleData then
				Desc = Keybind.ToggleData.Options.Name
			else
				Desc = Keybind.Options.Name
			end
			Side = 1 + (Side % 2)
			local KeybindsSection = ((Side == 1) and KeybindsSectionL) or KeybindsSectionR
			local Bind
			Bind = KeybindsSection:AddKeybind({
				Name = Desc,
				Value = Keybind:Get(),
				Callback = function(Key)
					if MayUpdate then
						Keybind:Set(Key)
						Bind:Set(Key)
					end
				end
			})
			function Keybind.Callback(...)
				local Key = ...
				pcall(Bind.Set, Bind, Key)
				if Keybind.OriginalCallback then
					return Keybind.OriginalCallback(...)
				end
			end
			Bind.IsKeybindHook = true
		end
		MayUpdate = true
	end

	PopulateBinds()
	while Library.Wait(10) do
		PopulateBinds()
	end
end)