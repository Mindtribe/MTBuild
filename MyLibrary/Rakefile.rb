static_library_project :MyLibrary do |lib|

	current_folder = File.dirname(__FILE__)

	lib.add_configuration :Kira,
		project_folder: current_folder,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cpu: 'cortex-m4'
		)

	lib.add_configuration :Tiva_Launchpad,
		project_folder: current_folder,
		sources: ['src/**/*.c'],
		api_headers: 'include',
		toolchain: arm_none_eabi_gcc(
			cpu: 'cortex-m4'
		)
end
