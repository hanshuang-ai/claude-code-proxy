#!/usr/bin/env bash
set -euo pipefail

event="${1:-UnknownEvent}"
phase="${2:-}"

# Fallback project dir for local testing when CLAUDE_PROJECT_DIR is unset
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"

# unified log file in project
log_file="$project_dir/.claude/hooks.log"
log_dir="$project_dir/.claude"
mkdir -p "$project_dir/.claude"

# Compose message for JSON field
if [ -n "$phase" ]; then
  message="${event}(${phase})事件正在执行"
else
  message="${event}事件正在执行"
fi

# Event description mapping (Chinese) based on docs
get_description() {
  case "$event" in
    PreToolUse)
      echo "工具执行前触发，可基于参数阻止或调整调用。" ;;
    PostToolUse)
      echo "工具成功执行后触发，常用于格式化、校验或记录结果。" ;;
    UserPromptSubmit)
      echo "用户提交提示前触发，可进行提示校验或增强。" ;;
    Notification)
      echo "当系统发送通知（需授权或等待输入）时触发。" ;;
    Stop)
      echo "主代理完成响应时触发（用户中断不触发）。" ;;
    SubagentStop)
      echo "子代理任务完成时触发，用于记录子任务结束。" ;;
    PreCompact)
      if [ "$phase" = "manual" ]; then
        echo "手动压缩前触发，用于记录或准备压缩。"
      else
        echo "自动压缩前触发（上下文接近上限），用于记录或准备压缩。"
      fi ;;
    SessionStart)
      case "$phase" in
        startup) echo "新会话启动时触发，用于加载上下文或设置环境。" ;;
        resume)  echo "恢复会话时触发，用于继续先前上下文。" ;;
        clear)   echo "清空会话后触发，用于重置环境与上下文。" ;;
        compact) echo "因压缩操作触发的会话启动，用于维持上下文。" ;;
        *)       echo "会话启动相关事件，初始化或恢复上下文。" ;;
      esac ;;
    SessionEnd)
      echo "会话结束时触发，常用于收尾与清理。" ;;
    *)
      echo "未知事件。" ;;
  esac
}

# Doc URL mapping
get_doc_url() {
  base="https://docs.claude.com/zh-CN/docs/claude-code/hooks"
  case "$event" in
    PreToolUse)    echo "$base#pretooluse" ;;
    PostToolUse)   echo "$base#posttooluse" ;;
    UserPromptSubmit) echo "$base#userpromptsubmit" ;;
    Notification)  echo "$base#notification" ;;
    Stop)          echo "$base#stop" ;;
    SubagentStop)  echo "$base#subagentstop" ;;
    PreCompact)    echo "$base#precompact" ;;
    SessionStart)  echo "$base#sessionstart" ;;
    SessionEnd)    echo "$base#sessionend" ;;
    *)             echo "$base" ;;
  esac
}

description="$(get_description)"
doc_url="$(get_doc_url)"

# Read JSON context from stdin if available (avoid blocking on TTY)
payload=""
if [ ! -t 0 ]; then
  payload="$(cat)"
fi

# Compact JSON for single-line logging; fallback to empty object
if [ -n "$payload" ]; then
  compact_json="$(jq -c . <<< "$payload" 2>/dev/null || echo '{}')"
else
  compact_json='{}'
fi

# Append multi-line JSON entry combining message, description, doc_url and payload
ts_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
jq -n \
  --arg ts "$ts_iso" \
  --arg event "$event" \
  --arg phase "$phase" \
  --arg message "$message" \
  --arg description "$description" \
  --arg doc_url "$doc_url" \
  --argjson payload "$compact_json" \
  '{
    ts: $ts,
    event: $event,
    phase: $phase,
    message: $message,
    description: $description,
    doc_url: $doc_url,
    payload: $payload
  }' >> "$log_file"