#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "optparse"
require "yaml"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

ROOT = File.expand_path("..", __dir__)
CATEGORY_GROUPS_PATH = File.join(ROOT, "_data", "category_groups.yml")
POSTS_DIR = File.join(ROOT, "_posts")
TEMPLATES = {
  "study" => File.join(ROOT, "_templates", "post-study.md"),
  "memo" => File.join(ROOT, "_templates", "post-memo.md")
}.freeze

def slugify(value)
  value.to_s
       .downcase
       .gsub(/[_\s,]+/, "-")
       .gsub(/[^a-z0-9-]+/, "-")
       .gsub(/-+/, "-")
       .gsub(/^-|-$/, "")
end

def utf8(value)
  value.to_s.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
end

def load_categories
  groups = YAML.safe_load(File.read(CATEGORY_GROUPS_PATH), aliases: true) || []
  groups.map { |group| group.fetch("title") }
end

def template_body(kind)
  path = TEMPLATES.fetch(kind)
  raw = File.read(path)
  parts = raw.split(/^---\s*$/, 3)
  parts.length >= 3 ? parts[2].sub(/\A\n/, "") : raw
end

def next_number(main_slug, sub_slug)
  pattern = File.join(POSTS_DIR, "*-#{main_slug}-#{sub_slug}-[0-9][0-9][0-9]-*.md")
  numbers = Dir[pattern].map do |path|
    match = File.basename(path).match(/-#{Regexp.escape(main_slug)}-#{Regexp.escape(sub_slug)}-(\d{3})-/)
    match ? match[1].to_i : nil
  end.compact
  max = numbers.max
  (max || 0) + 1
end

def existing_permalink?(permalink)
  Dir[File.join(POSTS_DIR, "*.md")].any? do |path|
    File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace).match?(/^permalink:\s*#{Regexp.escape(permalink)}\s*$/)
  end
end

def yaml_list(values)
  values.map { |value| "  - #{value}" }.join("\n")
end

options = {
  kind: "study",
  date: Date.today,
  tags: [],
  dry_run: false,
  assets: true
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/new_post.rb --title TITLE --category CATEGORY --slug SLUG [options]"

  opts.on("--kind KIND", "Template kind: study or memo. Default: study") { |v| options[:kind] = v }
  opts.on("--title TITLE", "Post title") { |v| options[:title] = v }
  opts.on("--excerpt TEXT", "Post excerpt") { |v| options[:excerpt] = v }
  opts.on("--category CATEGORY", "Top-level category") { |v| options[:category] = v }
  opts.on("--tags TAGS", "Comma-separated tags") { |v| options[:tags] = v.split(",").map(&:strip).reject(&:empty?) }
  opts.on("--sub SUB", "Filename sub group. Default: first tag or general") { |v| options[:sub] = v }
  opts.on("--slug SLUG", "URL and filename slug") { |v| options[:slug] = v }
  opts.on("--series SERIES", "Series key") { |v| options[:series] = v }
  opts.on("--series-order N", Integer, "Series order") { |v| options[:series_order] = v }
  opts.on("--number N", Integer, "Filename sequence number override") { |v| options[:number] = v }
  opts.on("--date DATE", "Publish date YYYY-MM-DD. Default: today") { |v| options[:date] = Date.parse(v) }
  opts.on("--no-assets", "Do not create image asset directory") { options[:assets] = false }
  opts.on("--dry-run", "Print result without writing files") { options[:dry_run] = true }
  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end

parser.parse!

abort "Unknown template kind: #{options[:kind]}" unless TEMPLATES.key?(options[:kind])
abort "--title is required" if options[:title].to_s.strip.empty?
abort "--category is required" if options[:category].to_s.strip.empty?

allowed_categories = load_categories
unless allowed_categories.include?(options[:category])
  abort "Unknown category: #{options[:category]}\nAllowed categories: #{allowed_categories.join(', ')}"
end

title = utf8(options[:title]).strip
excerpt = utf8(options[:excerpt]).strip
excerpt = "#{title} 내용을 정리한다." if excerpt.empty?

main_slug = slugify(options[:category])
sub_slug = slugify(options[:sub] || options[:tags].first || "general")
abort "Could not derive sub slug. Use --sub." if sub_slug.empty?

slug = slugify(options[:slug] || title)
abort "Could not derive slug from title. Use --slug with lowercase English words." if slug.empty?

number = options[:number] || next_number(main_slug, sub_slug)
abort "--number must be between 1 and 999" unless number.between?(1, 999)

date = options[:date]
date_text = date.strftime("%Y-%m-%d")
filename = "#{date_text}-#{main_slug}-#{sub_slug}-#{format('%03d', number)}-#{slug}.md"
post_path = File.join(POSTS_DIR, filename)
permalink = "/#{main_slug}/#{slug}/"
asset_dir = File.join(ROOT, "assets", "images", "posts", date.strftime("%Y"), date.strftime("%m"), date.strftime("%d"))
asset_url = "/assets/images/posts/#{date.strftime('%Y/%m/%d')}"

abort "Post already exists: #{post_path}" if File.exist?(post_path)
abort "Permalink already exists: #{permalink}" if existing_permalink?(permalink)

front_matter = [
  "---",
  %(title: "#{title.gsub('"', '\"')}"),
  %(excerpt: "#{excerpt.gsub('"', '\"')}"),
  "categories:",
  "  - #{options[:category]}",
  "tags:",
  (options[:tags].empty? ? "  - General" : yaml_list(options[:tags])),
  ("series: #{options[:series]}" if options[:series]),
  ("series_order: #{options[:series_order]}" if options[:series_order]),
  "permalink: #{permalink}",
  "toc: true",
  "toc_sticky: true",
  "date: #{date_text}",
  "last_modified_at: #{date_text}",
  "---"
].compact.join("\n")

body = template_body(options[:kind])
body = body.gsub("YYYY/MM/DD", date.strftime("%Y/%m/%d"))
           .gsub("YYYY-MM-DD", date_text)
           .gsub("/assets/images/posts/#{date.strftime('%Y/%m/%d')}", asset_url)

content = "#{front_matter}\n\n#{body}"

puts "Post: #{post_path}"
puts "Permalink: #{permalink}"
puts "Assets: #{asset_dir}" if options[:assets]

if options[:dry_run]
  puts "\n--- preview ---"
  puts content.lines.first(60).join
  exit
end

FileUtils.mkdir_p(POSTS_DIR)
FileUtils.mkdir_p(asset_dir) if options[:assets]
File.write(post_path, content)

puts "Created post."
