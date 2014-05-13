module MTBuild

  module DSL

    def workspace(workspace_name, workspace_folder, &configuration_block)
      MTBuild::Workspace.new(workspace_name, workspace_folder, &configuration_block)
    end

    def application_project(application_name, project_folder, &configuration_block)
      MTBuild::ApplicationProject.new(application_name, project_folder, &configuration_block)
    end

    def static_library_project(library_name, project_folder, &configuration_block)
      MTBuild::StaticLibraryProject.new(library_name, project_folder, &configuration_block)
    end

    def test_application_project(application_name, project_folder, &configuration_block)
      MTBuild::TestApplicationProject.new(application_name, project_folder, &configuration_block)
    end

    def toolchain(toolchain_name, toolchain_configuration={})
      fail "error: the toolchain configuration is expected to be a hash." unless toolchain_configuration.is_a? Hash
      toolchain_configuration[:name] = toolchain_name
      return toolchain_configuration
    end

    def versioner(versioner_name, versioner_configuration={})
      fail "error: the version file configuration is expected to be a hash." unless versioner_configuration.is_a? Hash
      versioner_configuration[:name] = versioner_name
      return versioner_configuration
    end

  end

end

# Extend the main object with the DSL commands. This allows top-level
# calls to task, etc. to work from a Rakefile without polluting the
# object inheritance tree.
self.extend MTBuild::DSL
