module MTBuild

  module Cleaner

    @global_clean_list = ::Rake::FileList.new

    class << self

      # The list of files/folder to clean
      attr_reader :global_clean_list

      def generate_global_clean_task
        desc "Remove intermediate and output files/folders for all projects."
        task :clean do
          cleanup_files(@global_clean_list)
        end
      end

      def generate_clean_task_for_project(project_name, project_clean_list)
        desc "Remove intermediate and output files/folders for #{project_name}."
        task :clean do
          cleanup_files(project_clean_list)
        end
      end

      private

      def cleanup_files(file_names)
        file_names.each do |file_name|
          cleanup(file_name)
        end
      end

      def cleanup(file_name, opts={})
        begin
          Rake::FileUtilsExt.rm_r file_name, opts
        rescue StandardError => ex
          puts "Failed to remove #{file_name}: #{ex}" unless file_already_gone?(file_name)
        end
      end

      def file_already_gone?(file_name)
        return false if File.exist?(file_name)

        path = file_name
        prev = nil

        while (path = File.dirname(path))
          return false if cant_be_deleted?(path)
          break if [prev, "."].include?(path)
          prev = path
        end
        true
      end

      def cant_be_deleted?(path_name)
        File.exist?(path_name) &&
          (!File.readable?(path_name) || !File.executable?(path_name))
      end

      include Rake::DSL

    end

  end

end
