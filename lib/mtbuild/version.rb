module MTBuild
  module Version
    MAJOR, MINOR, BUILD, *OTHER = MTBuild::VERSION.split '.'

    NUMBERS = [MAJOR, MINOR, BUILD, *OTHER]
  end
end
