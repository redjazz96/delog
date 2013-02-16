require 'delog/parsers/addins'

module Delog

  # These are parsers that can be used by Delog.  They're autoloaded so they're
  # only used on demand.
  module Parsers

    autoload :Empty, "delog/parsers/empty"
  end
end