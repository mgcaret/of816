#!/usr/bin/ruby
require 'yaml'

def usage
    puts <<EOF
Usage: #{$0} index-file|-

    Reads index file (- for stdin) and produces a test coverage
    report for non-headerless words.  The index file must have
    been merged with test coverage data or all words will be
    reported as uncovered.
EOF
    exit 1
end

index_file = ARGV.shift || usage

if index_file == '-'
    index = YAML.load(STDIN.read)
else
    File.readable?(index_file) || abort("#{index_file} not found!")
    index = YAML.load(File.read(index_file))
end

covered = []
uncovered = []

index.each_pair do |name, props|
    next if props['headerless']
    if props["tests"] && props["tests"] > 0
        covered << name
    else
        uncovered << name
    end
end

cov_percent = covered.count * 100 / (covered.count+uncovered.count)

puts "Total words: #{covered.count+uncovered.count}"
puts "Covered words: #{covered.count}"
puts "Uncovered words: #{uncovered.count}"
uncovered.sort.each_slice(5) do |sl|
    puts "\t#{sl.join(' ')}"
end
puts "Coverage: #{cov_percent}%"
