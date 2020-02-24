#! /usr/bin/env ruby

require "find"
require "fileutils"

HOME = ENV["HOME"]
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
    source_file = File.join PWD, file
    dest_file = File.join dest_dir, File.basename(file)
    FileUtils.rm_f dest_file
    FileUtils.ln source_file, dest_file, verbose: true
  end

  def default_dest_dir
    File.join HOME, source_dir
  end
end

class SymlinkSyncSpec < SyncSpec
  def sync!
    source_file = File.expand_path(File.join(PWD, source_dir))

    FileUtils.rm_rf dest_dir
    FileUtils.symlink source_file, dest_dir, verbose: true
  end
end

[
  SyncSpec.new("bin"),
  SyncSpec.new("home", dest_dir: HOME),
  SyncSpec.new("Music"),
  SyncSpec.new("vms"),
  SyncSpec.new(".fonts"),
  SyncSpec.new(".gem"),
  SyncSpec.new(".gdb"),
  SymlinkSyncSpec.new(".remmina"),
  SyncSpec.new(".subversion"),
  SyncSpec.new(".vnc"),
  SymlinkSyncSpec.new("devilspie2", dest_dir: File.join(HOME, ".config", "devilspie2")),
  SyncSpec.new(".config"),
].each do |spec|
  spec.sync!
end
