workspace :ExampleSDK, File.dirname(__FILE__) do |w|

  w.set_configuration_defaults :Configuration1,
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: ['-Dgcc'],
      cflags: ['-std=c99', '-mcpu=cortex-m4', '-mthumb', '-mlittle-endian', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard', '-ffunction-sections', '-fdata-sections', '-Wall', '-Werror', '-Wextra', '-pedantic-errors'],
      cxxflags: ['-std=c++03', '-mcpu=cortex-m4', '-mthumb', '-mlittle-endian', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard', '-ffunction-sections', '-fdata-sections', '-Wall', '-Werror', '-Wextra', '-pedantic-errors'],
      ldflags: ['-Wl,--entry,ResetISR', '-Wl,--gc-sections']
    )

  w.set_configuration_defaults :Configuration2,
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: ['-Dgcc'],
      cflags: ['-std=c99', '-mcpu=cortex-m4', '-mthumb', '-mlittle-endian', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard', '-ffunction-sections', '-fdata-sections', '-Wall', '-Werror', '-Wextra', '-pedantic-errors'],
      cxxflags: ['-std=c++03', '-mcpu=cortex-m4', '-mthumb', '-mlittle-endian', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard', '-ffunction-sections', '-fdata-sections', '-Wall', '-Werror', '-Wextra', '-pedantic-errors'],
      ldflags: ['-Wl,--entry,ResetISR', '-Wl,--gc-sections']
    )

  w.set_configuration_defaults :Test,
    toolchain: toolchain(:gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-Wall -Werror -Wextra -pedantic-errors',
    )

  w.add_project('ExampleLibrary')
  w.add_project('ExampleLibraryTest')
end
