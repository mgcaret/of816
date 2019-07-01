#!/usr/bin/ruby

def usage
  abort("Usage: #{$0} <outfile> <infile> [<infile> ...]")
end

def set_file_header(data, file_no, name, offset, size)
  f_name = file_no*16+5
  f_offs = f_name+12
  f_size = f_offs+2
  name.bytes.each_with_index {|b, i| data[f_name+i] = b}
  data[f_offs] = offset & 0xFF
  data[f_offs+1] = (offset >> 8) & 0xFF
  data[f_size] = size & 0xFF
  data[f_size+1] = (size >> 8) & 0xFF
end

outfile = ARGV.shift || usage

usage if ARGV.empty?

abort("Too many files (>15)") if ARGV.count > 15

out_bytes = [0x4D, 0x47, 0x46, 0x53]
out_bytes += [ARGV.count] # file count
out_bytes += (([0x20] * 12)+([0x00]*4)) * ARGV.count # header for each file

ARGV.each_with_index do |file, i|
  data = File.read(file).bytes
  set_file_header(out_bytes, i, File.basename(file)[0,12], out_bytes.count, data.count)
  out_bytes += data
end

File.write(outfile, out_bytes.map(&:chr).join)
