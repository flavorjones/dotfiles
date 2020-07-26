#! /usr/bin/env ruby
# coding: utf-8

require "find"
require "fileutils"
require "rake"

HOME = ENV["HOME"]
UDEV_PATH = "/etc/udev/rules.d"
PWD = File.dirname(__FILE__)

class SyncSpec
  module Commands
    REMOVE_FILE = "rm -f"
    REMOVE_FILE_OR_DIR = "rm -rf"
    SYMLINK = "ln -s"
    HARDLINK = "ln"
  end

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

  def dry_run?
    options[:dry_run]
  end

  def verbose?
    options[:verbose]
  end

  def files
    files = []
    Find.find(source_dir) do |file|
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

  def warn(message)
    if verbose?
      puts message
    end
  end

  def sh(command)
    warn("RUN: #{command}")
    unless dry_run?
      Rake.sh command
    end
  end

  private

  def sync_file(file)
    source_file = File.expand_path(File.join(PWD, file))
    dest_file = File.expand_path(File.join(dest_dir, File.basename(file)))
    if sudo?
      if File.symlink?(dest_file) && (File.readlink(dest_file) == source_file)
        warn "WARN: same, skipping: #{file} → #{dest_file}"
        return
      end
      sh %Q{sudo #{Commands::REMOVE_FILE} "#{dest_file}"}
      sh %Q{sudo #{Commands::SYMLINK} "#{source_file}" "#{dest_file}"}
    else
      if File.exist?(dest_file) && (File.stat(dest_file).ino == File.stat(source_file).ino)
        warn "WARN: same, skipping: #{file} ⇒ #{dest_file}"
        return
      end
      sh %Q{#{Commands::REMOVE_FILE} "#{dest_file}"}
      sh %Q{#{Commands::HARDLINK} "#{source_file}" "#{dest_file}"}
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
      warn "WARN: same, skipping: #{source_dir}/ → #{dest_dir}"
      return
    end

    sh %Q{#{Commands::REMOVE_FILE_OR_DIR} "#{dest_dir}"}
    sh %Q{#{Commands::SYMLINK} "#{source_file}" "#{dest_dir}"}
  end
end

options = Hash.new
if ARGV.include?("--dry-run")
  options[:dry_run] = true
end
if ARGV.include?("--verbose")
  options[:verbose] = true
end

[
  SyncSpec.new("bin", options),
  SyncSpec.new("home", options.merge(dest_dir: HOME)),
  SyncSpec.new("Music", options),
  SyncSpec.new(".fonts", options),
  SyncSpec.new(".gem", options),
  SyncSpec.new(".gdb", options),
  SymlinkSyncSpec.new(".remmina", options),
  SyncSpec.new(".subversion", options),
  SyncSpec.new(".vnc", options),
  SymlinkSyncSpec.new("devilspie2", options.merge(dest_dir: File.join(HOME, ".config/devilspie2"))),
  SyncSpec.new(".config", options),
  SyncSpec.new("udev", options.merge(dest_dir: UDEV_PATH, sudo: true)),
].each do |spec|
  spec.sync!
end
