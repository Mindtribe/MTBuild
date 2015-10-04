app1 = application_project :App1, File.dirname(__FILE__) do |app|

  app.set_default_configuration(
    sources: ['main.c'],
    toolchain: toolchain(:gcc,
      cppflags: ['-DHappyApp'],
    ),
    dependencies: [
      'SDK:Library:*'
    ]
  )

end

MTBuild::Workspace.add_default_tasks(app1.tasks_for_all_configurations)
