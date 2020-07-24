#! /usr/bin/env ruby
# coding: utf-8

require "find"
require "fileutils"
require "rake"

HOME = ENV["HOME"]
UDEV_PATH = "/etc/udev/rules.d"
PWD = File.dirname(__FILE__)

class SyncSpec
  attr_reader :source_dir, :options

  def initialize(source_dir, options = {})
    @source_dir = source_dir
    @options = options
  end

  def dest_dir
    options[:dest_dir] || default_dest_dir
  end

  def sudo?
    options[:sudo]
  end

  def files
    files = []
    Find.find(source_dir) do |file|
      Find.prune if file =~ %r(/.svn$)
      next if File.directory? file
      files << file
    end
    files
  end

  def sync!
    FileUtils.mkdir_p dest_dir
    files.each do |file|
      sync_file file
    end
  end

  private

  def sync_file(file)
    source_file = File.expand_path(File.join(PWD, file))
    dest_file = File.expand_path(File.join(dest_dir, File.basename(file)))
    if sudo?
      if File.symlink?(dest_file) && (File.readlink(dest_file) == source_file)
        warn "WARN: same, skipping: #{source_file} → #{dest_file}"
        return
      end
      Rake.sh %Q{sudo rm -f "#{dest_file}"}
      Rake.sh %Q{sudo ln -s "#{source_file}" "#{dest_file}"} # soft link
    else
      if File.exist?(dest_file) && (File.stat(dest_file).ino == File.stat(source_file).ino)
        warn "WARN: same, skipping: #{source_file} → #{dest_file}"
        return
      end
      FileUtils.rm_f dest_file
      FileUtils.ln source_file, dest_file, verbose: true # hard link
    end
  end

  def default_dest_dir
    File.join HOME, source_dir
  end
end

class SymlinkSyncSpec < SyncSpec
  def sync!
    source_file = File.expand_path(File.join(PWD, source_dir))

    if File.symlink?(dest_dir) && (File.readlink(dest_dir) == source_file)
      warn "WARN: same, skipping: #{source_file} → #{dest_dir}"
      return
    end

    FileUtils.rm_rf dest_dir
    FileUtils.symlink source_file, dest_dir, verbose: true
  end
end

[
  SyncSpec.new("bin"),
  SyncSpec.new("home", dest_dir: HOME),
  SyncSpec.new("Music"),
  SyncSpec.new(".fonts"),
  SyncSpec.new(".gem"),
  SyncSpec.new(".gdb"),
  SymlinkSyncSpec.new(".remmina"),
  SyncSpec.new(".subversion"),
  SyncSpec.new(".vnc"),
  SymlinkSyncSpec.new("devilspie2", dest_dir: File.join(HOME, ".config", "devilspie2")),
  SyncSpec.new(".config"),
  SyncSpec.new("udev", dest_dir: UDEV_PATH, sudo: true),
].each do |spec|
  spec.sync!
end
