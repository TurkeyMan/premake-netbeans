--
-- Name:        netbeans/_preload.lua
-- Purpose:     Define the MonoDevelop action.
-- Author:      Santo Pfingsten
--              Manu Evans
-- Created:     2013
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

--
-- Register the "netbeans" action
--

	local p = premake

	newaction {
		trigger         = "netbeans",
		shortname       = "NetBeans",
		description     = "Generate NetBeans project files",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc     = { "clang", "gcc" },
		},
		
		onProject = function(prj)
			p.modules.netbeans.generate(prj)
		end,
		
		onCleanProject = function(prj)
			p.clean.directory(prj, prj.name)
		end
	}


--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return (_ACTION == "netbeans")
	end
