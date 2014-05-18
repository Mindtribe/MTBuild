module Rake

  require 'rake'

  # This is a top-level Rake task for creating a static library
  class StaticLibraryTask < Task

    # API header location for the static library
    attr_accessor :api_headers

    # The static library output file(s)
    attr_accessor :library_files

    def initialize(task_name, app)
      super
      @api_headers = ''
      @library_files = ''
    end

  end

  module DSL

    # DSL method to create a static library task.
    def static_library_task(*args, &block)
      new_task = Rake::StaticLibraryTask.define_task(*args, &block)
    end

  end

end
