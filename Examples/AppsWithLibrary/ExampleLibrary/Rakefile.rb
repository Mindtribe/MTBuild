static_library_project :ExampleLibrary do |lib|

	current_folder = File.dirname(__FILE__)

	lib.add_configuration :Configuration1,
		project_folder: current_folder,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cpu: 'cortex-m4'
		)

	lib.add_configuration :Configuration2,
		project_folder: current_folder,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cpu: 'cortex-m4'
		)
end
