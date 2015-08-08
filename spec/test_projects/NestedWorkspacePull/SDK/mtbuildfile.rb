workspace :SDK, File.dirname(__FILE__) do |w|

  w.set_configuration_defaults :Cfg1,
    toolchain: toolchain(:gcc,
      cppflags: [],
      cflags: ['-std=c99', '-Wall', '-Werror', '-Wextra'],
      cxxflags: ['-Wall', '-Werror', '-Wextra']
    )

  w.add_project('Library')
end
