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

    @arm_none_eabi_gcc_architectures = {
      armv2: 'armv2',
      armv2a: 'armv2a',
      armv3: 'armv3',
      armv3m: 'armv3m',
      armv4: 'armv4',
      armv4t: 'armv4t',
      armv5: 'armv5',
      armv5t: 'armv5t',
      armv5e: 'armv5e',
      armv5te: 'armv5te',
      armv6: 'armv6',
      armv6j: 'armv6j',
      armv6t2: 'armv6t2',
      armv6z: 'armv6z',
      armv6zk: 'armv6zk',
      armv6_m: 'armv6-m',
      armv7: 'armv7',
      armv7_a: 'armv7-a',
      armv7_r: 'armv7-r',
      armv7_m: 'armv7-m',
      armv7e_m: 'armv7e-m',
      armv7ve: 'armv7ve',
      armv8_a: 'armv8-a',
      armv8_a_crc: 'armv8-a+crc',
      iwmmxt: 'iwmmxt',
      iwmmxt2: 'iwmmxt2',
      ep9312: 'ep9312'
    }

    @arm_none_eabi_gcc_processors = {
      arm2: 'arm2',
      arm250: 'arm250',
      arm3: 'arm3',
      arm6: 'arm6',
      arm60: 'arm60',
      arm600: 'arm600',
      arm610: 'arm610',
      arm620: 'arm620',
      arm7: 'arm7',
      arm7m: 'arm7m',
      arm7d: 'arm7d',
      arm7dm: 'arm7dm',
      arm7di: 'arm7di',
      arm7dmi: 'arm7dmi',
      arm70: 'arm70',
      arm700: 'arm700',
      arm700i: 'arm700i',
      arm710: 'arm710',
      arm710c: 'arm710c',
      arm7100: 'arm7100',
      arm720: 'arm720',
      arm7500: 'arm7500',
      arm7500fe: 'arm7500fe',
      arm7tdmi: 'arm7tdmi',
      arm7tdmi_s: 'arm7tdmi-s',
      arm710t: 'arm710t',
      arm720t: 'arm720t',
      atm740t: 'arm740t',
      strongarm: 'strongarm',
      strongarm110: 'strongarm110',
      strongarm1100: 'strongarm1100',
      strongarm1110: 'strongarm1110',
      arm8: 'arm8',
      arm810: 'arm810',
      arm9: 'arm9',
      arm9e: 'arm9e',
      arm920: 'arm920',
      arm920t: 'arm920t',
      arm922t: 'arm922t',
      arm946e_s: 'arm946e-s',
      arm966e_s: 'arm966e-s',
      arm968e_s: 'arm968e-s',
      arm926ej_s: 'arm926ej-s',
      arm940t: 'arm940t',
      arm9tdmi: 'arm9tdmi',
      arm10tdmi: 'arm10tdmi',
      arm1020t: 'arm1020t',
      arm1026ej_s: 'arm1026ej-s',
      arm10e: 'arm10e',
      arm1020e: 'arm1020e',
      arm1022e: 'arm1022e',
      arm1136j_s: 'arm1136j-s',
      arm1136jf_s: 'arm1136jf-s',
      mpcore: 'mpcore',
      mpcorenovfp: 'mpcorenovfp',
      arm1156t2_s: 'arm1156t2-s',
      arm1156t2f_s: 'arm1156t2f-s',
      arm1176jz_s: 'arm1176jz-s',
      arm1176jzf_s: 'arm1176jzf-s',
      cortex_a5: 'cortex-a5',
      cortex_a7: 'cortex-a7',
      cortex_a8: 'cortex-a8',
      cortex_a9: 'cortex-a9',
      cortex_a12: 'cortex-a12',
      cortex_a15: 'cortex-a15',
      cortex_a53: 'cortex-a53',
      cortex_a57: 'cortex-a57',
      cortex_r4: 'cortex-r4',
      cortex_r4f: 'cortex-r4f',
      cortex_r5: 'cortex-r5',
      cortex_r7: 'cortex-r7',
      cortex_m4: 'cortex-m4',
      cortex_m3: 'cortex-m3',
      cortex_m1: 'cortex-m1',
      cortex_m0: 'cortex-m0',
      cortex_m0plus: 'cortex-m0plus',
      marvell_pj4: 'marvell-pj4',
      xscale: 'xscale',
      iwmmxt: 'iwmmxt',
      iwmmxt2: 'iwmmxt2',
      ep9312: 'ep9312',
      fa526: 'fa526',
      fa626: 'fa626',
      fa606te: 'fa606te',
      fa626te: 'fa626te',
      fmp626: 'fmp626',
      fa726te: 'fa726te'
    }

    @arm_none_eabi_gcc_fpus = {
      vfp: 'vfp',
      vfpv3: 'vfpv3',
      vfpv3_fp16: 'vfpv3-fp16',
      vfpv3_d16: 'vfpv3-d16',
      vfpv3_d16_fp16: 'vfpv3-d16-fp16',
      vfpv3xd: 'vfpv3xd',
      vfpv3xd_fp16: 'vfpv3xd-fp16',
      neon: 'neon',
      neon_fp16: 'neon-fp16',
      vfpv4: 'vfpv4',
      vfpv4_d16: 'vfpv4-d16',
      fpv4_sp_d16: 'fpv4-sp-d16',
      neon_vfpv4: 'neon-vfpv4',
      fp_armv8: 'fp-armv8',
      neon_fp_armv8: 'neon-fp-armv8',
      crypto_neon_fp_armv8: 'crypto-neon-fp-armv8'
    }

    @arm_none_eabi_gcc_registers = {
      r0:  'R0',
      r1:  'R1',
      r2:  'R2',
      r3:  'R3',
      r4:  'R4',
      r5:  'R5',
      r6:  'R6',
      r7:  'R7',
      r8:  'R8',
      r9:  'R9',
      r10: 'R10',
      r11: 'R11',
      r12: 'R12',
      r13: 'R13',
      r14: 'R14',
      r15: 'R15',
    }

    @arm_none_eabi_gcc_flags = {
      abi: '-mabi=',
      apcs_frame: '',
      thumb_interwork: '',
      sched_prolog: '',
      float_abi: '-mfloat-abi=',
      endianness: '',
      cpu: '-mcpu=',
      tune: '-mtune=',
      arch: '-march=',
      fpu: '-mfpu=',
      fp16_format: '-mfp16-format=',
      structure_size_boundary: '-mstructure-size-boundary=',
      abort_on_noreturn: '',
      long_calls: '',
      single_pic_base: '',
      pic_register: '-mpic-register=',
      pic_data_is_text_relative: '',
      poke_function_name: '',
      mode: '',
      tpcs_frame: '',
      tpcs_leaf_frame: '',
      callee_super_interworking: '',
      caller_super_interworking: '',
      tp: '-mtp=',
      tls_dialect: '-mtls-dialect=',
      word_relocations: '',
      fix_cortex_m3_ldrd: '',
      unaligned_access: '',
      neon_for_64bits: '',
      slow_flash_data: '',
      restrict_it: ''
    }

    @arm_none_eabi_gcc_options = {
      abi: {
        apcs_gnu: 'apcs-gnu',
        atpcs: 'atpcs',
        aapcs: 'aapcs',
        aapcs_linux: 'aapcs-linux',
        iwmmxt: 'iwmmxt'
      },
      apcs_frame: {
        yes: '-mapcs-frame',
        no: '-mno-apcs-frame'
      },
      thumb_interwork: {
        yes: '-mthumb-interwork',
        no: '-mno-thumb-interwork'
      },
      sched_prolog: {
        yes: '-msched-prolog',
        no: '-mno-sched-prolog'
      },
      float_abi: {
        soft: 'soft',
        softfp: 'softfp',
        hard: 'hard'
      },
      endianness: {
        big_endian: '-mbig-endian',
        little_endian: '-mlittle-endian'
      },
      cpu: @arm_none_eabi_gcc_processors,
      tune: @arm_none_eabi_gcc_processors,
      arch: @arm_none_eabi_gcc_architectures,
      fpu: @arm_none_eabi_gcc_fpus,
      fp16_format: {
        none: 'none',
        ieee: 'ieee',
        alternative: 'alternative'
      },
      structure_size_boundary: {
        8 => '8',
        32 => '32',
        64 => '64'
      },
      abort_on_noreturn: {
        yes: '-mabort-on-noreturn',
        no: '-mno-abort-on-noreturn'
      },
      long_calls: {
        yes: '-mlong-calls',
        no: '-mno-long-calls'
      },
      single_pic_base: {
        yes: '-msingle-pic-base',
        no: '-mno-single-pic-base'
      },
      pic_register: @arm_none_eabi_gcc_registers,
      pic_data_is_text_relative: {
        yes: '-mpic-data-is-text-relative',
        no: '-no-mpic-data-is-text-relative'
      },
      poke_function_name: {
        yes: '-mpoke-function-name',
        no: '-mno-poke-function-name'
      },
      mode: {
        arm: '-marm',
        thumb: '-mthumb'
      },
      tpcs_frame: {
        yes: '-mtpcs-frame',
        no: '-mno-tpcs-frame'
      },
      tpcs_leaf_frame: {
        yes: '-mtpcs-leaf-frame',
        no: '-mno-tpcs-leaf-frame'
      },
      callee_super_interworking: {
        yes: '-mcallee-super-interworking',
        no: '-mno-callee-super-interworking'
      },
      caller_super_interworking: {
        yes: '-mcaller-super-interworking',
        no: '-mno-caller-super-interworking'
      },
      tp: {
        soft: 'soft',
        auto: 'auto'
      },
      tls_dialect: {
        gnu: 'gnu',
        gnu2: 'gnu2'
      },
      word_relocations: {
        yes: '-mword-relocations',
        no: '-mno-word-relocations'
      },
      fix_cortex_m3_ldrd: {
        yes: '-mfix-cortex-m3-ldrd',
        no: '-mno-fix-cortex-m3-ldrd'
      },
      unaligned_access: {
        yes: '-munaligned-access',
        no: '-mno-unaligned-access'
      },
      neon_for_64bits: {
        yes: '-mneon-for-64bits',
        no: '-mno-neon-for-64bits'
      },
      slow_flash_data: {
        yes: '-mslow-flash-data',
        no: '-mno-slow-flash-data'
      },
      restrict_it: {
        yes: '-mrestrict-it',
        no: '-mno-restrict-it'
      }
    }

    def self.arm_none_eabi_gcc_flags
      return @arm_none_eabi_gcc_flags
    end

    def self.arm_none_eabi_gcc_options
      return @arm_none_eabi_gcc_options
    end

    def get_flag(flagIdentifier)
      flag = super
      flag = ToolchainArmNoneEabiGcc.arm_none_eabi_gcc_flags.fetch(flagIdentifier, nil) if flag.nil?
      return flag
    end

    def get_options_for_flag(flagIdentifier)
      options = super
      options = ToolchainArmNoneEabiGcc.arm_none_eabi_gcc_options.fetch(flagIdentifier, nil) if options.nil?
      return options
    end

	end

  module DSL
    def arm_none_eabi_gcc(configuration_hash)
      MTBuild::ToolchainArmNoneEabiGcc.new configuration_hash
    end
  end

end
