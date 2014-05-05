module Rake

  require 'rake'

  class StaticLibraryTask < Task
    attr_accessor :api_headers, :library_files

    def initialize(task_name, app)
      super
      @api_headers = ''
      @library_files = ''
    end

  end

  module DSL
    def static_library_task(*args, &block)
      new_task = Rake::StaticLibraryTask.define_task(*args, &block)
    end
  end

end
