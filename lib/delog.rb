lib_path = File.expand_path("../", __FILE__)
$: << lib_path unless $:.include? lib_path

require 'set'
require 'date'
require 'forwardable'
require 'delog/line_parser'
require 'delog/parsers'
require 'delog/log'
require 'delog/method_accessor'
require 'delog/line'
require 'delog/version'

module Delog

end