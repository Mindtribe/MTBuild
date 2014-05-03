static_library_project :ExampleLibrary, File.dirname(__FILE__) do |lib|

	lib.add_configuration :Configuration1,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			include_paths: ['src']
		),
		dependencies: [
			'ExampleLibraryTest:Test'
		]

	lib.add_configuration :Configuration2,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			include_paths: ['src']
		),
		dependencies: [
			'ExampleLibraryTest:Test'
		]

	lib.add_configuration :Test,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-Wall -Werror -Wextra -pedantic-errors',
			include_paths: ['src']
		)

end

test_application_project :ExampleLibraryTest, File.dirname(__FILE__) do |app|

	app.add_configuration :Test,
		sources: ['src/**/*.cpp'],
		toolchain: gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-Wall -Werror -Wextra -pedantic-errors',
			include_paths: ['src']
		),
		dependencies: [
			'ExampleLibrary:Test'
		]

end
