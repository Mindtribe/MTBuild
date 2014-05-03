module MTBuild
  require 'mtbuild/toolchains/gcc'

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

  module DSL
    def arm_none_eabi_gcc(configuration_hash)
      MTBuild::ToolchainArmNoneEabiGcc.new configuration_hash
    end
  end

end
