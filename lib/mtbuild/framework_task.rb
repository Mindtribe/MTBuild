module Rake

  require 'rake'

  # This is a top-level Rake task for loading a framework
  class FrameworkTask < Task

    # API header location for the framework
    attr_accessor :api_headers

    # Configuration header location for the framework
    attr_accessor :configuration_headers

    # The framework objects
    attr_accessor :library_files

    def initialize(task_name, app)
      super
      @api_headers = []
      @configuration_headers = []
      @library_files = []
    end

  end

  module DSL

    # DSL method to create a framework task.
    def framework_task(*args, &block)
      new_task = Rake::FrameworkTask.define_task(*args, &block)
    end

  end

end
