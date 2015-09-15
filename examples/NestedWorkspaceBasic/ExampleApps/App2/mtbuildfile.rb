app2 = application_project :App2, File.dirname(__FILE__) do |app|

  app.add_configuration :Configuration1,
    sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration1.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DConfig1'],
      linker_script: 'LinkerFile-Configuration1.ld',
      include_paths: ['src']
    ),
    dependencies: [
      'ExampleSDK:ExampleLibrary:Configuration1'
    ]

  app.add_configuration :Configuration2,
    sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration2.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DConfig2'],
      linker_script: 'LinkerFile-Configuration2.ld',
      include_paths: ['src']
    ),
    dependencies: [
      'ExampleSDK:ExampleLibrary:Configuration2'
    ]

end

MTBuild::Workspace.add_default_tasks(
    [app2.task_for_configuration(:Configuration1),
     app2.task_for_configuration(:Configuration2)]
)
