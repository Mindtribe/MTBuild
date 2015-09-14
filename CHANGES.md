# Release Notes #


## MTBuild 0.1.3 ##

### Changes ###

* Changed 'default' task to 'all' task to be more compatible with 'make'
  conventions.  
* Fixed bug where source files couldn't be excluded with 'excludes'
  configuration property.
* Renamed the 'excludes' property to 'source_excludes' and documented it.
  (Source file exclusion was previously undocumented--probably because it
  didn't work.)  


## MTBuild 0.1.2 ##

### Changes ###

* Fixed issue where executables and libraries are generated with colons in
  their names due to workspace prefix.
* Added pre-build and post-build project tasks. 


## MTBuild 0.1.1 ##

### Changes ###

* Removed the gpp (g++) toolchains. Upon further reflection, these made no
  sense. We're back to simply having "gcc" toolchains, but now these will
  automatically invoke "gcc" or "g++" on C or C++ files, respectively. And if
  a configuration contains any C++ files, the linking is performed with "g++".


## MTBuild 0.1.0 ##

### Changes ###

* MTBuild v0.1.0 is a big, API-breaking change.
* MTBuild now requires Ruby >= 2.0.0.
* MTBuild now overrides the rake application name to display "mtbuild" as the
  application name.
* MTBuild now offers a '--super-dry-run' command line option to perform a dry
  run of the build where each command is printed, but not executed.
* Workspaces can now include other workspaces to inherit their projects and
  configurations.
* Default tasks can no longer be added to projects. You can only add default
  tasks to workspaces. If you need default tasks for a project, simply include
  a lightweight workspace that exists solely to specify default tasks.
* The "clobber" task is now gone. MTbuild workspaces now generate a top-level
  "clean" task that cleans all projects. Additionally, each project provides
  its own "clean" task for cleaning just one project at a time. The "clean"
  tasks remove all intermediate files and final output, so they behave like
  the older Rake "clobber" task.
* Added the "gpp" toolchains. These are similar to the gcc toolchains, but they
  invoke g++ instead of gcc.


## MTBuild 0.0.9 ##

### Changes ###

* MTBuild now requires Rake 10.4.2
* Fixed bug that prevented library include path specification for gcc-based
  toolchains.


## MTBuild 0.0.8 ##

### Changes ###

* MTBuild now uses 'mtbuildfile', 'MTBuildfile', 'mtbuildfile.rb', or 'MTBuildfile.rb'
  instead of the standard rakefile names. This was changed to avoid confusion
  since MTBuild files don't work with the "rake" command.
* When merging project configurations with workspace defaults, MTBuild now
  merges any arrays using the union operator. This allows projects to extend
  more default workspace configuration.
* MTBuild now allows strings or arrays for toolchain settings. If arrays are
  used, project configurations will be merged with any default workspace
  configurations. For example, a workspace could declare default cflags as
  and array of individual flags. A project could then declare its own cflags,
  which MTBuild would merge with the workspace defaults instead of
  overriding them.


## MTBuild 0.0.7 ##

### Changes ###

* GCC-based toolchains can now automatically handle renamed header files.
  Previously, if you renamed a header file, you had to manually clean before building.


## MTBuild 0.0.6 ##

### Changes ###

* Fixed spaces in project paths for test executables


## MTBuild 0.0.5 ##

### Changes ###

* MTBuild now supports spaces in project paths
* Cleaned up mtbuild sources and coverted stray tabs to spaces.


## MTBuild 0.0.4 ##

### Changes ###

* This was a bad gem push. Don't use.


## MTBuild 0.0.3 ##

### Changes ###

* MTBuild now supports configuration headers in static library and framework projects.


## MTBuild 0.0.2 ##

### Changes ###

* MTBuild now supports Frameworks.

* MTBuild can now create applications packages and can build framework packages from static library projects.


## MTBuild 0.0.1 ##

### Changes ###

None. This is the first release.
