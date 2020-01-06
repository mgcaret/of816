#!/usr/bin/ruby
require 'yaml'

def usage
    puts <<EOF
Usage: #{$0} dictionary-source-file coverage-file

    reads dictionary-source-file and produces YAML output
    with all visible words and their help text, flags, etc.

    if coverage-file is specified, merge coverage data
EOF
    exit 1
end

dict = ARGV.shift || usage
File.readable?(dict) || abort("#{dict} not found!")

cov = ARGV.shift

coverage = {}
if File.readable?(cov)
    coverage = YAML.load(File.read(cov))
end

input = File.read(dict)
output = Hash.new()

help = []
input.lines.each do |line|
    case line
    when /^\s*;\s+H:\s*(.+)/
        help << $1
    when /^\s*dword(q?)\s+(.+)/
        _label, nameq, flags = $2.split(',')
        name = nameq[1..-2].downcase # remove quotes
        name.tr!("'", '"') if $1 == 'q'
        output[name] ||= {}
        output[name].merge!({"help" => help}) unless help.empty?
        if flags
            fl = flags.split('|')
            output[name].merge!({"flags" => fl}) unless fl.empty?
        end
        output[name].merge!({"tests" => coverage[name]}) if coverage[name]
    when /^\s*eword/
        help = []
    end
end

puts output.to_yaml
