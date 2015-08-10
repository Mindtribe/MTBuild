workspace :NestedWorkspacePullTasks, File.dirname(__FILE__) do |w|
  w.add_workspace('Apps', pull_default_tasks: true)
end
