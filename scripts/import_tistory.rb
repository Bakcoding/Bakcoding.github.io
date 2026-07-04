#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "digest"
require "fileutils"
require "json"
require "net/http"
require "openssl"
require "time"
require "uri"

SOURCE_BASE = "https://b-note.tistory.com"
POSTS_DIR = "_posts"
IMAGE_ROOT = "assets/images/posts"

TARGETS = {
  "program-language" => {
    category_path: "Program Language",
    filename_prefix: "programming",
    permalink_prefix: "programming"
  },
  "computer" => {
    category_path: "Computer",
    filename_prefix: "computer-science",
    permalink_prefix: "computer-science"
  },
  "develop" => {
    category_path: "Develop",
    filename_prefix: "develop",
    permalink_prefix: "develop"
  },
  "coding" => {
    category_path: "Coding",
    filename_prefix: "coding",
    permalink_prefix: "coding"
  }
}.freeze

CATEGORY_MAP = {
  "Program Language/C#" => {
    category: "CSharp",
    section: "csharp",
    tags: ["CSharp"]
  },
  "Program Language/Python" => {
    category: "Python",
    section: "python",
    tags: ["Python"]
  },
  "Program Language/JavaScript" => {
    category: "Javascript",
    section: "javascript",
    tags: ["JavaScript", "Web"]
  },
  "Program Language" => {
    category: "ProgrammingBasic",
    section: "programming-basics",
    tags: ["Programming", "Programming Basics"]
  },
  "Computer/Engineering" => {
    category: "ComputerEngineering",
    section: "engineering",
    tags: ["Computer Engineering", "Computer Science"]
  },
  "Computer/Network" => {
    category: "Network",
    section: "network",
    tags: ["Network", "Computer Science"]
  },
  "Computer/Graphics" => {
    category: "Graphics",
    section: "graphics",
    tags: ["Graphics", "Computer Science"]
  },
  "Computer" => {
    category: "ComputerAlgorithm",
    section: "cs-algorithms",
    tags: ["Algorithm", "Computer Science"]
  },
  "Develop/Unity" => {
    category: "Unity",
    section: "unity",
    tags: ["Unity", "Game Development"]
  },
  "Develop/Unreal" => {
    category: "Unreal",
    section: "unreal",
    tags: ["Unreal", "Game Development"]
  },
  "Develop/Server" => {
    category: "Server",
    section: "server",
    tags: ["Server", "Linux"]
  },
  "Develop/Flutter" => {
    category: "Flutter",
    section: "flutter",
    tags: ["Flutter"]
  },
  "Coding/Algorithm" => {
    category: "Algorithm",
    section: "algorithm",
    tags: ["Algorithm"]
  },
  "Coding/Coding Test" => {
    category: "CodingTest",
    section: "coding-test",
    tags: ["Coding Test", "Baekjoon"]
  }
}.freeze

def fetch(url)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "Mozilla/5.0 (compatible; GitBlogImporter/1.0)"
  request["Referer"] = SOURCE_BASE

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    response = http.request(request)
    raise "GET #{url} failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
  end
end

def fetch_binary(url)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "Mozilla/5.0 (compatible; GitBlogImporter/1.0)"
  request["Referer"] = SOURCE_BASE

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    response = http.request(request)
    raise "GET #{url} failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    [response.body, response["content-type"].to_s]
  end
end

def decode_html(value)
  CGI.unescapeHTML(value.to_s).gsub(/\u00a0/, " ").strip
end

def slugify(value)
  slug = value.downcase
              .gsub("#", "sharp")
              .gsub("+", "plus")
              .gsub(/[^a-z0-9]+/, "-")
              .gsub(/^-|-$/, "")
  slug.empty? ? "post" : slug
end

def yaml_string(value)
  '"' + value.to_s.gsub("\\", "\\\\\\").gsub('"', '\"') + '"'
end

def extract_between_balanced_div(html, marker)
  marker_index = html.index(marker)
  return nil unless marker_index

  start_index = html.rindex("<div", marker_index)
  return nil unless start_index

  index = start_index
  depth = 0
  while index < html.length
    next_open = html.index("<div", index)
    next_close = html.index("</div>", index)
    break unless next_close

    if next_open && next_open < next_close
      depth += 1
      index = next_open + 4
    else
      depth -= 1
      index = next_close + 6
      return html[start_index...index] if depth.zero?
    end
  end

  nil
end

def normalize_image_url(url)
  url = CGI.unescapeHTML(url.to_s)
  return nil if url.empty? || url.start_with?("data:")
  return "https:#{url}" if url.start_with?("//")
  return URI.join(SOURCE_BASE, url).to_s if url.start_with?("/")

  url
end

def extension_for(url, content_type)
  from_path = File.extname(URI(url).path).downcase
  return from_path if from_path.match?(/\A\.(png|jpe?g|gif|webp|svg)\z/)

  case content_type
  when /png/ then ".png"
  when /jpe?g/ then ".jpg"
  when /gif/ then ".gif"
  when /webp/ then ".webp"
  when /svg/ then ".svg"
  else ".bin"
  end
end

def download_images(content, date, source_id)
  image_dir = File.join(IMAGE_ROOT, date.strftime("%Y/%m/%d"))
  FileUtils.mkdir_p(image_dir)

  index = 0
  content.gsub(/(<img\b[^>]*\bsrc=["'])([^"']+)(["'][^>]*>)/i) do
    prefix = Regexp.last_match(1)
    raw_url = Regexp.last_match(2)
    suffix = Regexp.last_match(3)
    image_url = normalize_image_url(raw_url)
    next Regexp.last_match(0) unless image_url

    index += 1
    begin
      body, content_type = fetch_binary(image_url)
      ext = extension_for(image_url, content_type)
      filename = "#{source_id}-#{index}#{ext}"
      local_path = File.join(image_dir, filename)
      File.binwrite(local_path, body)
      "#{prefix}/#{local_path}#{suffix}"
    rescue StandardError => e
      warn "image skipped #{image_url}: #{e.message}"
      Regexp.last_match(0)
    end
  end
end

def extract_tags(html)
  tags = html.scan(%r{<a href="/tag/[^"]+" rel="tag">([^<]+)</a>}).flatten
  tags.map { |tag| decode_html(tag) }.reject(&:empty?)
end

def clean_content(content)
  content = content.sub(/\A<div[^>]*class="tt_article_useless_p_margin contents_style"[^>]*>/, "")
                   .sub(%r{</div>\s*\z}, "")
  content.gsub!(/\sdata-ke-[a-z-]+="[^"]*"/, "")
  content.gsub!(/\s(?:srcset|data-url|data-phocus|data-og-image|data-video-thumbnail|onerror)="[^"]*"/, "")
  content.gsub!(/\sstyle="background-image:\s*url\('[^']*blog\.kakaocdn\.net[^']*'\);"/, "")
  content.gsub!(/\sid="code_[^"]*"/, "")
  content.gsub!(/<p>\s*(?:&nbsp;|\s)*\s*<\/p>/, "")
  content.gsub!(/<br\s*\/?>\s*(<br\s*\/?>\s*)+/i, "<br>")
  content.strip
end

def parse_article(source_id, target)
  source_url = "#{SOURCE_BASE}/#{source_id}"
  html = fetch(source_url)
  entry_info = html[/window\.T\.entryInfo = (\{.*?\});/, 1]
  entry = entry_info ? JSON.parse(entry_info) : {}
  category_label = entry["categoryLabel"].to_s
  mapping = CATEGORY_MAP[category_label]
  warn "unmapped #{source_id}: #{category_label}" unless mapping
  return nil unless mapping

  title = decode_html(html[%r{<div class="post-cover"[^>]*>.*?<h1>(.*?)</h1>}m, 1] || entry["title"])
  date_text = html[/datePublished":"([^"]+)"/, 1]
  date = date_text ? Time.parse(date_text).to_date : Date.today
  content = extract_between_balanced_div(html, 'class="tt_article_useless_p_margin contents_style"')
  raise "content not found for #{source_url}" unless content

  content = clean_content(content)
  content = download_images(content, date, source_id)
  source_tags = extract_tags(html)
  slug = "#{source_id}-#{slugify(title)}"
  section = mapping.fetch(:section)

  {
    source_id: source_id,
    source_url: source_url,
    title: title,
    date: date,
    category: mapping.fetch(:category),
    permalink: "/#{target.fetch(:permalink_prefix)}/#{section}/#{slug}/",
    tags: (mapping.fetch(:tags) + source_tags).reject { |tag| slugify(tag).empty? }.uniq,
    slug: slug,
    section: section,
    filename_prefix: target.fetch(:filename_prefix),
    content: content
  }
end

def article_ids(target)
  ids = []
  1.upto(50) do |page|
    encoded = CGI.escape(target.fetch(:category_path)).gsub("+", "%20")
    html = fetch("#{SOURCE_BASE}/category/#{encoded}?page=#{page}")
    page_ids = html.scan(%r{<div class="post-item">\s*<a href="/(\d+)"}).flatten
    break if page_ids.empty?

    ids.concat(page_ids)
    break if page_ids.size < 6
  end
  ids.uniq
end

def already_imported?(source_url)
  needle = "source_url: #{source_url}\n"
  Dir.glob(File.join(POSTS_DIR, "*.md")).any? do |path|
    File.read(path).include?(needle)
  end
end

def write_post(article)
  filename = "#{article[:date].strftime("%Y-%m-%d")}-#{article[:filename_prefix]}-#{article[:section]}-#{article[:slug]}.md"
  path = File.join(POSTS_DIR, filename)
  return [:skipped, path] if File.exist?(path) || already_imported?(article[:source_url])

  front_matter = [
    "---",
    "title: #{yaml_string(article[:title])}",
    "excerpt: #{yaml_string(article[:title])}",
    "categories:",
    "  - #{article[:category]}",
    "permalink: #{article[:permalink]}",
    "tags:",
    *article[:tags].map { |tag| "  - #{yaml_string(tag)}" },
    "toc: true",
    "toc_sticky: true",
    "date: #{article[:date].strftime("%Y-%m-%d")}",
    "last_modified_at: #{article[:date].strftime("%Y-%m-%d")}",
    "source_url: #{article[:source_url]}",
    "---",
    "",
    article[:content],
    ""
  ].join("\n")

  File.write(path, front_matter)
  [:created, path]
end

target_name = ARGV[0] || "program-language"
target = TARGETS[target_name]

unless target
  warn "unknown target: #{target_name}"
  warn "available targets: #{TARGETS.keys.join(", ")}"
  exit 1
end

ids = article_ids(target)
puts "found #{ids.size} article(s)"

created = []
skipped = []
failed = []

ids.each do |source_id|
  begin
    article = parse_article(source_id, target)
    next unless article

    status, path = write_post(article)
    status == :created ? created << path : skipped << path
    puts "#{status} #{source_id} #{article[:category]} #{article[:title]}"
  rescue StandardError => e
    failed << [source_id, e.message]
    warn "failed #{source_id}: #{e.message}"
  end
end

puts "created #{created.size}, skipped #{skipped.size}, failed #{failed.size}"
failed.each { |source_id, message| warn "failed #{source_id}: #{message}" }
exit(failed.empty? ? 0 : 1)
