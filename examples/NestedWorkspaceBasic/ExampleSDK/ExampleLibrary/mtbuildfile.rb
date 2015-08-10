static_library_project :ExampleLibrary, File.dirname(__FILE__) do |lib|

  lib.add_api_headers 'include'

  lib.add_configuration :Configuration1,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DConfig1'],
      include_paths: ['src']
    ),
    tests: [
      'ExampleLibraryTest:Test'
    ]

  lib.add_configuration :Configuration2,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DConfig2'],
      include_paths: ['src']
    ),
    tests: [
      'ExampleLibraryTest:Test'
    ]

  lib.add_configuration :Test,
    sources: ['src/**/*.c']
end
