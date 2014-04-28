application_project :App do |app|

	current_folder = File.dirname(__FILE__)

	app.add_configuration :Kira,
		project_folder: current_folder,
		sources: ['src/main.c', 'src/startup_gcc.c', 'src/hardware-Kira.c'],
		toolchain: arm_none_eabi_gcc(
			cpu: 'cortex-m4',
			linker_script: 'src/LinkerFile-Kira.ld'),
		dependencies: [
			'MyLibrary:Kira'
		]

	app.add_configuration :Tiva_Launchpad,
		project_folder: current_folder,
		sources: ['src/main.c', 'src/startup_gcc.c', 'src/hardware-Launchpad.c'],
		toolchain: arm_none_eabi_gcc(
			cpu: 'cortex-m4',
			linker_script: 'LinkerFile-Launchpad.ld'),
		dependencies: [
			'MyLibrary:Tiva_Launchpad'
		]
end

task :all => ['App1:Kira', 'App1:Tiva_Launchpad']
