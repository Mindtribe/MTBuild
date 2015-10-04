static_library_project :Library, File.dirname(__FILE__) do |lib|

  lib.add_api_headers 'include'

  lib.set_default_configuration(
    sources: ['src/**/*.c'],
    toolchain: toolchain(:gcc,
      #inherits flags from workspace, but adds to cppflags
      cppflags: ['-DHappyLib'],
      include_paths: ['src']
    )
  )

end
