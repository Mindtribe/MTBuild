workspace :AppPrpjectWithLocalWorkspaceAndBuildSteps, File.dirname(__FILE__) do |w|

  VERSION_MAJOR=ENV.fetch('VERSION_MAJOR', '0')
  VERSION_MINOR=ENV.fetch('VERSION_MINOR', '0')
  VERSION_PATCH=ENV.fetch('VERSION_PATCH', '0')
  VERSION_BUILD=ENV.fetch('VERSION_BUILD', '0')

  w.set_configuration_defaults :Configuration1,
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: ['-Dgcc', "-DVERSION_MAJOR=%s"%VERSION_MAJOR, "-DVERSION_MINOR=%s"%VERSION_MINOR, "-DVERSION_PATCH=%s"%VERSION_PATCH, "-DVERSION_BUILD=%s"%VERSION_BUILD],
      cflags: ['-std=c99', '-mcpu=cortex-m4', '-mthumb', '-mlittle-endian', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard', '-ffunction-sections', '-fdata-sections', '-Wall', '-Werror', '-Wextra', '-pedantic-errors'],
      cxxflags: ['-std=c++03', '-mcpu=cortex-m4', '-mthumb', '-mlittle-endian', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard', '-ffunction-sections', '-fdata-sections', '-Wall', '-Werror', '-Wextra', '-pedantic-errors'],
      ldflags: ['-Wl,--entry,ResetISR', '-Wl,--gc-sections']
    )

  application_project :App1, File.dirname(__FILE__) do |app|

    app.add_configuration :Configuration1,
                          sources: ['src/*.c'],
                          toolchain: toolchain(:arm_none_eabi_gcc,
                                               linker_script: 'src/LinkerFile-Configuration1.ld'
                          )
  end

  w.add_default_tasks('App1:Configuration1')

end
