module MTBuild

  class Versioner

    def initialize(project_name, project_folder, output_folder, configuration_name, configuration)
      @project_name = project_name
      @project_folder = project_folder
      @output_folder = output_folder
      @configuration_name = configuration_name

      check_configuration(configuration)

      @versioner_name = configuration[:name]
    end

    def create_version_tasks
      fail "Versioner didn't provide create_version_tasks"
    end

    private

    def check_configuration(configuration)
      fail "error. No name specified for versioner in #{@project_name}:#{@configuration_name}" if configuration.fetch(:name, nil).nil?
    end

    @registered_versioners = {}

    def self.register_versioner(versioner_name, versioner_class)
      @registered_versioners[versioner_name] = versioner_class;
    end

    def self.create_versioner(project_name, project_folder, output_folder, configuration_name, versioner_configuration)
      versioner_name = versioner_configuration.fetch(:name, nil)
      fail "error: versioner name not specified for #{project_name}:#{configuration_name}." if versioner_name.nil?

      versioner_class = @registered_versioners.fetch(versioner_name, nil)
      if !versioner_class
        versioner = File.join('mtbuild', 'versioners', versioner_name.to_s)
        begin
          require versioner
        rescue LoadError
        end
      end
      versioner_class = @registered_versioners.fetch(versioner_name, nil)
      fail "error: version file #{versioner_name} could not be found." if versioner_class.nil?
      return Object::const_get(versioner_class).new(project_name, project_folder, output_folder, configuration_name, versioner_configuration)
    end

    include Rake::DSL
  end

end
