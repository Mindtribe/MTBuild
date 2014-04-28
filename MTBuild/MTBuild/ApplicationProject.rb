require 'MTBuild/Project'

module MTBuild

	class ApplicationProject < Project

    include Rake::DSL

    private

    def create_configuration_tasks(configuration_name, configuration)
      super
      link_prerequisites = create_compile_tasks(configuration[:folder], configuration.fetch(:sources, []))

      task configuration_name => configuration[:dependencies] do |t|
        puts "built #{t.name}."
      end
    end

    def create_compile_tasks(sources_folder, sources)
      link_prerequisites = []

      sources.each do |source|
        object_file = source.pathmap '%X.o'
        dependency_file = source.pathmap '%X.d'

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

	end

end
