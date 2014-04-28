require 'MTBuild/Toolchain'

module MTBuild

	class ToolchainArmNoneEabiGcc < Toolchain

    attr_accessor :cpu, :linker_script

		def initialize(configuration_hash)
      super

		end

	end

  module DSL
    def arm_none_eabi_gcc(configuration_hash)
      MTBuild::ToolchainArmNoneEabiGcc.new configuration_hash
    end
  end

end
