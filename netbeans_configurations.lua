--
-- netbeans/netbeans_configurations.lua
-- Generate a C/C++ netbeans project.
-- Author: Santo Pfingsten
--         Manu Evans
-- Copyright (c) 2013-2015 Santo Pfingsten
--

	local p = premake
	local m = p.modules.netbeans

	m.configurations = {}
	
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree


---------------------------------------------------------------------------
--
-- Configurations file creation
--
---------------------------------------------------------------------------

	function m.configurations.generate(prj)
		_p('<?xml version="1.0" encoding="UTF-8"?>')
		_p('<configurationDescriptor version="95">')

		m.configurations.files(prj)
		m.configurations.sourceRootList(prj)

		_p(1, '<projectmakefile>Makefile</projectmakefile>')
		
		_p(1, '<confs>')
		for cfg in project.eachconfig(prj) do
			m.configurations.conf(cfg, prj)
		end
		_p(1, '</confs>')

		_p('</configurationDescriptor>')
	end


	function m.configurations.files(prj)

		_p(1, '<logicalFolder name="root" displayName="root" projectFiles="true" kind="ROOT">')

--		_p(2, '<logicalFolder name="ResourceFiles" displayName="Resource Files" projectFiles="true">')
--		_p(2, '</logicalFolder>')

		_p(2, '<logicalFolder name="SourceFiles" displayName="Source Files" projectFiles="true">')
		local tr = project.getsourcetree(prj)
		tree.sort(tr)
		tree.traverse(tr, {
			onbranchenter = function(node, depth)
				if depth > 0 then
					_p(depth + 2, '<logicalFolder name="%s" displayName="%s" projectFiles="true">', p.esc(node.name), p.esc(node.name))
				end
			end,
			onbranchexit = function(node, depth)
				if depth > 0 then
					_p(depth + 2, '</logicalFolder>')
				end
			end,
			
			onleaf = function(node, depth)
				_p(depth + 2, '<itemPath>%s</itemPath>', m.escapepath(prj, node.relpath))
			end
		}, true)
		_p(2, '</logicalFolder>')

		_p(2, '<logicalFolder name="ExternalFiles" displayName="Important Files" projectFiles="false" kind="IMPORTANT_FILES_FOLDER">')
		_p(3, '<itemPath>Makefile</itemPath>')
		_p(2, '</logicalFolder>')

		_p(1, '</logicalFolder>')

	end


	function m.configurations.sourceRootList(prj)

		_p(1, '<sourceRootList>')
		m.rootElements(prj, 2, 'Elem')
		_p(1, '</sourceRootList>')

	end

	function m.configurations.conf(cfg, prj)

		_p(2, '<conf name="%s" type="%d">', p.esc(cfg.shortname), m.kindToType(cfg.kind))

		m.configurations.toolsSet(cfg)
		m.configurations.compileType(cfg, prj)
		m.configurations.items(cfg, prj)

		_p(2, '</conf>')

	end

	function m.configurations.toolsSet(cfg)

		_p(3, '<toolsSet>')
		_p(4, '<remote-sources-mode>LOCAL_SOURCES</remote-sources-mode>')
		_p(4, '<compilerSet>default</compilerSet>')
		_p(4, '<dependencyChecking>true</dependencyChecking>')
		_p(4, '<rebuildPropChanged>false</rebuildPropChanged>')
		_p(3, '</toolsSet>')

	end

	function m.configurations.compileType(cfg, prj)

		local toolset, version = m.gettoolset(cfg)

		_p(3, '<compileType>')

		m.configurations.confTool(cfg, 'cTool', table.join(toolset.getcflags(cfg), cfg.buildoptions))
		m.configurations.confTool(cfg, 'ccTool', table.join(toolset.getcppflags(cfg), toolset.getcflags(cfg), cfg.buildoptions))

		local output = m.escapepath(prj, path.join(cfg.buildtarget.directory, cfg.buildtarget.name))
		if cfg.kind == "StaticLib" then
			m.configurations.archiver(cfg, prj, output)
		else
			m.configurations.linker(cfg, prj, toolset, output)
		end

		-- TODO: <requiredProjects />

		_p(3, '</compileType>')

	end

	function m.configurations.confTool(cfg, toolName, flags)
		_p(4, '<%s>', toolName)
		if not config.isDebugBuild(cfg) and cfg.flags.ReleaseRuntime then
			_p(5, '<developmentMode>5</developmentMode>')
		end
		_p(5, '<incDir>')
		for _, incdir in ipairs(cfg.includedirs) do
			_p(6, '<pElem>%s</pElem>', m.escapepath(cfg.project, incdir))
		end
		_p(5, '</incDir>')
		_p(5, '<preprocessorList>')
		for _, definename in ipairs(cfg.defines) do
			_p(6, '<Elem>%s</Elem>', p.esc(definename))
		end
		_p(5, '</preprocessorList>')
		_p(5, '<commandLine>%s</commandLine>', p.esc(table.concat(flags, " ")))
		_p(4, '</%s>', toolName)
	end

	function m.configurations.archiver(cfg, prj, output)
		_p(4, '<archiverTool>')
		_p(5, '<output>%s</output>', output)
		_p(4, '</archiverTool>')
	end

	function m.configurations.linker(cfg, prj, toolset, output)
		_p(4, '<linkerTool>')

		_p(5, '<linkerAddLib>')
		for _, libdir in ipairs(config.getlinks(cfg, "siblings", "directory")) do
		_p(6, '<pElem>%s</pElem>', m.escapepath(prj, libdir))
		end
		_p(5, '</linkerAddLib>')

		_p(5, '<linkerLibItems>')
		local scope = iif(explicit, "all", "system")
		for _, libname in ipairs(config.getlinks(cfg, scope, "fullpath")) do
		_p(6, '<linkerLibLibItem>%s</linkerLibLibItem>', p.esc(path.getbasename(libname)))
		end
		_p(5, '</linkerLibItems>')

		_p(5, '<commandLine>%s</commandLine>', p.esc(table.concat(table.join(toolset.getldflags(cfg), cfg.linkoptions), " ")))

		_p(5, '<output>%s</output>', output)

		_p(4, '</linkerTool>')
	end

	function m.configurations.items(cfg, prj)

		for _, file in ipairs(prj.files) do
			local tool = 3
			if path.iscfile(file) then
				tool = 0
			elseif path.iscppfile(file) then
				tool = 1
			end

			_p(3, '<item path="%s" ex="false" tool="%d" flavor2="0"></item>', m.escapepath(prj, file), tool)
		end

	end
