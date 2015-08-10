module MTBuild

  require 'rake'
  require 'rake/packagetask'
  require 'pathname'

  # Create a packaging task that will package files into distributable packages
  # (e.g zip archive or tar files). The files are organized in folders inside the
  # package.
  #
  # The OrganizedPackageTask will create the following targets:
  #
  # +:package+ ::
  #   Create all the requested package files.
  #
  # +:clobber_package+ ::
  #   Delete all the package files.  This target is automatically
  #   added to the main clobber target.
  #
  # +:repackage+ ::
  #   Rebuild the package files from scratch, even if they are not out
  #   of date.
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.tgz"</tt> ::
  #   Create a gzipped tar package (if <em>need_tar</em> is true).
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.tar.gz"</tt> ::
  #   Create a gzipped tar package (if <em>need_tar_gz</em> is true).
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.tar.bz2"</tt> ::
  #   Create a bzip2'd tar package (if <em>need_tar_bz2</em> is true).
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.zip"</tt> ::
  #   Create a zip package archive (if <em>need_zip</em> is true).
  #
  # Example:
  #
  #   Rake::OrganizedPackageTask.new("MyPackage", "1.2.3") do |p|
  #     p.need_tar = true
  #     p.add_files_to_folder('bin', 'bin', '**/*')
  #     p.package_files.include("lib/**/*.rb")
  #   end
  #
  class OrganizedPackageTask < Rake::PackageTask

    # Add files to a folder in the package
    def add_files_to_folder(package_folder, included_files, excluded_files=[])
      file_list = Utils.expand_file_list(included_files, excluded_files)
      package_file_list = file_list.collect{ |f| File.join(package_dir_path, package_folder, File.basename(f)) }
      @origin_files += file_list
      @destination_files += package_file_list
    end

    # Add folder to a folder in the package
    def add_folders_to_folder(package_folder, folders, included_files=['*'], excluded_files=[])
      folders.each do |folder|
        included_files = Utils.ensure_array(included_files).collect{|f| File.join('**',f)}
        file_list = Utils.expand_file_list(included_files, excluded_files, folder)
        package_file_list = file_list.collect{ |f| File.join(package_dir_path, package_folder, get_relative_path(folder,f)) }
        @origin_files += file_list
        @destination_files += package_file_list
      end
    end

    # Hide the PackageTask package_files because this class doesn't use it
    private :package_files

    private

    def init(name, version)
      super
      fail "Version required (or :noversion)" if @version.nil?
      @version = nil if :noversion == @version
      @destination_files = []
      @origin_files = []
    end

    def get_relative_path(parent, child)
      child = Pathname.new(child)
      parent = Pathname.new(parent)
      return child.relative_path_from(parent).to_s
    end

    def define
      desc "Build the package for #{@name}"
      task :package

      desc "Force a rebuild of the package files for #{@name}"
      task :repackage => [:clobber_package, :package]

      desc "Remove package products for #{@name}"
      task :clobber_package do
        rm_r package_dir rescue nil
      end

      task :clobber => [:clobber_package]

      [
        [need_tar, tgz_file, "z"],
        [need_tar_gz, tar_gz_file, "z"],
        [need_tar_bz2, tar_bz2_file, "j"]
      ].each do |(need, file, flag)|
        if need
          task :package => ["#{package_dir}/#{file}"]
          file "#{package_dir}/#{file}" =>
            [package_dir_path] + @origin_files + @destination_files do
            chdir(package_dir) do
              sh %{#{@tar_command} #{flag}cvf #{file} #{package_name}}
            end
          end
        end
      end

      if need_zip
        task :package => ["#{package_dir}/#{zip_file}"]
        file "#{package_dir}/#{zip_file}" =>
          [package_dir_path] + @origin_files + @destination_files do
          chdir(package_dir) do
            sh %{#{@zip_command} -r #{zip_file} #{package_name}}
          end
        end
      end

      directory package_dir_path

      @destination_files.each_index do |i|
        origin_file = @origin_files[i]
        destination_file = @destination_files[i]

        file destination_file => [origin_file, package_dir_path] do
          fdir = File.dirname(destination_file)
          mkdir_p(fdir) unless File.exist?(fdir)
          if File.directory?(origin_file)
            mkdir_p(destination_file)
          else
            rm_f destination_file
            safe_ln(origin_file, destination_file)
          end
        end
      end

      self
    end
  end

end
