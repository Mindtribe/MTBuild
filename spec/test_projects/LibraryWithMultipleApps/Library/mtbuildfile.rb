static_library_project :Library, File.dirname(__FILE__) do |lib|

  lib.add_api_headers 'include'

  lib.add_configuration :Cfg1,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DCfg1'],
      include_paths: ['src']
    ),
    tests: [
      'LibraryTest:Test'
    ]

  lib.add_configuration :Cfg2,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DCfg2'],
      include_paths: ['src']
    ),
    tests: [
      'LibraryTest:Test'
    ]

  lib.add_configuration :Test,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc,
      cppflags: ['-Dgcc'],
      cflags: ['-std=c99', '-Wall', '-Werror', '-Wextra'],
      cxxflags: ['-Wall', '-Werror', '-Wextra'],
      include_paths: ['src']
    )

  lib.build_framework_package([:Cfg1, :Cfg2])
end

test_application_project :LibraryTest, File.dirname(__FILE__) do |app|

  app.add_configuration :Test,
    sources: ['src/**/*.cpp'],
    toolchain: toolchain(:gcc,
      cppflags: ['-Dgcc'],
      cflags: ['-std=c99', '-Wall', '-Werror', '-Wextra'],
      cxxflags: ['-Wall', '-Werror', '-Wextra'],
      include_paths: ['src']
    ),
    dependencies: [
      'Library:Test'
    ]

end
