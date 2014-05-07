workspace :AppsWithLibrary, File.dirname(__FILE__) do |w|

  w.set_configuration_defaults :Configuration1,
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-std=c++03 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections'
    )

  w.set_configuration_defaults :Test,
    toolchain: toolchain(:gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-Wall -Werror -Wextra -pedantic-errors',
    )

end

static_library_project :ExampleLibrary, File.dirname(__FILE__) do |lib|

  lib.add_configuration :Configuration1,
    sources: ['src/**/*.c'],
    api_headers: 'include',
    toolchain: toolchain(:arm_none_eabi_gcc,
      include_paths: ['src']
    ),
    tests: [
      'ExampleLibraryTest:Test'
    ]

  lib.add_configuration :Test,
    sources: ['src/**/*.c'],
    api_headers: 'include'
end

test_application_project :ExampleLibraryTest, File.dirname(__FILE__) do |app|

  app.add_configuration :Test,
    sources: ['src/**/*.cpp'],
    dependencies: [
      'ExampleLibrary:Test'
    ]
end
