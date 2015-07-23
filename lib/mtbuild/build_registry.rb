module MTBuild

  # This class holds the mtbuild workspace hierarchy
  class BuildRegistry

    @workspaces = {}
    @projects = {}
    @top_workspace = nil
    @active_workspace = nil
    @last_active_workspace = nil

    @expecting=:project_or_workspace

    class << self

      # The map of registered workspaces
      attr_reader :workspaces

      # The map of registered projects
      attr_reader :projects

      # The top-level workspace
      attr_reader :top_workspace

      # The last active workspace
      attr_reader :last_active_workspace

      # Track the beginning of a new workspace's creation
      def enter_workspace(workspace_name, workspace)
        workspace_name = self.hierarchical_name(workspace_name)
        self.found_workspace(workspace_name)
        fail "A workspace named #{workspace_name} was already added." if @workspaces.has_key?(workspace_name)
        @workspaces[workspace_name] = workspace
        @top_workspace = workspace if @top_workspace.nil?
        parent = @active_workspace
        @active_workspace = @last_active_workspace = workspace
        return workspace_name, parent
      end

      # Track the completion of a new workspace's creation
      def exit_workspace
        @active_workspace = @active_workspace.parent_workspace
      end

      # Track the beginning of a new project's creation
      def enter_project(project_name, project)
        project_name = self.hierarchical_name(project_name)
        self.found_project(project_name)
        fail "A project named #{project_name} was already added." if @projects.has_key?(project_name)
        @projects[project_name] = project
        return project_name, @last_active_workspace
      end

      # Track the completion of a new project's creation
      def exit_project
      end

      # Register that we next expect to encounter a workspace, not a project
      def expect_workspace
        # We expect an explicitly-added workspace.
        @expecting=:added_workspace
      end

      # Register that we next expect to encounter a project, not a workspace
      def expect_project
        # We expect an explicitly-added project.
        @expecting=:added_project
      end

      # Register that we encountered a workspace and verify that it's allowed
      def found_workspace(workspace_name)
        unless [:project_or_workspace, :added_workspace].include? @expecting
          fail "#{workspace_name} was added with add_project(), but it contains a workspace. Use add_workspace() if you want to include it." if @expect==:added_project
          fail "Encountered workspace #{workspace_name} declared after a project or another workspace in the same file. This isn't allowed."
        end
        # We expect nothing but top-level projects now.
        @expect=:project
      end

      # Register that we encountered a project and verify that it's allowed
      def found_project(project_name)
        unless [:project_or_workspace, :project, :added_project].include? @expecting
          fail "#{project_name} was added with add_workspace(), but it contains a project. Use add_project() if you want to include it." if @expect==:added_workspace
        end
        # We expect nothing but top-level projects now.
        @expect=:project
      end

      # Get a workspace/project name that reflects the workspace/project hierarchy
      def hierarchical_name(name)
        return name if @last_active_workspace.nil?
        "#{@last_active_workspace.workspace_name}:#{name}"
      end

    end

  end

end
