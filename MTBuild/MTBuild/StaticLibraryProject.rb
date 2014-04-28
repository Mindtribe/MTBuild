require 'MTBuild/Project'
require 'MTBuild/Utils'

module MTBuild

  require 'rake/clean'

	class StaticLibraryProject < Project

    private

    def create_configuration_tasks(configuration_name, configuration)
      super
      output_folder = File.join(MTBuild.build_folder,@name.to_s,configuration_name.to_s)
      link_prerequisites = create_compile_tasks(configuration[:project_folder], configuration.fetch(:sources, []), output_folder)
      library_prerequisites = create_link_tasks(link_prerequisites, output_folder)
      new_task = static_library_task configuration_name => library_prerequisites do |t|
        puts "built #{t.name}."
      end
      new_task.api_headers = configuration.fetch(:api_headers, nil)
      new_task.library_binary = configuration.fetch(:library_binary, @name)
    end

    def create_compile_tasks(project_folder, sources, output_folder)
      link_prerequisites = []

      files = []

      sources = [sources] if sources.is_a?(String)
      sources.each do |source|
        files += FileList[File.join(project_folder,source)].to_a
      end

      files.each do |source|
        relative_source_location = Utils::path_difference(project_folder, File.dirname(source))
        fail "Source file #{source} must be within #{project_folder}." if relative_source_location.nil?
        object_file = File.join(output_folder, relative_source_location, source.pathmap('%n.o'))
        dependency_file = File.join(output_folder, relative_source_location, source.pathmap('%n.d'))

        link_prerequisites << object_file
        CLEAN.include(object_file)
        CLEAN.include(dependency_file)

        file object_file => [source] do |t|
          puts "#{t.name}"
          #sh "~/MTTools/OSX/bin/arm-none-eabi-gcc #{t.prerequisites.join(' ')} -I#{includeFolders.join(' -I')} -MMD -c -o #{t.name}"
        end
        Rake::MakefileLoader.new.load(dependency_file) if File.file?(dependency_file)
      end
      return link_prerequisites
    end

    def create_link_tasks(prerequisites, output_folder)
      library_file = File.join(output_folder, "#{@name}.a")

      CLEAN.include(library_file)

      file library_file => prerequisites do |t|
        puts "#{t.name}"
        #sh "~/MTTools/OSX/bin/arm-none-eabi-gcc #{t.prerequisites.join(' ')} -I#{includeFolders.join(' -I')} -MMD -c -o #{t.name}"
      end
      return library_file
    end

	end

end
