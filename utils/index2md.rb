#!/usr/bin/ruby
require 'yaml'
require 'date'

def usage
    puts <<EOF
Usage: #{$0} index-file|- [dictionary-title]

    reads index file (- for stdin) and produces markdown-
    formatted output for documentation purposes.

    if dictionary-title is specified, it is used as the top
    level heading instead of the file name.
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

dname = ARGV.shift || File.basename(index_file, File.extname(index_file))

puts "# #{dname}"
puts
puts "Updated: #{Time.new}"
puts

index.keys.sort.each do |word|
    word_info = index[word]
    cword = word.gsub(/^(#+)$/) { "\\#{$1}" } # let '#' display properly
    cword.gsub!(/^([<>])/) { "\\#{$1}" }
    puts "## #{cword}"
    puts
    if word_info['help']
        word_info['help'].each_with_index do |line, i|
            if line.start_with?('(')
                line.gsub!(/[(](.+?)[)]/, '_(\1)_') # emphasize stack effects
            else
                if line =~ /^\s*\S+:/
                    # space for separating interpretation/compilation/etc.
                    puts if i > 0
                end
                line.gsub!(/:\s+[(](.+?)[)]/, ': _(\1)_') # emphasize stack effects
            end
            puts line
        end
        puts
    end
end
