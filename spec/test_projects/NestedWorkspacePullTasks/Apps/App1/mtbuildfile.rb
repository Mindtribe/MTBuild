app1 = application_project :App1, File.dirname(__FILE__) do |app|

  cfg1 = app.add_configuration :Cfg1,
    sources: ['main.c']

end

MTBuild::Workspace.add_default_tasks(app1.task_for_configuration('Cfg1'))
