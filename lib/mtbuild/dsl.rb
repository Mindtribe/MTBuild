module MTBuild

  module DSL

    # Defines a Workspace
    def workspace(workspace_name, workspace_folder, &configuration_block)
      MTBuild::Workspace.new(workspace_name, workspace_folder, &configuration_block)
    end

    # Defines an ApplicationProject
    def application_project(application_name, project_folder, &configuration_block)
      MTBuild::ApplicationProject.new(application_name, project_folder, &configuration_block)
    end

    # Defines a FrameworkProject
    def framework_project(framework_name, project_folder, &configuration_block)
      MTBuild::FrameworkProject.new(framework_name, project_folder, &configuration_block)
    end

    # Defines a StaticLibraryProject
    def static_library_project(library_name, project_folder, &configuration_block)
      MTBuild::StaticLibraryProject.new(library_name, project_folder, &configuration_block)
    end

    # Defines a TestApplicationProject
    def test_application_project(application_name, project_folder, &configuration_block)
      MTBuild::TestApplicationProject.new(application_name, project_folder, &configuration_block)
    end

    # Defines a Toolchain
    def toolchain(toolchain_name, toolchain_configuration={})
      fail "error: the toolchain configuration is expected to be a hash." unless toolchain_configuration.is_a? Hash
      toolchain_configuration[:name] = toolchain_name
      return toolchain_configuration
    end

    # Defines a Versioner
    def versioner(versioner_name, versioner_configuration={})
      fail "error: the version file configuration is expected to be a hash." unless versioner_configuration.is_a? Hash
      versioner_configuration[:name] = versioner_name
      return versioner_configuration
    end

    # Declare an MT file task.
    #
    # Example:
    #   mtfile "config.cfg" => ["config.template"] do
    #     open("config.cfg", "w") do |outfile|
    #       open("config.template") do |infile|
    #         while line = infile.gets
    #           outfile.puts line
    #         end
    #       end
    #     end
    #  end
    #
    def mtfile(*args, &block)
      MTBuild::MTFileTask.define_task(*args, &block)
    end

  end

end

# Extend the main object with the DSL commands. This allows top-level calls to
# workspace, application_project, etc. to work from a Rakefile without
# polluting the object inheritance tree.
self.extend MTBuild::DSL
