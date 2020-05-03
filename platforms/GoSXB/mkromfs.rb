#!/usr/bin/ruby

@out_bytes = []
@offset_map = {}
@nentries_offset = 4

def usage
  abort("Usage: #{$0} <outfile> <infile> [<infile> ...]")
end

def new_romfs
  @out_bytes = [0x4D, 0x47, 0x46, 0x53, 0x00]
end

def set_int32(offset, num)
  @out_bytes[offset+0] = num & 0xFF
  @out_bytes[offset+1] = num >> 8 & 0xFF
  @out_bytes[offset+2] = num >> 16 & 0xFF
  @out_bytes[offset+3] = num >> 24 & 0xFF
end

def add_int32(num)
  @out_bytes += [num & 0xFF]
  @out_bytes += [num >> 8 & 0xFF]
  @out_bytes += [num >> 16 & 0xFF]
  @out_bytes += [num >> 24 & 0xFF]
end

def add_file_header(name, size)
  @offset_map[name] = @out_bytes.length
  add_int32(0) # offset
  add_int32(size)
  @out_bytes += [name.length]
  @out_bytes += name.bytes
  @out_bytes[@nentries_offset] += 1
end

outfile = ARGV.shift || usage

usage if ARGV.empty?

abort("Too many files (>15)") if ARGV.count > 255

new_romfs

ARGV.each do |name|
  if File.file?(name)
    add_file_header(name, File.size(name))
  else
    puts "skipping #{name} - not a regular file"
  end
end

@offset_map.each_pair do |name, offset|
  set_int32(offset, @out_bytes.length)
  data = File.read(name)
  @out_bytes += data.bytes
end

File.write(outfile, @out_bytes.map(&:chr).join)
