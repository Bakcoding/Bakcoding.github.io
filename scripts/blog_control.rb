#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "socket"
require "webrick"

ROOT = File.expand_path("..", __dir__)
LOG_DIR = File.join(ROOT, "_admin", "logs")
CONTROL_PORT = Integer(ENV.fetch("BLOG_CONTROL_PORT", "4568"))
HOST = "127.0.0.1"
SDKROOT = "/Library/Developer/CommandLineTools/SDKs/MacOSX12.3.sdk"

SERVERS = {
  "jekyll" => {
    label: "블로그 미리보기",
    port: 4000,
    url: "http://127.0.0.1:4000",
    command: ["bundle", "exec", "jekyll", "serve", "--host", HOST, "--port", "4000"],
    env: { "SDKROOT" => SDKROOT },
    log: File.join(LOG_DIR, "jekyll.log")
  },
  "admin" => {
    label: "글 작성 도구",
    port: 4567,
    url: "http://127.0.0.1:4567",
    command: ["bundle", "exec", "ruby", "scripts/blog_admin.rb"],
    env: { "BLOG_ADMIN_PORT" => "4567" },
    log: File.join(LOG_DIR, "blog_admin.log")
  }
}.freeze

def port_open?(port)
  TCPSocket.open(HOST, port).close
  true
rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
  false
end

def pids_for_port(port)
  stdout, = Open3.capture2("lsof", "-ti", "tcp:#{port}")
  stdout.lines.map(&:strip).reject(&:empty?).map(&:to_i)
rescue StandardError
  []
end

def start_server(key)
  server = SERVERS.fetch(key)
  return "#{server[:label]} 서버가 이미 실행 중이다." if port_open?(server[:port])

  FileUtils.mkdir_p(LOG_DIR)
  log = File.open(server[:log], "a")
  log.sync = true
  pid = Process.spawn(server[:env], *server[:command], chdir: ROOT, out: log, err: log, pgroup: true)
  Process.detach(pid)
  sleep 1
  "#{server[:label]} 서버를 시작했다. PID: #{pid}"
end

def stop_server(key)
  server = SERVERS.fetch(key)
  pids = pids_for_port(server[:port])
  return "#{server[:label]} 서버가 실행 중이 아니다." if pids.empty?

  pids.each { |pid| Process.kill("TERM", pid) }
  sleep 1
  "#{server[:label]} 서버를 종료했다. PID: #{pids.join(', ')}"
rescue Errno::ESRCH
  "#{server[:label]} 서버가 이미 종료됐다."
end

def status_payload
  servers = SERVERS.each_with_object({}) do |(key, server), memo|
    running = port_open?(server[:port])
    memo[key] = {
      label: server[:label],
      port: server[:port],
      url: server[:url],
      running: running,
      pids: running ? pids_for_port(server[:port]) : [],
      log: server[:log]
    }
  end
  { ok: true, servers: servers }
end

def json_response(response, status, payload)
  response.status = status
  response["Content-Type"] = "application/json; charset=utf-8"
  response.body = JSON.pretty_generate(payload)
end

HTML = <<~HTML
  <!doctype html>
  <html lang="ko">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bakcoding Local Control</title>
    <style>
      :root {
        --bg: #f6f7f4;
        --panel: #fff;
        --text: #24262b;
        --muted: #6f766f;
        --line: #dde3de;
        --accent: #24706b;
        --danger: #a13c3c;
        --ok: #2e7d4f;
      }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        background: var(--bg);
        color: var(--text);
        font-family: "Nanum Gothic", "Apple SD Gothic Neo", "Malgun Gothic", system-ui, sans-serif;
      }
      header {
        padding: 1rem 1.2rem;
        border-bottom: 1px solid var(--line);
        background: rgba(246, 247, 244, 0.96);
      }
      h1 { margin: 0; font-size: 1.1rem; }
      main {
        display: grid;
        grid-template-columns: repeat(2, minmax(280px, 1fr));
        gap: 1rem;
        max-width: 980px;
        margin: 0 auto;
        padding: 1rem;
      }
      section {
        border: 1px solid var(--line);
        border-radius: 8px;
        background: var(--panel);
        padding: 1rem;
      }
      h2 { margin: 0 0 0.5rem; font-size: 1rem; }
      p { color: var(--muted); line-height: 1.5; }
      .status {
        display: inline-flex;
        align-items: center;
        gap: 0.4rem;
        font-size: 0.9rem;
      }
      .dot {
        width: 0.7rem;
        height: 0.7rem;
        border-radius: 50%;
        background: var(--danger);
      }
      .running .dot { background: var(--ok); }
      .actions {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        margin-top: 1rem;
      }
      button, a.button {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-height: 2.2rem;
        border: 1px solid var(--line);
        border-radius: 6px;
        padding: 0.45rem 0.75rem;
        background: #fff;
        color: var(--text);
        font: inherit;
        text-decoration: none;
        cursor: pointer;
      }
      button.primary { color: #fff; border-color: var(--accent); background: var(--accent); }
      button.danger { color: var(--danger); }
      a.button.disabled {
        pointer-events: none;
        opacity: 0.45;
      }
      .wide {
        grid-column: 1 / -1;
      }
      pre {
        min-height: 120px;
        max-height: 260px;
        overflow: auto;
        white-space: pre-wrap;
        border: 1px solid var(--line);
        border-radius: 6px;
        padding: 0.75rem;
        background: #f9faf8;
      }
      @media (max-width: 760px) {
        main { grid-template-columns: 1fr; }
      }
    </style>
  </head>
  <body>
    <header>
      <h1>Bakcoding Local Control</h1>
    </header>
    <main>
      <section data-server="jekyll">
        <h2>블로그 미리보기</h2>
        <div class="status"><span class="dot"></span><span class="text">확인 중</span></div>
        <p>Jekyll 블로그를 로컬에서 미리 본다.</p>
        <div class="actions">
          <button class="primary" data-action="start">켜기</button>
          <button class="danger" data-action="stop">끄기</button>
          <a class="button open-link disabled" target="_blank" rel="noreferrer">열기</a>
        </div>
      </section>
      <section data-server="admin">
        <h2>글 작성 도구</h2>
        <div class="status"><span class="dot"></span><span class="text">확인 중</span></div>
        <p>새 글 작성, 이미지 삽입, 저장, 빌드, 커밋/푸시를 처리한다.</p>
        <div class="actions">
          <button class="primary" data-action="start">켜기</button>
          <button class="danger" data-action="stop">끄기</button>
          <a class="button open-link disabled" target="_blank" rel="noreferrer">열기</a>
        </div>
      </section>
      <section class="wide">
        <div class="actions">
          <button id="refreshBtn">상태 새로고침</button>
          <a class="button" href="https://bakcoding.github.io/" target="_blank" rel="noreferrer">배포 사이트 열기</a>
        </div>
        <pre id="log">대기 중</pre>
      </section>
    </main>
    <script>
      const log = (message) => { document.getElementById("log").textContent = message; };

      async function api(path, payload) {
        const response = await fetch(path, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload || {})
        });
        const data = await response.json();
        if (!response.ok || data.ok === false) throw new Error(data.error || "Request failed");
        return data;
      }

      async function refresh() {
        const response = await fetch("/api/status");
        const data = await response.json();
        for (const [key, server] of Object.entries(data.servers)) {
          const card = document.querySelector(`[data-server="${key}"]`);
          card.classList.toggle("running", server.running);
          card.querySelector(".text").textContent = server.running
            ? `실행 중 · ${server.port} · PID ${server.pids.join(", ")}`
            : `꺼짐 · ${server.port}`;
          const link = card.querySelector(".open-link");
          link.href = server.url;
          link.classList.toggle("disabled", !server.running);
        }
      }

      document.querySelectorAll("button[data-action]").forEach((button) => {
        button.addEventListener("click", async () => {
          const server = button.closest("[data-server]").dataset.server;
          const action = button.dataset.action;
          try {
            const data = await api(`/api/${action}`, { server });
            log(data.message);
            setTimeout(refresh, 800);
          } catch (error) {
            log(error.message);
          }
        });
      });

      document.getElementById("refreshBtn").addEventListener("click", refresh);
      refresh();
      setInterval(refresh, 5000);
    </script>
  </body>
  </html>
HTML

class BlogControlServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    case request.path
    when "/"
      response["Content-Type"] = "text/html; charset=utf-8"
      response.body = HTML
    when "/api/status"
      json_response(response, 200, status_payload)
    else
      json_response(response, 404, ok: false, error: "Not found")
    end
  rescue StandardError => error
    json_response(response, 500, ok: false, error: error.message)
  end

  def do_POST(request, response)
    payload = JSON.parse(request.body.to_s.empty? ? "{}" : request.body.to_s)
    key = payload["server"].to_s
    raise ArgumentError, "Unknown server: #{key}" unless SERVERS.key?(key)

    message = case request.path
              when "/api/start" then start_server(key)
              when "/api/stop" then stop_server(key)
              else raise ArgumentError, "Unknown action"
              end
    json_response(response, 200, ok: true, message: message)
  rescue StandardError => error
    json_response(response, 500, ok: false, error: error.message)
  end
end

url = "http://#{HOST}:#{CONTROL_PORT}"
Thread.new do
  sleep 1
  system("open", url) unless ENV["BLOG_CONTROL_NO_OPEN"] == "1"
end

server = WEBrick::HTTPServer.new(
  BindAddress: HOST,
  Port: CONTROL_PORT,
  DocumentRoot: ROOT,
  AccessLog: [],
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
)
server.mount "/", BlogControlServlet

trap("INT") { server.shutdown }
puts "Blog control running at #{url}"
server.start
