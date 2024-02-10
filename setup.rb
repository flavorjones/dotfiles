#! /usr/bin/env ruby
# coding: utf-8

require "find"
require "fileutils"
require "rake"

HOME = ENV["HOME"]
PWD = File.dirname(__FILE__)
DESKTOP_DIR = File.join(ENV["HOME"], ".local/share/applications")

class SyncSpec
  module Commands
    REMOVE_FILE = "rm -f"
    REMOVE_DIR = "rm -rf"
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

  def force?
    options[:force]
  end

  def warn(message)
    if verbose?
      puts message
    end
  end

  def sh(command)
    command = "sudo #{command}" if sudo?
    warn("RUN: #{command}")
    return if dry_run?
    Rake.sh command
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
      # so "bin/foo" becomes "foo"
      relative_file = file.split("/")[1..-1].join("/")

      # so "bin/foo" becomes "/fully/qualified/path/to/bin/foo"
      source_file = File.expand_path(File.join(PWD, file))
      # so "foo" becomes "#{full_path_to_dest_dir}/foo"
      dest_file = File.expand_path(File.join(dest_dir, relative_file))

      sync_file source_file, dest_file, file
    end
  end

  def sync_file(source_file, dest_file, relative_file)
    if !force?
      if File.exist?(dest_file) && (File.stat(dest_file).ino == File.stat(source_file).ino)
        warn "WARN: same, skipping: #{relative_file} ⇒ #{dest_file}"
        return
      end
    end
    sh %Q{#{Commands::REMOVE_FILE} "#{dest_file}"}
    sh %Q{#{Commands::HARDLINK} "#{source_file}" "#{dest_file}"}
  end

  def default_dest_dir
    File.join HOME, source_dir
  end
end

class WholeDirectorySyncSpec < SyncSpec
  def sync!
    source_file = File.expand_path(File.join(PWD, source_dir))

    if !force?
      if File.symlink?(dest_dir) && (File.readlink(dest_dir) == source_file)
        warn "WARN: same, skipping: #{source_dir}/ → #{dest_dir}"
        return
      end
    end

    sh %Q{#{Commands::REMOVE_DIR} "#{dest_dir}"}
    sh %Q{#{Commands::SYMLINK} "#{source_file}" "#{dest_dir}"}
  end
end

# use a symlink, so I can edit locally and iterate without having to re-run setup
class PrivilegedFileSyncSpec < SyncSpec
  def initialize(source_dir, options = {})
    options[:sudo] = true
    super
  end

  def sync_file(source_file, dest_file, relative_file)
    if !force?
      if File.symlink?(dest_file) && (File.readlink(dest_file) == source_file)
        warn "WARN: same, skipping: #{relative_file} → #{dest_file}"
        return
      end
    end
    sh %Q{#{Commands::REMOVE_FILE} "#{dest_file}"}
    sh %Q{#{Commands::SYMLINK} "#{source_file}" "#{dest_file}"}
  end
end

# # todo:
# # i think this could be refactored as:
# syncer = SyncMaster.new(options)
# syncer.hardlink_dir_contents "home" # (requires remapping, e.g. ./bin → ./home/bin)
# syncer.symlink_dir_contents "etc", to: "/etc"
# syncer.symlink_dir "fontconfig"

options = Hash.new
if ARGV.include?("--force")
  options[:force] = true
end
if ARGV.include?("--dry-run")
  options[:dry_run] = true
  options[:verbose] = true
end
if ARGV.include?("--verbose")
  options[:verbose] = true
end

specs = [
  SyncSpec.new("bin", options),
  SyncSpec.new("home", options.merge(dest_dir: HOME)),
  SyncSpec.new(".gdb", options),
  SyncSpec.new(".config", options),
]

specs += [
  SyncSpec.new(".fonts", options),
  SyncSpec.new("desktop", options.merge(dest_dir: DESKTOP_DIR)),
  WholeDirectorySyncSpec.new("fontconfig", options.merge(dest_dir: File.join(HOME, ".config/fontconfig"))),
#  PrivilegedFileSyncSpec.new("etc", options.merge(dest_dir: "/etc")),
] if ENV['I_AM_LINUX'] == "1" && ENV['DISPLAY']

specs.each(&:sync!)

File.join(HOME, ".gitconfig").tap do |gitconfig_path|
  unless File.exist?(gitconfig_path)
    puts "writing new #{gitconfig_path} ..."
    File.open(gitconfig_path, "w") do |f|
      f.write(<<~EOF)
        # this is a local file with ephemeral edits.

        # the permanent, generic profile is here:
        [include]
          path = .gitconfig_generic

        # local edits follow.
      EOF
    end
  end
end
