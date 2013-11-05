--
-- netbeans.lua
-- Define the netbeans action(s).
-- Copyright (c) 2013 Santo Pfingsten
--

	premake.extensions.netbeans = { }
	local netbeans = premake.extensions.netbeans
	local solution = premake.solution
	local project = premake.project

	netbeans.support_url = "https://bitbucket.org/premakeext/netbeans/wiki/Home"

	netbeans.printf = function( msg, ... )
		printf( "[netbeans] " .. msg, ...)
	end

	netbeans.printf( "Premake NetBeans Extension (" .. netbeans.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "actions/?.lua;".. package.path


--
-- Register the "netbeans" action
--

	newaction {
		trigger         = "netbeans",
		shortname       = "NetBeans",
		description     = "Generate NetBeans project files",
	
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc     = { "clang", "gcc" },
		},
		
		onproject = function(prj)
			io.esc = netbeans.esc
			premake.generate(prj, prj.name .. "/Makefile", netbeans.makefile.generate)
			premake.generate(prj, prj.name .. "/nbproject/project.xml", netbeans.projectfile.generate)
			premake.generate(prj, prj.name .. "/nbproject/configurations.xml", netbeans.configfile.generate)
		end,
		
		oncleanproject = function(prj)
			premake.clean.directory(prj, prj.name)
		end
	}


---
-- Apply XML escaping on a value to be included in an
-- exported project file.
---

	function netbeans.esc(value)
		value = string.gsub(value, '&',  "&amp;")
		value = value:gsub('"',  "&quot;")
		value = value:gsub("'",  "&apos;")
		value = value:gsub('<',  "&lt;")
		value = value:gsub('>',  "&gt;")
		value = value:gsub('\r', "&#x0D;")
		value = value:gsub('\n', "&#x0A;")
		return value
	end
	
	function netbeans.escapepath(prj, file)
		if path.isabsolute(file) then
			file = project.getrelative(prj, file)
		end
		
		if not path.isabsolute(file) then
			file = path.join('../', file)
		end
		return premake.esc(file)
	end  
	
	function netbeans.gettoolset(cfg)
		local toolset = premake.tools[cfg.toolset or "gcc"]
		if not toolset then
			error("Invalid toolset '" + cfg.toolset + "'")
		end
		return toolset
	end


--
-- 'require' the project generation code.
--

	require( "netbeans_cpp" )
	netbeans.printf( "Loaded NetBeans C/C++ support 'netbeans_cpp.lua'", v )
