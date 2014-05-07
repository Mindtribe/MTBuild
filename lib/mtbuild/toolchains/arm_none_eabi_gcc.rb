module MTBuild
  require 'mtbuild/toolchains/gcc'

  Toolchain.register_toolchain(:arm_none_eabi_gcc, 'MTBuild::ToolchainArmNoneEabiGcc')

	class ToolchainArmNoneEabiGcc < ToolchainGcc

		def initialize(configuration)
      super
		end

    private

    def compiler
      return 'arm-none-eabi-gcc'
    end

    def archiver
      return 'arm-none-eabi-ar'
    end

    def linker
      return 'arm-none-eabi-gcc'
    end

	end

end
