workspace :Workspace, File.dirname(__FILE__) do |w|

  w.set_configuration_defaults :Cfg1,
    toolchain: toolchain(:gcc,
      cppflags: [],
      cflags: ['-std=c99', '-Wall', '-Werror', '-Wextra'],
      cxxflags: ['-Wall', '-Werror', '-Wextra']
    )

  app = application_project :App1, File.dirname(__FILE__) do |app|
    app.add_configuration :Cfg1,
      sources: ['src/*.c']
  end

  MTBuild::Workspace.add_default_tasks(app.task_for_configuration('Cfg1'))

end
