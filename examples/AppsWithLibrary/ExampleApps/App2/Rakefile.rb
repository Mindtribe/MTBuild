application_project :App2 do |app|

	current_folder = File.dirname(__FILE__)

	app.add_configuration :Configuration1,
		project_folder: current_folder,
		sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration1.c'],
		toolchain: arm_none_eabi_gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections',
			linker_script: 'LinkerFile-Configuration1.ld'
		),
		dependencies: [
			'ExampleLibrary:Configuration1'
		]

	app.add_configuration :Configuration2,
		project_folder: current_folder,
		sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration2.c'],
		toolchain: arm_none_eabi_gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			ldflags: '-Wl,--entry,ResetISR -Wl,--gc-sections',
			linker_script: 'LinkerFile-Configuration2.ld'
		),
		dependencies: [
			'ExampleLibrary:Configuration2'
		]

end

task :all => ['App2:Configuration1', 'App2:Configuration2']
