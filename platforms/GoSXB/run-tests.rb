#!/usr/bin/ruby

require 'open3'
require 'yaml'
require 'stringio'
require 'timeout'
require 'optparse'

@opts = {
    test_dir: '../../test',
    suites: '*',
    output_file: nil,
    cov_file: nil,
    verbose: $DEBUG,
    list_only: false
}

@coverage = Hash.new(0)

OptionParser.new do |o|
    o.banner = "Usage: #{$0} [options]"

    o.on('-d', '--dir TEST_DIR', 'Specify test directory.') do |d|
        @opts[:test_dir] = d
    end

    o.on('-s', '--suites PATTERN', 'Specify suites as shell glob.') do |p|
        @opts[:suites] = p
    end

    o.on('-o', '--outfile FILENAME', 'Specify test output file (default none).') do |f|
        @opts[:output_file] = f
    end

    o.on('-c', '--coverage FILENAME', 'Specify test coverage file (default none).') do |f|
        @opts[:cov_file] = f
    end

    o.on('-l', '--list-suites', 'List available test suites.') do |d|
        @opts[:list_only] = true
    end

    o.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @opts[:verbose] = v
    end

    o.on_tail("-h", "--help", "Show this message") do
        puts o
        exit
    end
end.parse!

@total_errors = 0

def verbose
    @opts[:verbose]
end

def run_suite(suite, outfile = nil)
    errors = 0
    suite_text = []
    outbuf = StringIO.new
    errbuf = StringIO.new
    suite['load'].each do |file|
        suite_text += File.readlines("#{@opts[:test_dir]}/#{file}")
    end
    colons = {}
    suite_text << "\nbye\n"
    Open3.popen3('./gosxb-of816.sh') do |stdin, stdout, stderr, wait_thr|
        until [stdout, stderr].find {|f| !f.eof}.nil?
            readable, writable, errored = IO.select([stdout,stderr],[stdin],[],0)
            if writable.include?(stdin)
                if line = suite_text.shift
                    puts ">> #{line}" if verbose
                    stdin.write(line)
                else
                    puts "Lines complete."
                    stdin.flush
                    begin
                        Timeout.timeout(10) do
                            outbuf.write(stdout.read)
                        end
                    rescue Timeout::Error
                        begin
                            outbuf.write(stdout.read_nonblock(1024))
                        rescue IO::EAGAINWaitReadable
                            # nothing
                        end
                        puts outbuf.string unless verbose
                        STDERR.puts "Emulator did not exit on its own."
                        errors += 1
                    end
                    stdin.close
                    puts outbuf.string if verbose
                    break
                end
            end
            if readable.include?(stdout)
                text = stdout.readline
                puts "<< #{text}" if verbose
                outbuf.write(text)
            end
            if readable.include?(stderr)
                stdin.flush
                errbuf.write(stderr.read)
                puts "Unexpected output on stderr:"
                puts outbuf.string
                puts errbuf.string
                stdout.close
                stderr.close
                exit 2
            end
            break unless wait_thr.alive?
        end
        outfile.write(outbuf.string) if outfile
        prevline = ""
        outbuf.string.lines.each do |line|
            cs_line = line.gsub(/\\.+$/,'')
            case line
            when /Exception/, /Def not found/, /Stack u/
                STDERR.puts prevline, line
                errors += 1
            when /WRONG/, /INCORRECT/
                unless prevline =~ /\[OK\]/
                    STDERR.puts line
                    errors += 1
                end
            when /TESTING/i
                puts line unless line.start_with?(':') || line.start_with?('\\')
            end
            if cs_line =~ /\s*:\s+(\S+)/
                colons[$1.downcase] = true
            end
            if cs_line =~ /\s*[tT]\{\s+:\s+(\S+)/
                colons[$1.downcase] = true
            end
            if cs_line =~ /^\s*T\{\s+(.+)\s+\-\>\s+/i
                words = $1.split(/\s+/)
                words.each do |word|
                    next if word == '->'
                    @coverage[word.downcase] += 1 unless colons[word.downcase]
                end
            end
            if prevline =~ /expect:\s*\"(.+)\"\s*$/
                unless line.chomp == $1
                    STDERR.puts prevline
                    STDERR.puts "Unexpected: #{line.chomp.inspect}"
                    errors += 1
                end
            elsif prevline =~ /expect:\s*\/(.+)\/\s*$/
                rexp = Regexp.new($1)
                unless line.chomp =~ rexp
                    STDERR.puts prevline
                    STDERR.puts "Unexpected: #{line.chomp.inspect}"
                    errors += 1
                end
            end

            prevline = line
        end
        puts "Errors = #{errors}"
    end
    puts "Suite complete."
    return errors
end

outfile = nil
begin
    manifest = YAML.load(File.read("#{@opts[:test_dir]}/test-manifest.yaml"))
    #puts manifest.inspect

    unless @opts[:verbose]
        outfile = File.open(@opts[:output_file], 'w') if @opts[:output_file]
    end

    manifest.each do |suite|
        if File.fnmatch(@opts[:suites], suite['name'])
            print "Executing suite: " unless @opts[:list_only]
            puts suite['name']
            @total_errors += run_suite(suite, outfile) unless @opts[:list_only]
        end
    end
rescue RuntimeError => e
    STDERR.puts e.to_s
ensure
    outfile.close if outfile
end

exit 0 if @opts[:list_only]

File.write(@opts[:cov_file], @coverage.to_yaml) if @opts[:cov_file]

if @total_errors > 0
    STDERR.puts "Tests complete, total errors: #{@total_errors}"
    exit 1
end

STDOUT.puts "Tests complete, no errors."
exit 0
