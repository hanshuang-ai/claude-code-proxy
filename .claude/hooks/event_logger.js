#!/usr/bin/env node
/*
 * Cross-platform event logger for Claude Code hooks
 * Writes structured JSON entries to .claude/hooks.log
 */
import fs from 'node:fs';
import path from 'node:path';

const event = process.argv[2] || 'UnknownEvent';
const phase = process.argv[3] || '';

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const claudeDir = path.join(projectDir, '.claude');
const logFile = path.join(claudeDir, 'hooks.log');

try {
  fs.mkdirSync(claudeDir, { recursive: true });
} catch {}

function getDescription(evt, ph) {
  switch (evt) {
    case 'PreToolUse':
      return '工具执行前触发，可基于参数阻止或调整调用。';
    case 'PostToolUse':
      return '工具成功执行后触发，常用于格式化、校验或记录结果。';
    case 'UserPromptSubmit':
      return '用户提交提示前触发，可进行提示校验或增强。';
    case 'Notification':
      return '当系统发送通知（需授权或等待输入）时触发。';
    case 'Stop':
      return '主代理完成响应时触发（用户中断不触发）。';
    case 'SubagentStop':
      return '子代理任务完成时触发，用于记录子任务结束。';
    case 'PreCompact':
      return ph === 'manual'
        ? '手动压缩前触发，用于记录或准备压缩。'
        : '自动压缩前触发（上下文接近上限），用于记录或准备压缩。';
    case 'SessionStart':
      switch (ph) {
        case 'startup':
          return '新会话启动时触发，用于加载上下文或设置环境。';
        case 'resume':
          return '恢复会话时触发，用于继续先前上下文。';
        case 'clear':
          return '清空会话后触发，用于重置环境与上下文。';
        case 'compact':
          return '因压缩操作触发的会话启动，用于维持上下文。';
        default:
          return '会话启动相关事件，初始化或恢复上下文。';
      }
    case 'SessionEnd':
      return '会话结束时触发，常用于收尾与清理。';
    default:
      return '未知事件。';
  }
}

function getDocUrl(evt) {
  const base = 'https://docs.claude.com/zh-CN/docs/claude-code/hooks';
  switch (evt) {
    case 'PreToolUse':
      return `${base}#pretooluse`;
    case 'PostToolUse':
      return `${base}#posttooluse`;
    case 'UserPromptSubmit':
      return `${base}#userpromptsubmit`;
    case 'Notification':
      return `${base}#notification`;
    case 'Stop':
      return `${base}#stop`;
    case 'SubagentStop':
      return `${base}#subagentstop`;
    case 'PreCompact':
      return `${base}#precompact`;
    case 'SessionStart':
      return `${base}#sessionstart`;
    case 'SessionEnd':
      return `${base}#sessionend`;
    default:
      return base;
  }
}

// Read optional JSON payload from stdin (non-TTY)
async function readStdinJSON() {
  if (process.stdin.isTTY) return {};
  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(Buffer.from(chunk));
  }
  const raw = Buffer.concat(chunks).toString('utf8').trim();
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

const run = async () => {
  const description = getDescription(event, phase);
  const docUrl = getDocUrl(event);
  const payload = await readStdinJSON();

  const message = phase
    ? `${event}(${phase})事件正在执行`
    : `${event}事件正在执行`;

  const entry = {
    ts: new Date().toISOString(),
    event,
    phase,
    message,
    description,
    doc_url: docUrl,
    payload,
  };

  fs.appendFileSync(logFile, JSON.stringify(entry) + '\n', 'utf8');
};

run().catch(err => {
  // Fail silently to avoid breaking hook execution flow
  try {
    fs.appendFileSync(logFile, JSON.stringify({
      ts: new Date().toISOString(),
      event,
      phase,
      error: String(err && err.message || err),
    }) + '\n', 'utf8');
  } catch {}
});