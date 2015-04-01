--
-- netbeans/netbeans.lua
-- Define the netbeans action(s).
-- Copyright (c) 2013-2015 Santo Pfingsten
--

	local p = premake

	p.modules.netbeans = { }

	local netbeans = p.modules.netbeans
	local solution = p.solution
	local project = p.project


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
		return p.esc(file)
	end  

	function netbeans.gettoolset(cfg)
		local toolset = p.tools[cfg.toolset or "gcc"]
		if not toolset then
			error("Invalid toolset '" + cfg.toolset + "'")
		end
		return toolset
	end

	function netbeans.generate(prj)
		p.escaper(netbeans.esc)
		p.generate(prj, prj.name .. "/Makefile", p.modules.netbeans.makefile.generate)
		p.generate(prj, prj.name .. "/nbproject/project.xml", p.modules.netbeans.projectfile.generate)
		p.generate(prj, prj.name .. "/nbproject/configurations.xml", p.modules.netbeans.configfile.generate)
	end


	include("_preload.lua")
	include("netbeans_cpp.lua")

	return netbeans
