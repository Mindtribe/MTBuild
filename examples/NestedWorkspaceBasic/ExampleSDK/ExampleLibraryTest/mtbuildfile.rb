test_application_project :ExampleLibraryTest, File.dirname(__FILE__) do |app|

  app.add_configuration :Test,
    sources: ['src/**/*.cpp'],
    dependencies: [
      'ExampleLibrary:Test'
    ]
end
