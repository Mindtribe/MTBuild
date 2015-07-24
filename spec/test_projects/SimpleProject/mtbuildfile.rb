application_project :App1, File.dirname(__FILE__) do |app|

  app.add_configuration :Cfg1,
    sources: ['src/*.c'],
    toolchain: toolchain(:gcc,
      cppflags: [],
      cflags: ['-std=c99', '-Wall', '-Werror', '-Wextra'],
      cxxflags: ['-Wall', '-Werror', '-Wextra']
    )

end
