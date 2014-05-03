static_library_project :ExampleLibrary, File.dirname(__FILE__) do |lib|

	lib.add_configuration :Configuration1,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			include_paths: ['src']
		)

	lib.add_configuration :Configuration2,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cppflags: "-Dgcc",
			cflags: '-std=c99 -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			cxxflags: '-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -Wall -Werror -Wextra -pedantic-errors',
			include_paths: ['src']
		)
end
