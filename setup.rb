#! /usr/bin/env ruby

require 'find'
require 'fileutils'

specs = ['bin', '.subversion', '.vnc', 'Music', '.gdb', {'home' => ENV['HOME']}]

specs.each do |spec|
  if spec.is_a?(Hash)
    srcdir = spec.keys.first
    destdir = spec[srcdir]
  else
    srcdir = spec
    destdir = File.join(ENV['HOME'], srcdir)
  end
  FileUtils.mkdir_p destdir

  files = []
  Find.find(srcdir) do |file|
    Find.prune if file =~ %r(/.svn$)
    next if File.directory? file
    files << file
  end

  files.each do |file|
    src_file = File.join(File.dirname(__FILE__), file)
    dest_file = File.join(destdir, File.basename(file))
    puts "%-30s => %s" % [src_file, dest_file]
    FileUtils.rm_f dest_file
    FileUtils.ln   src_file, dest_file
  end
end
