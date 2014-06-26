module MTBuild
  require "mtbuild/staticlibrary_configuration"
  require 'mtbuild/organized_package_task'
  require 'mtbuild/project'

  # This class is used to build static libraries. A static library has
  # compilation and archival phases that produce a binary library package.
  class StaticLibraryProject < Project

    def initialize(project_name, project_folder, &configuration_block)
      @framework_configurations = []
      @api_headers = []
      super
      if @framework_configurations.count > 0
        configure_framework_tasks
      end
    end

    # Adds a named static library configuration to the project.
    def add_configuration(configuration_name, configuration)
      super
      default_configuration = Workspace.configuration_defaults.fetch(configuration_name, {})
      merged_configuration = Utils.merge_configurations(default_configuration, configuration)
      cfg = StaticLibraryConfiguration.new(@project_name, @project_folder, effective_output_folder, configuration_name, merged_configuration, @api_headers)
      @configurations << cfg
      return cfg
    end

    # Provides a framework package target that builds a framework package with the specified configurations
    def build_framework_package(configuration_names)
      @framework_configurations += Utils.ensure_array(configuration_names)
    end

    # Specifies API header locations
    def add_api_headers(api_headers)
      @api_headers += Utils.expand_folder_list(api_headers, @project_folder)
    end

    private

    def configure_framework_tasks
      namespace @project_name do
        framework_task = OrganizedPackageTask.new("#{@project_name}", :noversion) do |t|
          t.need_tar_gz = true
          t.add_folders_to_folder("Headers", @api_headers)
          @framework_configurations.each do |framework_configuration|
            configuration_name = "#{@project_name}:#{framework_configuration}"
            configuration_task = Rake.application.lookup(configuration_name)
            fail "Unable to locate configuration: #{configuration_name}" if configuration_task.nil?
            fail "Configuration is not a library configuration: #{configuration_name}" unless configuration_task.respond_to? :library_files and configuration_task.respond_to? :configuration_headers

            t.add_files_to_folder("Libraries/#{framework_configuration}", configuration_task.library_files)
            t.add_folders_to_folder("Config/#{framework_configuration}", configuration_task.configuration_headers) unless configuration_task.configuration_headers.empty?
          end
        end

        framework_rakefile = File.join(framework_task.package_dir_path, "Rakefile.rb")
        file framework_rakefile do |f|
          fdir = File.dirname(framework_rakefile)
          mkdir_p(fdir) unless File.exist?(fdir)

          File.open(framework_rakefile, 'w') do |f|
            f.puts("framework_project :#{@project_name}, File.dirname(__FILE__) do |lib|")
            f.puts("  lib.add_api_headers 'Headers'")
            @framework_configurations.each do |framework_configuration|
              configuration_name = "#{@project_name}:#{framework_configuration}"
              configuration_task = Rake.application.lookup(configuration_name)
              f.puts("  lib.add_configuration :#{framework_configuration},")
              f.puts("    configuration_headers: ['Config/#{framework_configuration}'],") unless configuration_task.configuration_headers.empty?
              f.puts("    objects: ['Libraries/#{framework_configuration}/*']")
            end
            f.puts("end")
          end
        end

        @framework_configurations.each do |framework_configuration|
          Rake::Task[:"#{@project_name}:package"].prerequisites.insert(0, :"#{@project_name}:#{framework_configuration}")
          Rake::Task[:"#{@project_name}:package"].prerequisites.insert(0, framework_rakefile)
        end

      end
    end

  end

end
