app1 = application_project :App1, File.dirname(__FILE__) do |app|

  cfg1 = app.add_configuration :Cfg1,
    sources: ['main.c'],
    dependencies: [
      'Library:Cfg1'
    ]

  cfg2 = app.add_configuration :Cfg2,
    sources: ['main.c'],
    dependencies: [
      'Library:Cfg2'
    ]
end

MTBuild::Workspace.add_default_tasks(
    [app1.task_for_configuration('Cfg1'),
     app1.task_for_configuration('Cfg2')]
)
