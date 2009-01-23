#! /usr/bin/env ruby

require 'fileutils'

# directory => [files]
spec = {
  'bin'         => %w[clup sshconf rsync_portable wvdialer m2h open_mailto g1-internets eclipse say webserver],
  '.subversion' => %w[config],
  '.vnc'        => %w[xstartup],
  'Music'       => %w[normalize_volume.sh],
  '.gdb'        => %w[session-hack session-ruby session-asm],
  ENV['HOME']   => %w[.autotest .bashrc .exrc .gdbinit .gitconfig .gitignore .inputrc .mwmrc .sawfishrc .twmrc .Xdefaults .xmodmap4win],
}

spec.each do |directory, files|
  fq_dest_dir = directory.match(%r(^/)) ? directory : File.join(ENV['HOME'], directory)
  FileUtils.mkdir_p fq_dest_dir
  files.each do |file|
    fq_src_file = File.join(File.dirname(__FILE__), file)
    fq_dest_file = File.join(fq_dest_dir, file)
    FileUtils.rm_f      fq_dest_file
    FileUtils.ln        fq_src_file, fq_dest_file
  end
end

# use directories and map directories instead of individual files.
# make "old" directory, with xmodmap4win and others
