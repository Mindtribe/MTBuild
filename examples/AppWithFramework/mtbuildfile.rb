workspace :AppsWithLibrary, File.dirname(__FILE__) do |w|
  w.add_project('ExampleLibrary')
  w.add_project('ExampleApp')

  w.add_default_tasks(['ExampleApp:Configuration1', 'ExampleApp:Configuration2'])
end

