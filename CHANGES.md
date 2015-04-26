# Release Notes #

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
