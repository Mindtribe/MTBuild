module MTBuild
  require 'mtbuild/toolchains/gcc'

  Toolchain.register_toolchain(:gpp, 'MTBuild::ToolchainGpp')

  # This ToolchainGcc subclass can build using g++
  class ToolchainGpp < ToolchainGcc

    private

    def compiler
      return 'g++'
    end

    def linker
      return 'g++'
    end

  end

end
