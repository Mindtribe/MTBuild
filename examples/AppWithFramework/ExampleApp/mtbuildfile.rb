example_app = application_project :ExampleApp, File.dirname(__FILE__) do |app|

  cfg1 = app.add_configuration :Configuration1,
    sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration1.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-std=c++03 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections',
      linker_script: 'LinkerFile-Configuration1.ld'
    ),
    dependencies: [
      'ExampleLibrary:Configuration1'
    ]

  cfg1.add_sources 'special.c', toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c89 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors'
    )

  cfg2 = app.add_configuration :Configuration2,
    sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration2.c'],
    toolchain: toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      cxxflags: '-std=c++03 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
      ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections',
      linker_script: 'LinkerFile-Configuration2.ld'
    ),
    dependencies: [
      'ExampleLibrary:Configuration2'
    ]

  cfg2.add_sources 'special.c', toolchain(:arm_none_eabi_gcc,
      cppflags: "-Dgcc",
      cflags: '-std=c89 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors'
    )

end

MTBuild::Workspace.add_default_tasks(
    [example_app.task_for_configuration('Configuration1'),
     example_app.task_for_configuration('Configuration2')]
)
