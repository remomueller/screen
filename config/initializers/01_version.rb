module Screen
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 9
    TINY = 11
    BUILD = nil # nil, "pre", "beta1", "beta2", "rc", "rc2"

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
