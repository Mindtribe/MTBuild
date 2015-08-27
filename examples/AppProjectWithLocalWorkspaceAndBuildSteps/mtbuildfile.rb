workspace :AppPrpjectWithLocalWorkspaceAndBuildSteps, File.dirname(__FILE__) do |w|

  w.set_configuration_defaults :Configuration1,
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-std=c++03 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections'
    )

  w.add_default_tasks('App1:Configuration1')

end

application_project :App1, File.dirname(__FILE__) do |app|

  app.add_configuration :Configuration1,
    sources: ['src/*.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      linker_script: 'src/LinkerFile-Configuration1.ld'
    ),
    versioner: versioner(:mt_std_version,
      files: 'src/version.h'
    ),
    pre_build: lambda {puts 'pre-build step!'},
    post_build: lambda {my_post_build_step}

end

# demonstrates using a function as a build step
def my_post_build_step
  puts 'post-build step!'
end
