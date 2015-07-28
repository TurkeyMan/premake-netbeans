--
-- netbeans/netbeans.lua
-- Define the netbeans action(s).
-- Author: Santo Pfingsten
--         Manu Evans
-- Copyright (c) 2013-2015 Santo Pfingsten
--

	local p = premake

	p.modules.netbeans = {}

	local m = p.modules.netbeans

	local solution = p.solution
	local project = p.project

	m._VERSION = "0.0.1"
	m.elements = {}

---
-- Apply XML escaping on a value to be included in an
-- exported project file.
---

	function m.esc(value)
		value = string.gsub(value, '&',  "&amp;")
		value = value:gsub('"',  "&quot;")
		value = value:gsub("'",  "&apos;")
		value = value:gsub('<',  "&lt;")
		value = value:gsub('>',  "&gt;")
		value = value:gsub('\r', "&#x0D;")
		value = value:gsub('\n', "&#x0A;")
		return value
	end

	function m.escapepath(prj, file)
		if path.isabsolute(file) then
			file = project.getrelative(prj, file)
		end
		
		return p.esc(file)
	end  

	function m.gettoolset(cfg)
		local toolset = p.tools[cfg.toolset or "gcc"]
		if not toolset then
			error("Invalid toolset '" + cfg.toolset + "'")
		end
		return toolset
	end

	function m.generate(prj)
		p.escaper(m.esc)
		p.indent("  ")
		p.generate(prj, "Makefile", m.makefile.generate)
		p.generate(prj, "nbproject/project.xml", m.project.generate)
		p.generate(prj, "nbproject/configurations.xml", m.configurations.generate)
	end


	include("_preload.lua")
	include("netbeans_makefile.lua")
	include("netbeans_project.lua")
	include("netbeans_configurations.lua")

	return m
