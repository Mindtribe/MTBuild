application_project :App1 do |app|

	current_folder = File.dirname(__FILE__)

	app.add_configuration :Configuration1,
		project_folder: current_folder,
		sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration1.c'],
		toolchain: arm_none_eabi_gcc(
			cflags: {
				cpu: 'cortex_m4',
				mode: :thumb,
				endianness: :little_endian,
				fpu: 'fpv4_sp_d16',
				float_abi: :hard
			},
			ldflags: {
				entry: 'ResetISR',
				linker_script: 'LinkerFile-Configuration1.ld'
			}
		),
		dependencies: [
			'ExampleLibrary:Configuration1'
		]

	app.add_configuration :Configuration2,
		project_folder: current_folder,
		sources: ['main.c', 'startup_gcc.c', 'hardware-Configuration2.c'],
		toolchain: arm_none_eabi_gcc(
			cflags: {
				cpu: 'cortex_m4',
				mode: :thumb,
				endianness: :little_endian,
				fpu: 'fpv4_sp_d16',
				float_abi: :hard
			},
			ldflags: {
				entry: 'ResetISR',
				linker_script: 'LinkerFile-Configuration2.ld'
			}
		),
		dependencies: [
			'ExampleLibrary:Configuration2'
		]
end

task :all => ['App1:Configuration1', 'App1:Configuration2']
