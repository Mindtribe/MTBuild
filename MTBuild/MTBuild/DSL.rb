module MTBuild

  module DSL

    def application_project(application_name, &configuration_block)
      MTBuild::ApplicationProject.new(application_name, &configuration_block)
    end

    def static_library_project(library_name, &configuration_block)
      MTBuild::StaticLibraryProject.new(library_name, &configuration_block)
    end

  end

end

# Extend the main object with the DSL commands. This allows top-level
# calls to task, etc. to work from a Rakefile without polluting the
# object inheritance tree.
self.extend MTBuild::DSL
