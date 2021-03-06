# MTBuild #

[![Gem Version](https://badge.fury.io/rb/mtbuild.svg)](http://badge.fury.io/rb/mtbuild)

MTBuild is Mindtribe's Rake-based build system for building C/C++ projects.

MTBuild lives here: https://github.com/Mindtribe/MTBuild

## Quick Start ##

### Installation ###

MTBuild is distributed as a gem. Install it with:

```Shell
gem install mtbuild
```

To build with MTBuild, switch to a folder containing an mtbuildfile and run:

```Shell
mtbuild
```

To install from source, clone the [MTBuild repository](https://github.com/Mindtribe/MTBuild) and run the following:

```Shell
rake install
```

### Getting Started ###

Here's an example of a very simple mtbuildfile.rb that defines an MTBuild project:

```Ruby
application_project :MyApp, File.dirname(__FILE__) do |app|

  app.add_configuration :Debug,
    sources: ['src/*.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-std=c++03 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections',
      linker_script: 'src/LinkerFile-Debug.ld'
    )

end
```

This mtbuildfile builds an application called "MyApp" (```application_project :MyApp```).

The project folder is set to the mtbuildfile's containing folder (```File.dirname(__FILE__)```). All folder references in the mtbuildfile are relative to this folder.

The MyApp project has one configuration called "Debug" (```app.add_configuration :Debug,```).

The Debug configuration builds all C files in the "src" folder (```sources: ['src/*.c'],```).

The Debug configuration builds with the ARM toolchain (```toolchain: toolchain(:arm_none_eabi_gcc,```)

The ARM toolchain should use the specified C Preprocessor flags for all compilation and link steps (```cppflags: ...```)

The ARM toolchain should use the specified C flags when compiling C files (```cflags: ...```)

The ARM toolchain should use the specified C++ flags when compiling C++ files (```cxxflags: ...```)

The ARM toolchain should use the specified linker flags when linking (```ldflags: ...```)

The ARM toolchain should use the specified linker script when linking (```linker_script: ...```)

When invoked with no parameters, MTBuild will do nothing for this project. When invoked as ```mtbuild 'MyApp:Debug'```, MTBuild will build the ```Debug``` configuration of ```MyApp```.

You can find more project examples here: [MTBuild examples](https://github.com/Mindtribe/MTBuild/tree/master/examples)

## Documentation ##

### MTBuild Goals ###

1. With reasonable syntax (for example, XML is not considered reasonable here), allow a developer to define projects and workspaces that can be built from the command-line.
2. Allow developers to easily incorporate cross-compilers.
3. Allow developers to easily define multiple configurations for projects intended for multiple targets.
4. Support unit and integration testing with command line build and execution.
5. Opine on project structure, but allow exceptions where needed.
6. Leverage an existing build system's infrastructure and ecosystem.

### MTBuild Concepts ###

#### Project Structure ####

MTBuild is opinionated in that it is easy to describe our preferred project structure using MTBuild's domain-specific language. Because MTBuild uses Rake, other structures are possible but more difficult to describe.

Here is an example of our preferred structure for a complex application that is broken into one or more libraries plus the application itself:

```
Workspace Folder
  ├ mtbuildfile.rb         <-- workspace mtbuildfile
  ├ Library Project Folder
  │   ├ mtbuildfile.rb     <-- project mtbuildfile
  │   ├ include            <-- public headers
  │   │   └ *.h
  │   ├ src                <-- private headers and source
  │   │   └ *.h/*.c/*.cpp
  │   └ test               <-- unit tests
  │       └ *.c/*.cpp
  └ Application Project Folder
      ├ mtbuildfile.rb     <-- project mtbuildfile
      ├ src                <-- headers and source
      │   └ *.h/*.c/*.cpp
      └ test               <-- unit tests
          └ *.h/*.c/*.cpp
```

We have a top-level workspace folder that contains projects in sub-folders. The project folders have public headers and source files neatly separated. Unit Test files are either located in their own folders, or separated by language--for example, if our project is written in C, but our unit tests are C++, we might put the unit test files alongside the project sources for convenience.

Here is an example of a simpler application that is self-contained:

```
Application Project Folder
  ├ mtbuildfile.rb         <-- project+workspace mtbuildfile
  ├ src                    <-- headers and source
  │   └ *.h/*.c/*.cpp
  └ test                   <-- unit tests
      └ *.h/*.c/*.cpp
```

The project and (optional) workspace are defined in a single mtbuildfile. There are no public headers, so everything goes into the "src" folder, but tests might still be separated into a "test" folder.

#### mtbuildfiles ####

MTBuild uses Rake. MTBuild projects and workspaces are defined using mtbuildfiles. MTBuild offers new syntax to learn for defining projects and workspaces, but this syntax simply results in the generation of standard Rake tasks. Therefore, Rake is highly leveraged--if you encounter a build scenario that MTBuild doesn't quite handle, you can usually drop down to the Rake level and make it work.

#### Building ####

Building is as simple as invoking ```mtbuild``` in a folder containing a mtbuildfile. Under the hood, MTBuild pulls in the MTBuild infrastructure and then invokes Rake.

##### Command Line Options #####

MTBuild supports the standard Rake command line options. Additionally, it adds the following:

* ```--super-dry-run``` This command performs a dry run; however, unlike the Rake dry run, it actually prints the shell commands that would be executed.

#### Project Hierarchy ####

The MTBuild project hierarchy looks roughly like this:

```
Workspace
  ├ Project1
  │   ├ Configuration1
  │   └ Configuration2
  └ Project2
      ├ Configuration1
      └ Configuration2
```

#### Projects ####

MTBuild currently defines four types of projects.

##### Application Project #####

An application project defines one or more configurations that contain settings for building an executable application. This project type generates Rake tasks for compiling source files and linking them, along with external libraries, into an executable.

##### Library Project #####

A library project defines one or more configurations that contain settings for building a static library. This project type generates Rake tasks for compiling source files and archiving them into a static library container.

##### Test Application Project #####

A test application project defines one or more configurations that contain settings for building an executable application that is executed after building. This project type generates Rake tasks for compiling source files, linking them into an executable, and then running the executable. This is intended for building and running unit tests as part of the build process.

##### Framework Project #####

A framework project wraps up a static library and its headers for use by applications. See the "Frameworks" section below for more information.

#### Configurations ####

A configuration contains build settings for a project. This includes source files, toolchain, dependencies, etc. By defining multiple configurations, a project can be built for different processors (ARM, x86, etc.), different platforms, or simply different settings (debug vs. release). Configurations generate the actual Rake tasks that begin doing work. They are named with a fixed convention that allows you to refer to them in other Rake tasks. The naming scheme is "Project:Configuration". For example, if you declare a project called "MyLibrary" with configuration "Debug", you could list "MyLibrary:Debug" as a dependency in any Rake task and "MyLibrary:Debug" would be built before that task.

#### Workspaces ####

An MTBuild workspace contains MTBuild projects and can provide default settings for configurations within those projects. For example, a project configuration can specify source code files, but omit toolchain settings. A workspace could then provide default toolchain settings that the project inherits.

MTBuild workspaces are optional. It's possible to build an MTBuild project by itself--assuming the project provides all settings required to build & isn't relying on a workspace to provide those.

MTBuild allows workspaces to be nested. A workspace can include another workspace, allowing the parent to reference the child workspace's projects. When you include a child workspace from within your workspace, you can choose whether or not to pull in the child's default tasks. You can also choose to pull configurations up from the child or push configurations down to the child.

###### Simple Workspace Example #####

This defines a workspace that includes the "MyLibrary" and "MyApp" projects. The projects are presumed to be defined in their own mtbuildfiles inside sub-folders called "MyLibrary" and "MyApp".

mtbuildfile.rb:

```Ruby
workspace :AppWithLibrary, File.dirname(__FILE__) do |w|
  w.add_project('MyLibrary')
  w.add_project('MyApp')
end
```

###### Project Plus Workspace Example #####

This defines a workspace that includes the MyLibrary project, which is defined in the same mtbuildfile. When a project is defined in the same mtbuildfile, it does not need to be explicitly added to the workspace (in this particular example, the workspace isn't very useful).

mtbuildfile.rb:

```Ruby
workspace :MyWorkspace, File.dirname(__FILE__) do |w|
end

static_library_project :MyLibrary, File.dirname(__FILE__) do |lib|
  lib.add_api_headers 'include'
  lib.add_configuration :Debug,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc,
      cflags: '-std=c99',
    )
end
```

###### Project Plus Workspace With Defaults Example #####

This defines a workspace that includes the MyLibrary project, which is defined in the same mtbuildfile. The workspace provides a default toolchain for the "Debug" configuration. A higher-level workspace would override this with its own defaults.

mtbuildfile.rb:

```Ruby
workspace :MyLibrary, File.dirname(__FILE__) do |w|
  w.set_configuration_defaults :Debug,
    toolchain: toolchain(:gcc,
      cflags: '-std=c99',
    )
end

static_library_project :MyLibrary, File.dirname(__FILE__) do |lib|
  lib.add_api_headers 'include'
  lib.add_configuration :Debug,
    sources: ['src/**/*.c']
end
```

###### Nested Workspace Example #####

This defines a workspace that includes a "MyLibrary" workspace and pulls up a configuration called "Debug" from the "MyLibrary" workspace. This makes the library's "Debug" configuration settings available to the "MyApp" project, allowing "MyApp" to be built with the same toolchain settings as "MyLibrary".

mtbuildfile.rb:

```Ruby
workspace :AppWithLibrary, File.dirname(__FILE__) do |w|
  w.add_workspace('MyLibrary', pull_configurations: [:Debug])
  w.add_project('MyApp')
end
```

#### Dependencies ####

Configurations can list dependencies that will be built before the configuration. A configuration's dependencies are specified as a list of Rake tasks. Therefore, these dependencies can refer to other MTBuild projects or any Rake task.

#### Automatic Library Dependencies ####

MTBuild allows you to specify API header locations for framework and static library project configurations. If you list a framework or a static library project as a dependency of an application project, MTbuild will automatically include the framework or library's API header paths when compiling the application. Additionally, it will automatically link the application with the framework or library. This is intended to facilitate the scenario where you're building both a library and an application from a Workspace. To use the library from the application, you simply need to list the library as a dependency and MTBuild will make sure the application can use it.

Note that this does not work with non-MTBuild libraries. If you list a non-MTBuild Rake library task as a dependency of a MTBuild project, you will need to manually add the library's headers and library file to the project. If you have a precompiled 3rd-party library, you might consider wrapping it in a framework project so that you can use the Automatic Library Dependencies mechanism.

###### Configuration Headers #####

In addition to the per-project API header location, MTBuild allows you to specify per-configuration header locations. These are intended for headers that "configure" a library--typically via ```#define```. Note that this is a terrible pattern. If you're creating your own library, try very hard not to do this. For example, instead of using a ```#define``` to configure a library resource such as a buffer size, consider structuring the library such that the caller passes in buffer storage.

Using configuration headers to configure libraries is such a bad idea that MTBuild almost didn't support them. Unfortunately, the pattern is so common that we felt we needed to support them in order to work properly with many 3rd-party libraries. Again, if you're writing a library, avoid using them.

###### Automatic Library Dependencies Example #####

Top-level mtbuildfile.rb:

This defines a workspace that includes the "MyLibrary" and "MyApp" projects. Because MyApp will depend upon MyLibrary, the order that the projects are added does matter. MyLibrary needs to be added first.

```Ruby
workspace :AppWithLibrary, File.dirname(__FILE__) do |w|
  w.add_project('MyLibrary')
  w.add_project('MyApp')
end
```

MyLibrary/mtbuildfile.rb

This defines a library with one configuration called "Debug". The library's API headers are in a folder called "include". This library is foul and therefore has configuration headers for the Debug configuration in a folder called "config/Debug".

```Ruby
static_library_project :MyLibrary, File.dirname(__FILE__) do |lib|
  lib.add_api_headers 'include'
  lib.add_configuration :Debug,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc),
    configuration_headers: ['config/Debug']
end
```

MyApp/mtbuildfile.rb:

This defines an application with one configuration called "Debug". It uses two libraries. It takes advantage of the automatic library dependency feature to include and link with 'MyLibrary:Debug' simply by listing it as a dependency. It includes and links with a 3rd party by manually specifying the include path and the library file for the toolchain.

```Ruby
application_project :MyApp, File.dirname(__FILE__) do |app|
  app.add_configuration :Debug,
    sources: ['main.c'],
    toolchain: toolchain(:gcc,
      include_paths: '3rdPartyLibrary/include',
      include_objects: 'externalLibrary/lib/lib3rdPartyLibrary.a'
    ),
    dependencies: [
      'MyLibrary:Debug'
    ]
end
```

#### Frameworks ####

MTBuild Frameworks contain pre-compiled objects/libraries and their headers. MTBuild Frameworks generate tasks that don't do anything; however, applications can list Framework configurations as dependencies to take advantage of Automatic Library Dependencies.

#### Toolchains ####

MTBuild Toolchains generate the individual compile, archival, and link tasks that comprise an application or library. Most of the interesting settings in a project's configuration go in the toolchain. The settings vary based upon the toolchain.


#### DSL ####

MTBuild provides several Domain Specific Language (DSL) methods to wrap up the underlying MTBuild classes into a friendlier syntax. These are called out in the reference section below.

## Reference ##

### MTBuild::Workspace ###

Declare a workspace with the following DSL method:

```Ruby
workspace(workspace_name, workspace_folder, &configuration_block)
```

```workspace_name``` is your desired name for the workspace. This should be a symbol like ":MyWorkspace". It serves as a human-readable way to refer to the workspace.

```workspace_folder``` is the location of the workspace. Project folders should be located at or below this location. Typically, you'd simply pass ```File.dirname(__FILE__)``` to use the same folder as the workspace's mtbuildfile.

For ```configuration_block```, you supply a block that takes one parameter. When MTBuild invokes the block, it will pass a Workspace object as this parameter. Inside the block, you can make Workspace calls on this object to add projects, set configuration defaults, etc.

#### add_project ####

Use ```add_project(project_location)``` inside of a workspace configuration block to add a project that lives inside a subfolder. The ```project_location``` parameter must be a subfolder of the workspace. If the project lives at the same level as the workspace, you should define it in the same mtbuildfile as the workspace. In this case, the project will be implicitly added and you do not need to use ```add_project``` inside the workspace. See the **Project Plus Workspace Example** above for an example of a workspace and project that live at the same folder level.

#### add_workspace ####

Use ```add_workspace(workspace_location, pull_default_tasks: false, pull_configurations: [], push_configurations: [])``` inside of a workspace configuration block to add a child workspace that lives inside a subfolder. The ```workspace_location``` parameter must be a subfolder of the workspace.

The optional, named parameter, ```pull_default_tasks``` determines whether the parent workspace should pull in the child workspace's default tasks. If this is ```true```, then when ```mtbuild``` is run on the parent workspace with no specified build targets, the child workspace's default targets will be built. If this is ```false```, then only targets that are referenced from the child workspace will be built as needed.

The optional, named parameter ```pull_configurations``` specifies a list of configurations to pull up from the child workspace. Pulling up configurations makes them available to other projects included by the parent workspace.

The optional, named parameter ```push_configurations``` specifies a list of configurations to push down to the child workspace. Pushing down configurations allows you to add to a child workspace's configuration settings or, if the child has a default configuration set via ```set_default_configuration()```, you can auto-generate a new configuration.

#### add_default_tasks ####

Use ```add_default_tasks(default_tasks)``` inside of a workspace configuration block to add tasks that run when you invoke MTBuild with no arguments. The ```default_tasks``` parameter expects one or more (in an array) project task names. The project tasks should be qualified relative to the current workspace. For example, if a workspace includes a project called ```MyApp```, which has a configuration called ```Debug```, you can add this by referring to it as ```MyApp:Debug```. If no default tasks are specified, then invoking MTBuild with no arguments will effectively do nothing.

#### add_default_rake_tasks ####

Use ```add_default_rake_tasks(default_tasks)``` inside of a workspace configuration block to add tasks that run when you invoke MTBuild with no arguments. The ```default_tasks``` parameter expects one or more (in an array) Rake task names. Unlike ```add_default_tasks()```, this method expects "raw" Rake task names. This lets you specify that MTBuild should run any Rake task by default when building this workspace.

#### MTBuild::Workspace.add_default_tasks ####

Use the class method ```MTBuild::Workspace.add_default_tasks(default_tasks)``` to add a default task outside of a workspace configuration block. This is useful for letting projects register default tasks in the project's mtbuildfile.rb. Note that the tasks specified in the ```default_tasks``` list must be fully-qualified ```mtbuild``` names that take workspace nesting into account. You should use the project method ```task_for_configuration``` to get the correct task names.

#### set_configuration_defaults ####

Use ```set_configuration_defaults(configuration_name, defaults_hash)``` inside of a workspace configuration block to add default settings for a configuration. This is how you would select, for instance, a default toolchain for all projects with a specific configuration.

The following example selects the "gcc" toolchain and sets the C standard to C99 for any projects with a configuration named "Debug":

```Ruby
workspace :MyWorkspace, File.dirname(__FILE__) do |w|
  w.set_configuration_defaults :Debug,
    toolchain: toolchain(:gcc,
      cflags: '-std=c99',
    )
end
```

Any configuration value can be specified in the hash passed to ```set_configuration_defaults```. MTBuild merges workspace configuration value defaults with project configuration values. In the case of conflicting settings (when both a workspace and a project define the same configuration value), one of two things can happen:

1. If the configuration value is a string in either the project or the workspace, the project configuration wins and completely overrides the workspace's value.
2. If the configuration value is an array in both the project or the workspace, the values will be merged using a union operation. This allows the workspace to define, for example, "cflags" to be used for compiling, which could then be extended with more flags inside of a specific project. However, there is currently no way for a project to remove array values that are defined in the workspace. If a project needs to do this, it will have to override the entire workspace configuration using a string for the value.

The following example selects the "gcc" toolchain and sets the C standard to C99 for any projects with a configuration named "Debug". The project then extends the "cflags" to add an optimization level. The resulting command line would be "-std=c99 -O0":

```Ruby
workspace :MyWorkspace, File.dirname(__FILE__) do |w|
  w.set_configuration_defaults :Debug,
    toolchain: toolchain(:gcc,
      cflags: ['-std=c99'],
    )
end

static_library_project :MyLibrary, File.dirname(__FILE__) do |lib|
  lib.add_api_headers 'include'
  lib.add_configuration :Debug,
    sources: ['src/**/*.c']
    toolchain: toolchain(:gcc,
      cflags: ['-O0'],
    )
end
```

#### set_output_folder ####

Use ```set_output_folder(output_folder)``` inside of a workspace configuration block to change the build output folder. By default, this folder is set to "build" underneath the workspace folder. The ```output_folder``` parameter expects the name of a folder relative to the workspace. If the folder does not exist, MTBuild will create it.

### MTBuild::Project ###

This is a base class for projects. You won't typically use it directly, but it provides some useful methods for all project types.

#### task_for_configuration ####

Use ```task_for_configuration(config_name)``` to get the fully qualified task name for the project configuration called ```config_name```. This is useful for getting fully qualified task names to register as default tasks using ```MTBuild::Workspace.add_default_tasks```

#### tasks_for_all_configurations ####

Use ```tasks_for_all_configurations``` to get a list of the fully qualified task names for all of the project's configurations. This is useful for getting fully qualified task names to register as default tasks using ```MTBuild::Workspace.add_default_tasks```


### MTBuild::ApplicationProject ###

Define an Application Project with the following DSL method:

```Ruby
application_project(application_name, project_folder, &configuration_block)
```

```application_name``` is your desired name for the application. This should be a symbol such as ```:MyApplication```. It serves as a human-readable name for the application. Rake tasks related to this application will be namespaced with this symbol. For example, the top-level Rake task for building the "MyApplication" application with a configuration called "Debug" would be "MyApplication:Debug".

```project_folder``` is the location of the project. Project files should be located at or below this location. Typically, you'd simply pass ```File.dirname(__FILE__)``` to use the same folder as the project's mtbuildfile.

For ```configuration_block```, you supply a block that takes one parameter. When MTBuild invokes the block, it will pass an ApplicationProject object as this parameter. Inside the block, you can make ApplicationProject calls on this object to add configurations.

#### set_default_configuration ####

Use ```set_default_configuration(configuration)``` inside of an application project configuration block to add a default build configuration for the application. The ```configuration``` parameter expects a hash that contains settings for the configuration. Default project configurations allow you to specify a base set of toolchain settings, source files, dependencies, etc. for a project. Any project configurations that are explicitly added with ```add_configuration()``` will be merged with the project default.
 
You can also use ```set_default_configuration()``` in a project along with ```set_configuration_defaults()``` in the parent workspace to auto-generate project configurations without needing to explicitly add each configuration to a project with ```add_configuration()```. If a project contains a default configuration, then any configurations added with ```set_configuration_defaults()``` in a parent workspace will be auto-generated for the project by merging the workspace configuration with the default configuration. Note that you can use all three mechanisms together: ```set_default_configuration()```, ```set_configuration_defaults()```, and ```add_configuration()```. When you do so, the configuration results from the merging of all three tiers of settings.      

#### add_configuration ####

Use ```add_configuration(configuration_name, configuration)``` inside of an application project configuration block to add a build configuration for the application. The ```configuration_name``` parameter expects a symbol that serves as a human-readable name for the configuration. Rake tasks related to this configuration will be namespaced with this symbol. For example, the top-level Rake task for building the "Debug" configuration of "MyApplication" would be "MyApplication:Debug". The ```configuration``` parameter expects a hash that contains settings for the configuration.

##### Application Project configuration settings #####

Application Project configurations require the following settings:

* ```:toolchain``` - A toolchain hash constructed with the ```toolchain``` DSL method (detailed in a later section).

Application Project configurations offer the following optional settings:

* ```:dependencies``` - The Rake task names of one or more dependencies. For example, ```'MyLibrary:Debug'``` or ```['MyLibrary1:Debug', 'MyLibrary2:Debug']```. You can use the special character '.' to specify the current configuration. For example, ```'MyLibrary:.'``` would expand to ```'MyLibrary:Debug'``` if listed as a dependency in a configuration called 'Debug'.

* ```:sources``` - Source files to build in this configuration. Specified as one or more source file names or source file glob patterns. For example, ```'main.c'``` or ```['main.c', 'startup.c']``` or ```['src/main.c', 'src/*.cpp']```. Note that the source file paths should be relative to the project folder.

* ```:excluded_sources``` - Source files to exclude from the configuration. Specified as one or more source file names or source file glob patterns. For example, ```'badmain.c'``` or ```['badmain.c', 'badstartup.c']``` or ```['src/badmain.c', 'src/bad*.cpp']```. Note that the source file paths should be relative to the project folder.

* ```:tests``` - The Rake task names of one or more unit test applications. For example, ```'MyLibraryTest:Test'``` or ```['MyLibraryTest1:Test', 'MyLibraryTest2:Test']```

* ```:pre_build``` - A callable object (typically a ```lambda```) that will be invoked before the build of this configuration begins.

* ```:post_build``` - A callable object (typically a ```lambda```) that will be invoked after the build of this configuration completes.

### MTBuild::TestApplicationProject ###

Define a Test Application Project with the following DSL method:

```Ruby
test_application_project(application_name, project_folder, &configuration_block)
```

Test Application Projects are defined with the same parameters and settings as Application Projects. The only difference is that Test Application Projects attempt to execute their outputs after building. Therefore, Test Application Projects should always be defined with toolchains and settings suitable for execution on the host machine running MTBuild (as opposed to an Application Project, which could be using a cross-compiler).

### MTBuild::StaticLibraryProject ###

Define a Static Library Project with the following DSL method:

```Ruby
static_library_project(library_name, project_folder, &configuration_block)
```

```library_name``` is your desired name for the library. This should be a symbol like ```:MyLibrary```. It serves as a human-readable name for the library. Rake tasks related to this library will be namespaced with this symbol. For example, the top-level Rake task for building the "MyLibrary" library with a configuration called "Debug" would be "MyLibrary:Debug".

```project_folder``` is the location of the project. Project files should be located at or below this location. Typically, you'd simply pass ```File.dirname(__FILE__)``` to use the same folder as the project's mtbuildfile.

For ```configuration_block```, you supply a block that takes one parameter. When MTBuild invokes the block, it will pass a StaticLibraryProject object as this parameter. Inside the block, you can make StaticLibraryProject calls on this object to add configurations.

#### add_configuration ####

Use ```add_configuration(configuration_name, configuration)``` inside of a static library project configuration block to add a build configuration for the library. The ```configuration_name``` parameter expects a symbol that serves as a human-readable name for the configuration. Rake tasks related to this configuration will be namespaced with this symbol. For example, the top-level Rake task for building the "Debug" configuration of "MyLibrary" would be "MyLibrary:Debug". The ```configuration``` parameter expects a hash that contains settings for the configuration.

#### add_api_headers ####

Use ```add_api_headers(api_headers)``` inside of a static library project configuration block--before adding configurations--to set the location(s) of the library's API headers. The ```api_headers``` parameter should be one or more API header paths. For example, ```'include'``` or ```['include', 'plugins']```. Note that the API header paths should be relative to the project folder. API header paths should NOT contain one another. For example, do not do this: ```['include', 'include/things']```. You can have subfolders inside of an API header location, but you should only add the topmost folder.

#### build_framework_package ####

Use ```build_framework_package(configuration_names)``` inside of a static library project configuration block to specify that the library should provide a framework package target. Use ```configuration_names``` to provide a list of configuration names to include in the package. For example, ```'Configuration1'``` or ```['Configuration1', 'Configuration2']```.

##### Static Library Project configuration settings #####

Static Library Project configurations use the same settings as Application Project configurations.

Additionally, Static Library Project configurations offer the following optional settings:

* ```:configuration_headers``` - One or more configuration header paths. For example, ```'config/Debug'``` or ```['config/Debug', 'config/common']```.

### MTBuild::TestApplicationProject ###

Define a Test Application Project with the following DSL method:

```Ruby
test_application_project(application_name, project_folder, &configuration_block)
```

```application_name``` is your desired name for the application. This should be a symbol like ```:MyApplication```. It serves as a human-readable name for the application. Rake tasks related to this application will be namespaced with this symbol. For example, the top-level Rake task for building the "MyTestApplication" application with a configuration called "Debug" would be "MyTestApplication:Debug".

```project_folder``` is the location of the project. Project files should be located at or below this location. Typically, you'd simply pass ```File.dirname(__FILE__)``` to use the same folder as the project's mtbuildfile.

For ```configuration_block```, you supply a block that takes one parameter. When MTBuild invokes the block, it will pass a TestApplicationProject object as this parameter. Inside the block, you can make TestApplicationProject calls on this object to add configurations.

#### add_configuration ####

Use ```add_configuration(configuration_name, configuration)``` inside of a test application project configuration block to add a build configuration for the application. The ```configuration_name``` parameter expects a symbol that serves as a human-readable name for the configuration. Rake tasks related to this configuration will be namespaced with this symbol. For example, the top-level Rake task for building the "Debug" configuration of "MyTestApplication" would be "MyTestApplication:Debug". The ```configuration``` parameter expects a hash that contains settings for the configuration.

##### Test Application Project configuration settings #####

Test Application Project configurations use the same settings as Application Library Project configurations.

### MTBuild::FrameworkProject ###

Define a Framework Project with the following DSL method:

```Ruby
framework_project(framework_name, project_folder, &configuration_block)
```

```framework_name``` is your desired name for the framework. This should be a symbol such as ```:MyApplication```. It serves as a human-readable name for the framework. Rake tasks related to this framework will be namespaced with this symbol. For example, the top-level Rake task for building the "MyLibrary" framework with a configuration called "Debug" would be "MyLibrary:Debug".

```project_folder``` is the location of the project. Project files should be located at or below this location. Typically, you'd simply pass ```File.dirname(__FILE__)``` to use the same folder as the project's mtbuildfile.

For ```configuration_block```, you supply a block that takes one parameter. When MTBuild invokes the block, it will pass an FrameworkProject object as this parameter. Inside the block, you can make FrameworkProject calls on this object to add configurations.

#### add_configuration ####

Use ```add_configuration(configuration_name, configuration)``` inside of a framework project configuration block to add a configuration for the framework. The ```configuration_name``` parameter expects a symbol that serves as a human-readable name for the configuration. Rake tasks related to this configuration will be namespaced with this symbol. For example, the top-level Rake task for building the "Debug" configuration of "MyLibrary" would be "MyLibrary:Debug". The ```configuration``` parameter expects a hash that contains settings for the configuration.

#### add_api_headers ####

Use ```add_api_headers(api_headers)``` inside of a framework project configuration block--before adding configurations--to set the location(s) of the framework's API headers. The ```api_headers``` parameter should be one or more API header paths. For example, ```'include'``` or ```['include', 'plugins']```. Note that the API header paths should be relative to the project folder. API header paths should NOT contain one another. For example, do not do this: ```['include', 'include/things']```. You can have subfolders inside of an API header location, but you should only add the topmost folder.

##### Framework Project configuration settings #####

Framework Project configurations require the following settings:

* ```:objects``` - One or more framework object files. For example, ```'MyLibrary.a'```

Framework Project configurations offer the following optional settings:

* ```:configuration_headers``` - One or more configuration header paths. For example, ```'config/Debug'``` or ```['config/Debug', 'config/common']```.

### MTBuild::Toolchain ###

Define a Toolchain with the following DSL method:

```Ruby
def toolchain(toolchain_name, toolchain_configuration={})
```

```toolchain_name``` is the name of a valid MTBuild toolchain. See following sections for valid toolchain names.

```toolchain_configuration``` expects a hash that contains settings for the toolchain.

##### Toolchain settings #####

All toolchains offer the following optional settings:

* ```:include_paths``` - One or more include folders to use while compiling. For example, ```'include'``` or ```['include', 'include/plugins']```. Note that the paths should be relative to the project folder.

* ```:include_objects``` - One or more object files or libraries to link against. For example, ```'startup.o'``` or ```['startup.o', 'lib3rdParty.a']```.

* ```:library_paths``` - One or more library paths to search when linking. For example, ```'FancyLibrary/lib'``` or ```['FancyLibrary/lib', 'SuperFancyLibrary/lib']```. Note that the paths should be relative to the project folder.


### MTBuild::ToolchainGcc ###

Define a gcc toolchain by passing ```:gcc``` as the ```toolchain_name``` when invoking the ```toolchain()``` method.

##### ToolchainGcc settings #####

On top of the base Toolchain settings, the ToolchainGcc toolchain offers the following optional settings:

* ```:cppflags``` - A string or array of strings representing C Preprocessor flags to be used in all compilation and link steps

* ```:cflags``` - A string or array of strings representing C flags to be used when compiling C files

* ```:cxxflags``` - A string or array of strings representing C++ flags to be used when compiling C++ files

* ```:asflags``` - A string or array of strings representing assembler flags to be used when assembling assembly files

* ```:ldflags``` - A string or array of strings representing linker flags to be used when linking

* ```:linker_script``` - A linker script file to be used when linking


### MTBuild::ToolchainArmNoneEabiGcc ###

Define an arm-none-eabi-gcc toolchain by passing ```:arm_none_eabi_gcc``` as the ```toolchain_name``` when invoking the ```toolchain()``` method.

##### ToolchainArmNoneEabiGcc settings #####

The ToolchainArmNoneEabiGcc toolchain uses the same settings as the ToolchainGcc toolchain.
