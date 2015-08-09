module MTBuild
  require 'mtbuild/toolchains/arm_none_eabi_gcc'

  Toolchain.register_toolchain(:arm_none_eabi_gpp, 'MTBuild::ToolchainArmNoneEabiGpp')

  # This ToolchainGcc subclass can build using arm-non-eabi-g++
  class ToolchainArmNoneEabiGpp < ToolchainArmNoneEabiGcc

    private

    def compiler
      return 'arm-none-eabi-g++'
    end

    def linker
      return 'arm-none-eabi-g++'
    end

  end

end
