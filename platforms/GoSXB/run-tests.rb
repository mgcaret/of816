#!/usr/bin/ruby

require 'open3'
require 'yaml'
require 'stringio'
require 'timeout'

TEST_DIR = '../../test'

@verbose = $DEBUG
@total_errors = 0

def run_suite(suite)
    puts "Executing suite: #{suite['name']}"
    errors = 0
    suite_text = []
    outbuf = StringIO.new
    errbuf = StringIO.new
    suite['load'].each do |file|
        suite_text += File.readlines("#{TEST_DIR}/#{file}")
    end
    suite_text << "\nbye\n"
    Open3.popen3('./gosxb-of816.sh') do |stdin, stdout, stderr, wait_thr|
        until [stdout, stderr].find {|f| !f.eof}.nil?
            readable, writable, errored = IO.select([stdout,stderr],[stdin],[],0)
            if writable.include?(stdin)
                if line = suite_text.shift
                    puts ">> #{line}" if @verbose
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
                        puts outbuf.string unless @verbose
                        STDERR.puts "Emulator did not exit on its own."
                        errors += 1
                    end
                    stdin.close
                    puts outbuf.string if @verbose
                    break
                end
            end
            if readable.include?(stdout)
                text = stdout.readline
                puts "<< #{text}" if @verbose
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
        prevline = ""
        outbuf.string.lines.each do |line|
            case line
            when /Exception/, /not found/
                STDERR.puts prevline, line
                errors += 1
            when /WRONG/, /INCORRECT/
                unless prevline =~ /\[OK\]/
                    STDERR.puts line
                    errors += 1
                end
            when /TESTING/i
                puts line unless line.start_with?(':')
            end
            prevline = line
        end
        puts "Errors = #{errors}"
    end
    puts "Suite complete."
    return errors
end


manifest = YAML.load(File.read("#{TEST_DIR}/test-manifest.yaml"))

#puts manifest.inspect

manifest.each do |suite|
    @total_errors += run_suite(suite)
end

if @total_errors > 0
    STDERR.puts "Tests complete, total errors: #{@total_errors}"
    exit 1
end

STDOUT.puts "Tests complete, no errors."
exit 0
