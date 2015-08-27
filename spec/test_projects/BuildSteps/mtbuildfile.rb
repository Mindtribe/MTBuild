application_project :App1, File.dirname(__FILE__) do |app|
  app.add_configuration :Cfg1,
    sources: ['src/*.c'],
    toolchain: toolchain(:gcc,
      cppflags: [],
      cflags: ['-std=c99', '-Wall', '-Werror', '-Wextra'],
      cxxflags: ['-Wall', '-Werror', '-Wextra']
    ),
    pre_build: lambda {puts 'pre-build step!'},
    post_build: lambda {post_build_step}
end

def post_build_step
  puts 'post-build step!'
end
