#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "date"
require "fileutils"
require "json"
require "open3"
require "shellwords"
require "webrick"
require "yaml"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

ROOT = File.expand_path("..", __dir__)
CATEGORY_GROUPS_PATH = File.join(ROOT, "_data", "category_groups.yml")
POSTS_DIR = File.join(ROOT, "_posts")
IMAGE_ROOT = File.join(ROOT, "assets", "images", "posts")
TEMPLATES = {
  "study" => File.join(ROOT, "_templates", "post-study.md"),
  "memo" => File.join(ROOT, "_templates", "post-memo.md")
}.freeze
ALLOWED_IMAGE_TYPES = {
  "image/png" => ".png",
  "image/jpeg" => ".jpg",
  "image/gif" => ".gif",
  "image/webp" => ".webp"
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

def json_response(response, status, payload)
  response.status = status
  response["Content-Type"] = "application/json; charset=utf-8"
  response.body = JSON.pretty_generate(payload)
end

def parse_json(request)
  JSON.parse(request.body.to_s)
rescue JSON::ParserError => error
  raise ArgumentError, "Invalid JSON: #{error.message}"
end

def load_category_groups
  YAML.safe_load(File.read(CATEGORY_GROUPS_PATH), aliases: true) || []
end

def top_categories
  load_category_groups.map { |group| group.fetch("title") }
end

def template_body(kind)
  raw = File.read(TEMPLATES.fetch(kind), encoding: "UTF-8")
  parts = raw.split(/^---\s*$/, 3)
  parts.length >= 3 ? parts[2].sub(/\A\n/, "") : raw
end

def yaml_list(values)
  values.map { |value| "  - #{value}" }.join("\n")
end

def next_number(main_slug, sub_slug)
  pattern = File.join(POSTS_DIR, "*-#{main_slug}-#{sub_slug}-[0-9][0-9][0-9]-*.md")
  numbers = Dir[pattern].map do |path|
    match = File.basename(path).match(/-#{Regexp.escape(main_slug)}-#{Regexp.escape(sub_slug)}-(\d{3})-/)
    match && match[1].to_i
  end.compact
  (numbers.max || 0) + 1
end

def existing_permalink?(permalink)
  Dir[File.join(POSTS_DIR, "*.md")].any? do |path|
    File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace).match?(/^permalink:\s*#{Regexp.escape(permalink)}\s*$/)
  end
end

def safe_image_name(name, index, content_type)
  ext = File.extname(name.to_s).downcase
  ext = ALLOWED_IMAGE_TYPES[content_type] if ext.empty?
  ext = ".png" unless ALLOWED_IMAGE_TYPES.value?(ext)
  base = File.basename(name.to_s, ".*")
  base = slugify(base)
  base = "image-#{index + 1}" if base.empty?
  "#{base}#{ext}"
end

def run_command(command)
  stdout, stderr, status = Open3.capture3(command, chdir: ROOT)
  {
    ok: status.success?,
    status: status.exitstatus,
    output: [stdout, stderr].reject(&:empty?).join("\n")
  }
end

def build_post(payload)
  kind = payload.fetch("kind", "study")
  raise ArgumentError, "Unknown template kind: #{kind}" unless TEMPLATES.key?(kind)

  title = utf8(payload["title"]).strip
  raise ArgumentError, "Title is required" if title.empty?

  category = utf8(payload["category"]).strip
  allowed_categories = top_categories
  unless allowed_categories.include?(category)
    raise ArgumentError, "Unknown category: #{category}. Allowed: #{allowed_categories.join(', ')}"
  end

  tags = Array(payload["tags"]).map { |tag| utf8(tag).strip }.reject(&:empty?)
  tags = ["General"] if tags.empty?
  excerpt = utf8(payload["excerpt"]).strip
  excerpt = "#{title} 내용을 정리한다." if excerpt.empty?

  date = payload["date"].to_s.strip.empty? ? Date.today : Date.parse(payload["date"].to_s)
  date_text = date.strftime("%Y-%m-%d")
  main_slug = slugify(category)
  sub_slug = slugify(payload["sub"].to_s.empty? ? tags.first : payload["sub"])
  raise ArgumentError, "Sub slug is required" if sub_slug.empty?

  slug = slugify(payload["slug"].to_s.empty? ? title : payload["slug"])
  raise ArgumentError, "Slug is required. Use lowercase English words." if slug.empty?

  number = payload["number"].to_s.strip.empty? ? next_number(main_slug, sub_slug) : payload["number"].to_i
  raise ArgumentError, "Number must be between 1 and 999" unless number.between?(1, 999)

  filename = "#{date_text}-#{main_slug}-#{sub_slug}-#{format('%03d', number)}-#{slug}.md"
  post_path = File.join(POSTS_DIR, filename)
  permalink = "/#{main_slug}/#{slug}/"
  asset_dir = File.join(IMAGE_ROOT, date.strftime("%Y"), date.strftime("%m"), date.strftime("%d"))
  asset_url = "/assets/images/posts/#{date.strftime('%Y/%m/%d')}"

  raise ArgumentError, "Post already exists: #{filename}" if File.exist?(post_path)
  raise ArgumentError, "Permalink already exists: #{permalink}" if existing_permalink?(permalink)

  body = utf8(payload["body"]).strip
  body = template_body(kind).gsub("YYYY/MM/DD", date.strftime("%Y/%m/%d")).strip if body.empty?

  front_matter = [
    "---",
    %(title: "#{title.gsub('"', '\"')}"),
    %(excerpt: "#{excerpt.gsub('"', '\"')}"),
    "categories:",
    "  - #{category}",
    "tags:",
    yaml_list(tags),
    "permalink: #{permalink}",
    "toc: true",
    "toc_sticky: true",
    "date: #{date_text}",
    "last_modified_at: #{date_text}",
    "---"
  ].join("\n")

  {
    date: date,
    filename: filename,
    post_path: post_path,
    permalink: permalink,
    asset_dir: asset_dir,
    asset_url: asset_url,
    content: "#{front_matter}\n\n#{body}\n"
  }
end

def save_images(images, asset_dir)
  FileUtils.mkdir_p(asset_dir)
  Array(images).each_with_index do |image, index|
    content_type = image["type"].to_s
    raise ArgumentError, "Unsupported image type: #{content_type}" unless ALLOWED_IMAGE_TYPES.key?(content_type)

    data = image["data"].to_s.sub(%r{\Adata:[^;]+;base64,}, "")
    bytes = Base64.decode64(data)
    raise ArgumentError, "Image is empty: #{image['name']}" if bytes.empty?

    image_path = File.join(asset_dir, safe_image_name(image["name"], index, content_type))
    File.write(image_path, bytes, mode: "wb")
  end
end

HTML = <<~HTML
  <!doctype html>
  <html lang="ko">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bakcoding Blog Admin</title>
    <style>
      :root {
        --bg: #f6f7f4;
        --panel: #ffffff;
        --text: #24262b;
        --muted: #6e756f;
        --line: #dfe4df;
        --accent: #24706b;
        --accent-dark: #18534f;
        --danger: #a13c3c;
      }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        color: var(--text);
        background: var(--bg);
        font-family: "Nanum Gothic", "Apple SD Gothic Neo", "Malgun Gothic", system-ui, sans-serif;
      }
      header {
        position: sticky;
        top: 0;
        z-index: 5;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
        padding: 0.8rem 1rem;
        border-bottom: 1px solid var(--line);
        background: rgba(246, 247, 244, 0.96);
      }
      h1 { margin: 0; font-size: 1rem; }
      button, input, select, textarea {
        font: inherit;
      }
      button {
        border: 1px solid var(--line);
        border-radius: 6px;
        padding: 0.45rem 0.7rem;
        background: var(--panel);
        color: var(--text);
        cursor: pointer;
      }
      button.primary {
        color: #fff;
        border-color: var(--accent);
        background: var(--accent);
      }
      button.primary:hover { background: var(--accent-dark); }
      button.danger { color: var(--danger); }
      main {
        display: grid;
        grid-template-columns: 340px minmax(0, 1fr) minmax(360px, 0.9fr);
        gap: 1rem;
        padding: 1rem;
      }
      section {
        min-width: 0;
        border: 1px solid var(--line);
        border-radius: 8px;
        background: var(--panel);
      }
      .panel-title {
        margin: 0;
        padding: 0.75rem 0.9rem;
        border-bottom: 1px solid var(--line);
        font-size: 0.85rem;
        color: var(--muted);
      }
      .fields, .tools, .status {
        display: grid;
        gap: 0.75rem;
        padding: 0.9rem;
      }
      label { display: grid; gap: 0.3rem; font-size: 0.82rem; color: var(--muted); }
      input, select, textarea {
        width: 100%;
        border: 1px solid var(--line);
        border-radius: 6px;
        padding: 0.5rem;
        color: var(--text);
        background: #fff;
      }
      textarea {
        min-height: calc(100vh - 160px);
        resize: vertical;
        line-height: 1.6;
        font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      }
      .row { display: grid; grid-template-columns: 1fr 1fr; gap: 0.6rem; }
      .button-row { display: flex; flex-wrap: wrap; gap: 0.5rem; }
      .preview {
        padding: 1rem;
        line-height: 1.7;
        overflow-wrap: anywhere;
      }
      .preview h2 { margin-top: 1.2rem; border-bottom: 1px solid var(--line); padding-bottom: 0.3rem; }
      .preview pre { overflow: auto; padding: 0.8rem; background: #f0f3f1; border-radius: 6px; }
      .preview img { max-width: 100%; height: auto; display: block; margin: 0.5rem auto; }
      .preview figure { margin: 1rem auto; text-align: center; }
      .preview figcaption { color: var(--muted); font-size: 0.85rem; }
      .log {
        max-height: 180px;
        overflow: auto;
        white-space: pre-wrap;
        border: 1px solid var(--line);
        border-radius: 6px;
        padding: 0.6rem;
        background: #f9faf8;
        font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
        font-size: 0.78rem;
      }
      .hint { color: var(--muted); font-size: 0.78rem; line-height: 1.5; }
      @media (max-width: 1100px) {
        main { grid-template-columns: 1fr; }
        textarea { min-height: 45vh; }
      }
    </style>
  </head>
  <body>
    <header>
      <h1>Bakcoding Blog Admin</h1>
      <div class="button-row">
        <button id="buildBtn">빌드 확인</button>
        <button id="statusBtn">Git 상태</button>
        <button class="primary" id="pushBtn">커밋/푸시</button>
      </div>
    </header>
    <main>
      <section>
        <h2 class="panel-title">글 정보</h2>
        <div class="fields">
          <label>종류
            <select id="kind">
              <option value="study">study</option>
              <option value="memo">memo</option>
            </select>
          </label>
          <label>제목 <input id="title" placeholder="예: C# 델리게이트 기본"></label>
          <label>요약 <input id="excerpt" placeholder="검색/목록에 표시될 한 문장"></label>
          <div class="row">
            <label>카테고리 <select id="category"></select></label>
            <label>세부 파일명 <input id="sub" placeholder="예: csharp"></label>
          </div>
          <label>태그 <input id="tags" placeholder="예: CSharp, Delegate"></label>
          <div class="row">
            <label>슬러그 <input id="slug" placeholder="예: csharp-delegate-basic"></label>
            <label>날짜 <input id="date" type="date"></label>
          </div>
          <label>이미지 추가 <input id="imageInput" type="file" accept="image/png,image/jpeg,image/gif,image/webp" multiple></label>
          <div class="button-row">
            <button id="templateBtn">템플릿 넣기</button>
            <button id="imageBtn">이미지 삽입</button>
            <button class="primary" id="saveBtn">로컬 저장</button>
          </div>
          <p class="hint">이미지는 본문 커서 위치에 figure 태그로 삽입된다. 저장 시 날짜별 이미지 폴더로 같이 저장된다.</p>
        </div>
      </section>
      <section>
        <h2 class="panel-title">본문 Markdown</h2>
        <textarea id="body" placeholder="여기에 글을 작성한다."></textarea>
      </section>
      <section>
        <h2 class="panel-title">미리보기 / 로그</h2>
        <div class="preview" id="preview"></div>
        <div class="status">
          <label>커밋 메시지 <input id="commitMessage" value="Add blog post"></label>
          <div class="log" id="log">대기 중</div>
        </div>
      </section>
    </main>
    <script>
      const $ = (id) => document.getElementById(id);
      const images = [];
      const today = new Date().toISOString().slice(0, 10);
      $("date").value = today;

      function slugify(value) {
        return String(value || "")
          .toLowerCase()
          .replace(/[_,\\s]+/g, "-")
          .replace(/[^a-z0-9-]+/g, "-")
          .replace(/-+/g, "-")
          .replace(/^-|-$/g, "");
      }

      function tags() {
        return $("tags").value.split(",").map((tag) => tag.trim()).filter(Boolean);
      }

      function assetUrl() {
        return `/assets/images/posts/${$("date").value.replaceAll("-", "/")}`;
      }

      function log(message) {
        $("log").textContent = typeof message === "string" ? message : JSON.stringify(message, null, 2);
      }

      async function api(path, payload) {
        const response = await fetch(path, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload || {})
        });
        const data = await response.json();
        if (!response.ok || data.ok === false) throw new Error(data.error || data.output || "Request failed");
        return data;
      }

      function insertAtCursor(textarea, text) {
        const start = textarea.selectionStart;
        const end = textarea.selectionEnd;
        textarea.value = textarea.value.slice(0, start) + text + textarea.value.slice(end);
        textarea.selectionStart = textarea.selectionEnd = start + text.length;
        textarea.focus();
        renderPreview();
      }

      function renderPreview() {
        let html = $("body").value
          .replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;");
        html = html.replace(/^## (.+)$/gm, "<h2>$1</h2>")
          .replace(/^### (.+)$/gm, "<h3>$1</h3>")
          .replace(/```([\\s\\S]*?)```/g, "<pre><code>$1</code></pre>")
          .replace(/\\*\\*(.+?)\\*\\*/g, "<strong>$1</strong>")
          .replace(/\\n\\n/g, "</p><p>");
        html = `<p>${html}</p>`;
        html = html.replace(/&lt;figure([\\s\\S]*?)&lt;\\/figure&gt;/g, (match) =>
          match.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"')
        );
        html = html.replace(/src="([^"]+)"/g, (match, src) => {
          const image = images.find((item) => src.endsWith("/" + item.safeName));
          return image ? `src="${image.data}"` : match;
        });
        $("preview").innerHTML = html;
      }

      function payload() {
        return {
          kind: $("kind").value,
          title: $("title").value,
          excerpt: $("excerpt").value,
          category: $("category").value,
          sub: $("sub").value,
          tags: tags(),
          slug: $("slug").value,
          date: $("date").value,
          body: $("body").value,
          images: images.map(({ name, type, data }) => ({ name, type, data }))
        };
      }

      async function loadCategories() {
        const response = await fetch("/api/categories");
        const data = await response.json();
        $("category").innerHTML = data.categories.map((category) => `<option>${category}</option>`).join("");
      }

      $("title").addEventListener("input", () => {
        if (!$("slug").dataset.touched) $("slug").value = slugify($("title").value);
      });
      $("slug").addEventListener("input", () => { $("slug").dataset.touched = "true"; });
      $("body").addEventListener("input", renderPreview);

      $("templateBtn").addEventListener("click", async () => {
        const response = await fetch(`/api/template?kind=${encodeURIComponent($("kind").value)}&date=${encodeURIComponent($("date").value)}`);
        const data = await response.json();
        $("body").value = data.body;
        renderPreview();
      });

      $("imageInput").addEventListener("change", async (event) => {
        for (const file of event.target.files) {
          const data = await new Promise((resolve) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.readAsDataURL(file);
          });
          const safeName = slugify(file.name.replace(/\\.[^.]+$/, "")) + file.name.match(/\\.[^.]+$/)[0].toLowerCase();
          images.push({ name: file.name, safeName, type: file.type, data });
        }
        log(`${images.length}개 이미지 준비됨`);
      });

      $("imageBtn").addEventListener("click", () => {
        if (images.length === 0) return log("먼저 이미지를 선택해야 한다.");
        const image = images[images.length - 1];
        const size = prompt("이미지 크기: small, medium, large", "medium") || "medium";
        const alt = prompt("alt / caption", image.name) || image.name;
        insertAtCursor($("body"), `\\n<figure class="post-image post-image--${size}">\\n  <img src="${assetUrl()}/${image.safeName}" alt="${alt}">\\n  <figcaption>${alt}</figcaption>\\n</figure>\\n`);
      });

      $("saveBtn").addEventListener("click", async () => {
        try {
          const data = await api("/api/save", payload());
          log(`저장 완료\\nPost: ${data.filename}\\nPermalink: ${data.permalink}`);
        } catch (error) {
          log(error.message);
        }
      });

      $("buildBtn").addEventListener("click", async () => {
        try {
          log("빌드 중...");
          const data = await api("/api/build");
          log(data.output || "빌드 성공");
        } catch (error) {
          log(error.message);
        }
      });

      $("statusBtn").addEventListener("click", async () => {
        try {
          const data = await api("/api/git-status");
          log(data.output);
        } catch (error) {
          log(error.message);
        }
      });

      $("pushBtn").addEventListener("click", async () => {
        const message = $("commitMessage").value.trim();
        if (!message) return log("커밋 메시지가 필요하다.");
        if (!confirm("현재 변경사항을 커밋하고 origin/master로 푸시할까?")) return;
        try {
          log("커밋/푸시 중...");
          const data = await api("/api/commit-push", { message });
          log(data.output);
        } catch (error) {
          log(error.message);
        }
      });

      loadCategories();
      renderPreview();
    </script>
  </body>
  </html>
HTML

class BlogAdminServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    case request.path
    when "/"
      response["Content-Type"] = "text/html; charset=utf-8"
      response.body = HTML
    when "/api/categories"
      json_response(response, 200, categories: top_categories, groups: load_category_groups)
    when "/api/template"
      kind = request.query["kind"] || "study"
      date = request.query["date"].to_s.empty? ? Date.today : Date.parse(request.query["date"].to_s)
      body = template_body(kind).gsub("YYYY/MM/DD", date.strftime("%Y/%m/%d")).gsub("YYYY-MM-DD", date.strftime("%Y-%m-%d"))
      json_response(response, 200, body: body)
    else
      json_response(response, 404, ok: false, error: "Not found")
    end
  rescue StandardError => error
    json_response(response, 500, ok: false, error: error.message)
  end

  def do_POST(request, response)
    case request.path
    when "/api/save"
      post = build_post(parse_json(request))
      save_images(JSON.parse(request.body.to_s)["images"], post[:asset_dir])
      FileUtils.mkdir_p(POSTS_DIR)
      File.write(post[:post_path], post[:content])
      json_response(response, 200, ok: true, filename: post[:filename], permalink: post[:permalink], asset_url: post[:asset_url])
    when "/api/build"
      result = run_command("env SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX12.3.sdk bundle exec jekyll build")
      json_response(response, result[:ok] ? 200 : 500, result.merge(ok: result[:ok]))
    when "/api/git-status"
      result = run_command("git status -sb")
      json_response(response, 200, result.merge(ok: true))
    when "/api/commit-push"
      payload = parse_json(request)
      message = utf8(payload["message"]).strip
      raise ArgumentError, "Commit message is required" if message.empty?

      commands = [
        "git add -A _posts assets/images _sass _includes _layouts _data _templates scripts Gemfile _config.yml .gitignore",
        "git commit -m #{Shellwords.escape(message)}",
        "git push origin master"
      ]
      outputs = commands.map do |command|
        result = run_command(command)
        raise "#{command}\n#{result[:output]}" unless result[:ok]

        "$ #{command}\n#{result[:output]}"
      end
      json_response(response, 200, ok: true, output: outputs.join("\n"))
    else
      json_response(response, 404, ok: false, error: "Not found")
    end
  rescue StandardError => error
    json_response(response, 500, ok: false, error: error.message)
  end
end

port = Integer(ENV.fetch("BLOG_ADMIN_PORT", "4567"))
server = WEBrick::HTTPServer.new(
  BindAddress: "127.0.0.1",
  Port: port,
  DocumentRoot: ROOT,
  AccessLog: [],
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
)
server.mount "/", BlogAdminServlet

trap("INT") { server.shutdown }
puts "Blog admin running at http://127.0.0.1:#{port}"
server.start
