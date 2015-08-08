workspace :NestedWorkspacePull, File.dirname(__FILE__) do |w|

  w.add_workspace('SDK', pull_configurations: [:Cfg1])
  w.add_project('App')
end
