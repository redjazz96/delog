module Delog

  # These are parsers that can be used by Delog.  They're autoloaded so they're
  # only used on demand.
  module Parsers
    
    autoload :Basic, "delog/parsers/basic"

  end
end