#!/usr/bin/ruby

require 'optparse'

require_relative 'lib_pinyin.rb'

def check_string(string)
  string.split(/\s+/).each do |word|
    if !@conv.check_syllable(word)
      puts word
    end
  end
end

def convert_file(options, target)
  filename = options[:filename]
  if !File.exist?(filename)
    abort("  Specified file does not exist: '#{filename}'")
  end
  File.read(filename).each_line do |line|
    pinyin = line.chomp
    puts @conv.convert_line(pinyin, target, options)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./convert_pinyin.rb [options]"

  opts.on('-c', '--check', 'Check if input contains invalid romanization') { options[:check] = true }
  opts.on('-i', '--input STRING', 'Input string to be converted') { |v| options[:input] = v }
  opts.on('-f', '--filename FILE', 'Provide file for conversion') { |v| options[:filename] = v }
  opts.on('-n', '--normalize', 'Normalize Pinyin (removes marker from fifth tone)') { options[:normalize] = true }
  opts.on('-N', '--numerals', 'Print all superscript tone numbers as numerals') { options[:numerals] = true }
  opts.on('-s', '--source INDEX', 'Provide index number of romanization to convert from') { |v| options[:source] = v }
  opts.on('-t', '--target INDEX', 'Provide index number of romanization to convert into') { |v| options[:target] = v }

end.parse!

if !options[:input] && !options[:filename]
  abort("  Please provide some input text or a filename.")
end

pinyin = options[:input]
target = options[:target]
source = options[:source]

target = target ? target.to_i : 1
source = source ? source.to_i : 0

@conv = Py_Converter.new(source)

if options[:check]
  check_string(pinyin)
elsif options[:filename]
  convert_file(options, target)
else
  puts @conv.convert_line(pinyin, target, options)
end
