#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "net/http"
require "time"
require "uri"

SOURCE_BASE = "https://b-note.tistory.com"
IMAGE_ROOT = "assets/images/posts"

DRY_RUN = ARGV.include?("--dry-run")

def fetch(url)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "Mozilla/5.0 (compatible; GitBlogImageRepair/1.0)"
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
  request["User-Agent"] = "Mozilla/5.0 (compatible; GitBlogImageRepair/1.0)"
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

def extension_for(url, content_type, body)
  from_path = File.extname(URI(url).path).downcase
  return from_path if from_path.match?(/\A\.(png|jpe?g|gif|webp|svg)\z/)

  return ".png" if body.start_with?("\x89PNG".b)
  return ".gif" if body.start_with?("GIF8".b)
  return ".jpg" if body.start_with?("\xFF\xD8".b)
  return ".webp" if body[8, 4] == "WEBP"
  return ".svg" if body.lstrip.start_with?("<svg")

  case content_type
  when /png/ then ".png"
  when /jpe?g/ then ".jpg"
  when /gif/ then ".gif"
  when /webp/ then ".webp"
  when /svg/ then ".svg"
  else ".bin"
  end
end

def image_entries(content)
  entries = []

  content.scan(%r{<figure\b.*?</figure>}mi).each do |figure|
    img_tag = figure[/<img\b[^>]*>/i]
    next unless img_tag

    src = img_tag[/\bsrc=["']([^"']+)["']/i, 1]
    caption = decode_html(figure[%r{<figcaption[^>]*>(.*?)</figcaption>}mi, 1])
    alt = decode_html(figure[/\bdata-alt=["']([^"']+)["']/i, 1])
    width = img_tag[/\bwidth=["']([^"']+)["']/i, 1]
    height = img_tag[/\bheight=["']([^"']+)["']/i, 1]

    entries << {
      url: normalize_image_url(src),
      caption: caption.empty? ? alt : caption,
      width: width,
      height: height
    }.compact
  end

  if entries.empty?
    content.scan(/<img\b[^>]*>/i).each do |img_tag|
      src = img_tag[/\bsrc=["']([^"']+)["']/i, 1]
      width = img_tag[/\bwidth=["']([^"']+)["']/i, 1]
      height = img_tag[/\bheight=["']([^"']+)["']/i, 1]
      entries << { url: normalize_image_url(src), width: width, height: height }.compact
    end
  end

  entries.reject { |entry| entry[:url].to_s.empty? }
end

def next_image_path(date, source_id, ext)
  image_dir = File.join(IMAGE_ROOT, date.strftime("%Y/%m/%d"))
  FileUtils.mkdir_p(image_dir)
  existing_numbers = Dir[File.join(image_dir, "#{source_id}-*.*")]
                     .map { |path| File.basename(path)[/\A#{Regexp.escape(source_id)}-(\d+)\./, 1] }
                     .compact
                     .map(&:to_i)
  number = existing_numbers.max.to_i + 1
  File.join(image_dir, "#{source_id}-#{number}#{ext}")
end

def figure_html(local_path, entry, caption)
  width = entry[:width]
  height = entry[:height]
  size_attrs = [width && %(width="#{width}"), height && %(height="#{height}")].compact.join(" ")
  figcaption = caption.to_s.empty? ? "" : "<figcaption>#{CGI.escapeHTML(caption)}</figcaption>"

  <<~HTML.strip
    <p><figure class="imageblock alignLeft">#{figcaption.empty? ? "" : "<span data-alt=\"#{CGI.escapeHTML(caption)}\">"}<img src="/#{local_path}" loading="lazy" #{size_attrs}/>#{figcaption.empty? ? "" : "</span>#{figcaption}"}</figure></p>
  HTML
end

placeholder_pattern = />\s*용량 문제로\s*(?:`([^`]+)`\s*)?(?:해당\s*)?(?:애니메이션\s*)?이미지는\s*\[원문\]\([^)]+\)에서 확인한다\.\s*(?:<\/figure>\s*)?(?:<\/p>)?/m

Dir["_posts/*.md"].sort.each do |path|
  raw = File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace)
  next unless raw.match?(placeholder_pattern)

  source_url = raw[/^source_url:\s*(https:\/\/b-note\.tistory\.com\/(\d+))\s*$/, 1]
  source_id = raw[/^source_url:\s*https:\/\/b-note\.tistory\.com\/(\d+)\s*$/, 1]
  date = Date.parse(raw[/^date:\s*(\d{4}-\d{2}-\d{2})\s*$/, 1])
  raise "source_url not found: #{path}" unless source_url && source_id

  html = fetch(source_url)
  content = extract_between_balanced_div(html, 'class="tt_article_useless_p_margin contents_style"') || html
  entries = image_entries(content)
  used_indexes = []
  replacements = []

  raw.scan(placeholder_pattern).each do |caption_match|
    placeholder_caption = decode_html(caption_match.first)
    index = entries.each_index.find do |candidate_index|
      next false if used_indexes.include?(candidate_index)

      entry_caption = entries[candidate_index][:caption].to_s
      placeholder_caption.empty? || entry_caption.empty? || entry_caption.include?(placeholder_caption) || placeholder_caption.include?(entry_caption)
    end
    index ||= entries.each_index.find { |candidate_index| !used_indexes.include?(candidate_index) }
    raise "no remote image for #{path}: #{placeholder_caption}" unless index

    used_indexes << index
    replacements << [placeholder_caption, entries[index]]
  end

  puts "#{DRY_RUN ? "would repair" : "repair"} #{path} placeholders=#{replacements.length}"
  replacements.each { |caption, entry| puts "  - #{caption.empty? ? "(no caption)" : caption} <= #{entry[:caption]} #{entry[:url]}" }
  next if DRY_RUN

  replacement_index = 0
  updated = raw.gsub(placeholder_pattern) do
    caption, entry = replacements.fetch(replacement_index)
    replacement_index += 1

    body, content_type = fetch_binary(entry.fetch(:url))
    ext = extension_for(entry.fetch(:url), content_type, body)
    local_path = next_image_path(date, source_id, ext)
    File.binwrite(local_path, body)
    "\n#{figure_html(local_path, entry, caption.empty? ? entry[:caption] : caption)}"
  end

  File.write(path, updated, encoding: "UTF-8")
end
