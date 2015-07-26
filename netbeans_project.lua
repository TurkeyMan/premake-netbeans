--
-- netbeans/netbeans_project.lua
-- Generate a C/C++ netbeans project.
-- Author: Santo Pfingsten
--         Manu Evans
-- Copyright (c) 2013-2015 Santo Pfingsten
--

	local p = premake
	local m = p.modules.netbeans

	m.project = {}
	
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree


---------------------------------------------------------------------------
--
-- Some shared methods
--
---------------------------------------------------------------------------

	function m.rootElements(prj, d, tagname)
		-- Build a source tree without removing the root
		local tr = tree.new(prj.name)
		table.foreachi(prj._.files, function(fcfg)
			local flags
			if fcfg.vpath ~= fcfg.relpath then
				flags = { trim = false }
			end
			local parent = tree.add(tr, path.getdirectory(fcfg.vpath), flags)
			local node = tree.insert(parent, tree.new(path.getname(fcfg.vpath)))
			setmetatable(node, { __index = fcfg })
		end)
		tree.sort(tr)
		
		-- Need more than one child
		while #tr.children == 1 do
			tr = tr.children[1]
			if tr.trim == false then
				break
			end
		end

		-- If there are files inside this folder, use the parent folder
		local numChildren = #tr.children
		for i = 1, numChildren do
			-- Only files have relpath set
			if tr.children[i].relpath then
				tr = tr.parent
				numChildren = 1
				break
			end
		end
		
		print(numChildren)
		for i = 1, numChildren do
--			local child = 
			_p(d, '<%s>%s</%s>', tagname, m.escapepath(prj, tr.children[i].path), tagname)
		end
	end

	m.kinds = {
		WindowedApp = 1,
		ConsoleApp = 1,
		SharedLib = 2,
		StaticLib = 3
	}
	function m.kindToType(kind)
		return m.kinds[kind] or 1
	end


---------------------------------------------------------------------------
--
-- Project file creation
--
---------------------------------------------------------------------------

	function m.project.deps(prj)

		_p(3, '<make-dep-projects/>')

		-- TODO: hook up link dependencies
--		<make-dep-projects>
--			<make-dep-project>../CppStaticLibrary_1</make-dep-project>
--		</make-dep-projects>

	end

	function m.project.sourceRootList(prj)

		_p(3, '<sourceRootList>')
		m.rootElements(prj, 4, 'sourceRootElem')
		_p(3, '</sourceRootList>')

	end

	function m.project.confList(prj)

		_p(3, '<confList>')
		for cfg in project.eachconfig(prj) do
			_p(4, '<confElem>')
			_p(5, '<name>%s</name>', p.esc(cfg.shortname))
			_p(5, '<type>%d</type>', m.kindToType(cfg.kind))
			_p(4, '</confElem>')
		end
		_p(3, '</confList>')

	end

	function m.project.generate(prj)

		_p('<?xml version="1.0" encoding="UTF-8"?>')
		_p('<project xmlns="http://www.netbeans.org/ns/project/1">')
		_p(1, '<type>org.netbeans.modules.cnd.makeproject</type>')
		_p(1, '<configuration>')
		_p(2, '<data xmlns="http://www.netbeans.org/ns/make-project/1">')
		_p(3, '<name>%s</name>', p.esc(prj.name))
		_p(3, '<c-extensions>c</c-extensions>')
		_p(3, '<cpp-extensions>cpp,cxx,cc</cpp-extensions>')
		_p(3, '<header-extensions>h,hpp,hxx,hh</header-extensions>')
		_p(3, '<sourceEncoding>UTF-8</sourceEncoding>')

		m.project.deps(prj)
		m.project.sourceRootList(prj)
		m.project.confList(prj)

		_p(3, '<formatting>')
		_p(4, '<project-formatting-style>false</project-formatting-style>')
		_p(3, '</formatting>')
		_p(2, '</data>')
		_p(1, '</configuration>')
		_p('</project>')

	end
