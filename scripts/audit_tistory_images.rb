#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "net/http"
require "uri"

SOURCE_BASE = "https://b-note.tistory.com"

def fetch(url)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "Mozilla/5.0 (compatible; GitBlogImageAudit/1.0)"
  request["Referer"] = SOURCE_BASE

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    response = http.request(request)
    raise "GET #{url} failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
  end
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

def image_sources(html)
  img_sources = html.scan(%r{<img\b[^>]*\bsrc=["']([^"']+)["'][^>]*>}i).flatten
  background_sources = html.scan(%r{background-image:\s*url\(["']?([^"')]+)["']?\)}i).flatten

  (img_sources + background_sources)
    .map { |source| CGI.unescapeHTML(source.to_s) }
    .reject { |source| source.empty? || source.start_with?("data:") }
    .uniq
end

rows = []

Dir["_posts/*.md"].sort.each do |path|
  raw = File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace)
  source_url = raw[/^source_url:\s*(https:\/\/b-note\.tistory\.com\/\d+)\s*$/, 1]
  next unless source_url

  source_id = source_url.split("/").last.to_i

  begin
    html = fetch(source_url)
    content = extract_between_balanced_div(html, 'class="tt_article_useless_p_margin contents_style"') || html
    remote_count = image_sources(content).length
    local_count = raw.scan(%r{<img\b[^>]*\bsrc=["']/assets/images/posts/[^"']+["']}i).length
    external_count = raw.scan(%r{<img\b[^>]*\bsrc=["']https?://[^"']+["']}i).length

    rows << [source_id, path, remote_count, local_count, external_count] if remote_count != local_count || external_count.positive?
  rescue StandardError => e
    rows << [source_id, path, "ERR", e.message, 0]
  end
end

rows.sort_by! { |source_id, _path, _remote_count, _local_count, _external_count| source_id.to_i }

puts "mismatches=#{rows.length}"
rows.each do |source_id, path, remote_count, local_count, external_count|
  puts [source_id, path, remote_count, local_count, external_count].join("\t")
end
