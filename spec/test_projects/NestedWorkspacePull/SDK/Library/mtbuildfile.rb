static_library_project :Library, File.dirname(__FILE__) do |lib|

  lib.add_api_headers 'include'

  lib.add_configuration :Cfg1,
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DCfg1'],
      include_paths: ['src']
    )
end
