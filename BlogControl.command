#!/bin/bash
cd "$(dirname "$0")"
URL="http://127.0.0.1:4568"

if lsof -i :4568 >/dev/null 2>&1; then
  open "$URL"
  exit 0
fi

BLOG_CONTROL_PORT=4568 bundle exec ruby scripts/blog_control.rb
