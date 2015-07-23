module MTBuild

  require 'mtbuild/versioner'

  # This is the base class for all configuration types.
  class Configuration

    # The configuration's name
    attr_reader :configuration_name

    # The project that owns this configuration
    attr_reader :parent_project

    # The project's folder. Relative path references are interpreted as
    # relative to this folder.
    attr_reader :project_folder

    # The project's output folder. Project output goes here.
    attr_reader :output_folder

    def initialize(parent_project, output_folder, configuration_name, configuration)
      @parent_project = parent_project
      @project_folder = File.expand_path(@parent_project.project_folder)
      @configuration_name = configuration_name
      @output_folder = File.expand_path(File.join(output_folder, @configuration_name.to_s))
      check_configuration(configuration)

      @versioner = nil
      @versioner_config = configuration.fetch(:versioner, nil)
      @versioner = Versioner.create_versioner(@parent_project.project_name, @project_folder, @output_folder, @configuration_name, @versioner_config) unless @versioner_config.nil?
    end

    # Create the actual Rake tasks that will perform the configuration's work
    def configure_tasks
      @versioner.create_version_tasks unless @versioner.nil?
    end

    private

    def check_configuration(configuration)
    end

    def namespace_tasks(task_list)
      return task_list.collect {|task| "#{@parent_project.parent_workspace.workspace_name}:#{task}"} unless @parent_project.parent_workspace.nil?
      return task_list
    end

    include Rake::DSL
  end

end
