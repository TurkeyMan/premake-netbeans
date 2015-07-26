--
-- netbeans/netbeans_makefile.lua
-- Generate a C/C++ netbeans project.
-- Author: Santo Pfingsten
--         Manu Evans
-- Copyright (c) 2013-2015 Santo Pfingsten
--

	local p = premake
	local m = p.modules.netbeans

	m.makefile = {}
	
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree


---------------------------------------------------------------------------
--
-- Makefile creation
--
---------------------------------------------------------------------------

	function m.makefile.createcommands(prj, key, text)
		for cfg in project.eachconfig(prj) do
			local commands = cfg[key]
			if #commands > 0 then
				_x('ifeq ($(CND_CONF),%s)', cfg.shortname)
					_p('\t@echo Running %s commands', text)
					_p('\t%s', table.implode(commands, "", "", "\n\t"))
				_p('endif')
			end
		end
	end

	function m.makefile.instructions(prj)
		_p([[
#
#  There exist several targets which are by default empty and which can be 
#  used for execution of your targets. These targets are usually executed 
#  before and after some main targets. They are: 
#
#     .build-pre:              called before 'build' target
#     .build-post:             called after 'build' target
#     .clean-pre:              called before 'clean' target
#     .clean-post:             called after 'clean' target
#     .clobber-pre:            called before 'clobber' target
#     .clobber-post:           called after 'clobber' target
#     .all-pre:                called before 'all' target
#     .all-post:               called after 'all' target
#     .help-pre:               called before 'help' target
#     .help-post:              called after 'help' target
#
#  Targets beginning with '.' are not intended to be called on their own.
#
#  Main targets can be executed directly, and they are:
#  
#     build                    build a specific configuration
#     clean                    remove built files from a configuration
#     clobber                  remove all built files
#     all                      build all configurations
#     help                     print help mesage
#  
#  Targets .build-impl, .clean-impl, .clobber-impl, .all-impl, and
#  .help-impl are implemented in nbproject/makefile-impl.mk.
#
#  Available make variables:
#
#     CND_BASEDIR                base directory for relative paths
#     CND_DISTDIR                default top distribution directory (build artifacts)
#     CND_BUILDDIR               default top build directory (object files, ...)
#     CONF                       name of current configuration
#     CND_PLATFORM_${CONF}       platform name (current configuration)
#     CND_ARTIFACT_DIR_${CONF}   directory of build artifact (current configuration)
#     CND_ARTIFACT_NAME_${CONF}  name of build artifact (current configuration)
#     CND_ARTIFACT_PATH_${CONF}  path to build artifact (current configuration)
#     CND_PACKAGE_DIR_${CONF}    directory of package (current configuration)
#     CND_PACKAGE_NAME_${CONF}   name of package (current configuration)
#     CND_PACKAGE_PATH_${CONF}   path to package (current configuration)
#
# NOCDDL

]])
	end

	function m.makefile.header(prj)
		_p([[
# Environment 
MKDIR=mkdir
CP=cp
CCADMIN=CCadmin

]])
	end

	function m.makefile.buildEvents(prj)
		_p('# build')
		_p('build: .build-post')
		_p('')
		_p('.build-pre:')
		m.makefile.createcommands(prj, 'prebuildcommands', 'pre-build')
		_p('')
		_p('.build-post: .build-impl')
		m.makefile.createcommands(prj, 'postbuildcommands', 'post-build')
		_p('')
		_p('')

		-- fixme: prelink doesn't seem possible ?
--		m.makefile.createcommands(prj, 'prelinkcommands', 'pre-link')

	end

	function m.makefile.clean(prj)
		_p([[
# clean
clean: .clean-post

.clean-pre:
# Add your pre 'clean' code here...

.clean-post: .clean-impl
# Add your post 'clean' code here...

]])
	end

	function m.makefile.clobber(prj)
		_p([[
# clobber
clobber: .clobber-post

.clobber-pre:
# Add your pre 'clobber' code here...

.clobber-post: .clobber-impl
# Add your post 'clobber' code here...

]])
	end

	function m.makefile.all(prj)
		_p([[
# all
all: .all-post

.all-pre:
# Add your pre 'all' code here...

.all-post: .all-impl
# Add your post 'all' code here...

]])
	end

	function m.makefile.buildTest(prj)
		_p([[
# build tests
build-tests: .build-tests-post

.build-tests-pre:
# Add your pre 'build-tests' code here...

.build-tests-post: .build-tests-impl
# Add your post 'build-tests' code here...

]])
	end

	function m.makefile.runTest(prj)
		_p([[
# run tests
test: .test-post

.test-pre: build-tests
# Add your pre 'test' code here...

.test-post: .test-impl
# Add your post 'test' code here...

]])
	end

	function m.makefile.help(prj)
		_p([[
# help
help: .help-post

.help-pre:
# Add your pre 'help' code here...

.help-post: .help-impl
# Add your post 'help' code here...

]])
	end

	m.elements.makefile = function(prj)
		return {
			m.makefile.instructions,
			m.makefile.header,
			m.makefile.buildEvents,
			m.makefile.clean,
			m.makefile.clobber,
			m.makefile.all,
			m.makefile.buildTest,
			m.makefile.runTest,
			m.makefile.help,
		}
	end

	function m.makefile.generate(prj)

		p.callArray(m.elements.makefile, prj)

		_p([[

# include project implementation makefile
include nbproject/Makefile-impl.mk

# include project make variables
include nbproject/Makefile-variables.mk
]])
	end
