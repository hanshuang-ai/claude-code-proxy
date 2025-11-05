# Claude Code Proxy - Hooks Log Analysis Tool

A comprehensive web-based analysis tool for examining Claude Hooks event logs and HTTP proxy requests. This project combines a Java-based HTTP proxy server with modern HTML5 interfaces for log visualization and analysis.

## Architecture Overview

This is a dual-component system:

1. **Java HTTP Proxy Server** (`proxy/` directory) - Tomcat-based proxy that intercepts and logs API calls
2. **Web Analysis Interface** (`analyze/` directory) - HTML5-based log analysis dashboard

### System Components

- **Proxy Server**: Java servlet running on embedded Tomcat (port 8888)
- **Analysis Dashboard**: Split-view interface with iframe-based architecture
- **Hooks Log Parser**: JavaScript-based JSON line parser for Claude Hooks events
- **HTTP Request Log Parser**: Advanced parser for proxy request/response pairs

## Essential Commands

### Starting the Application

**Windows:**
```bash
# Run the startup script
start.bat
```

**macOS/Linux:**
```bash
# Make scripts executable (if needed)
chmod +x start-tomcat.sh

# Start the server
./start-tomcat.sh
```

### Stopping the Application

**macOS/Linux:**
```bash
./stop-tomcat.sh
```

**Windows:** Use Ctrl+C in the console or close the command window.

### Access Points

- **Main Dashboard**: http://localhost:8888/analyze/index.html
- **Proxy Server**: http://localhost:8888/proxy
- **Hooks Analysis**: http://localhost:8888/analyze/hooks.html
- **Proxy Analysis**: http://localhost:8888/analyze/proxy.html

## Configuration

### Proxy Target Configuration

Edit `proxy/webapps/proxy/WEB-INF/classes/config.xml`:

```xml
<handler path="/proxy">
    <target>https://open.bigmodel.cn/api/anthropic</target>
    <replacer source="qwerweq" target="wqerrerewqerqw"/>
    <print-skip-header>authorization</print-skip-header>
</handler>
```

### Claude Settings

Configure your Claude settings to use the proxy:
```json
{
  "apiUrl": "http://localhost:8888/proxy"
}
```

## Technical Details

### Hooks Log Format

The system parses Claude Hooks event logs with the following JSON structure per line:

```json
{
  "ts": "2025-11-05T03:07:49.991Z",
  "event": "UserPromptSubmit",
  "phase": "",
  "message": "UserPromptSubmit事件正在执行",
  "description": "用户提交提示前触发，可进行提示校验或增强。",
  "doc_url": "https://docs.claude.com/zh-CN/docs/claude-code/hooks#userpromptsubmit",
  "payload": {
    "session_id": "uuid",
    "transcript_path": "path/to/transcript.jsonl",
    "cwd": "working/directory",
    "permission_mode": "acceptEdits",
    "hook_event_name": "UserPromptSubmit",
    "prompt": "/init"
  }
}
```

### Supported Hook Events

The system recognizes and categorizes 9 different hook event types:

1. **UserPromptSubmit** - User prompt submission events
2. **PreToolUse** - Pre-tool execution events
3. **PostToolUse** - Post-tool execution events
4. **Notification** - System notification events
5. **Stop** - Main agent completion events
6. **SubagentStop** - Subagent completion events
7. **PreCompact** - Pre-context compaction events
8. **SessionStart** - Session initialization events
9. **SessionEnd** - Session termination events

### HTTP Request Log Format

Proxy logs follow a structured format with 8 components per request:
- Request Header (2 parts)
- Request Body (2 parts)
- Response Header (2 parts)
- Response Body (2 parts)

Each request includes timing information, processing duration, and unique LOG-ID for correlation.

## Key Features

### Hooks Analysis Interface (`hooks.html`)

- **File Upload**: Drag-and-drop support for .log/.txt files (50MB limit)
- **Event Statistics**: Real-time counting of all hook event types
- **Transcript Path Detection**: Automatic detection and display of transcript_path fields
- **Advanced Filtering**: Event type filtering and full-text search
- **File Operations**: Copy path to clipboard, attempt file opening via File API
- **Modal Viewer**: Built-in file content viewer with copy functionality
- **Responsive Design**: Mobile-friendly interface with animations

### Proxy Analysis Interface (`proxy.html`)

- **Request Grouping**: Intelligent grouping of HTTP request/response pairs
- **Timing Analysis**: Processing time calculations and span analysis
- **JSON Formatting**: Automatic formatting of JSON payloads with syntax highlighting
- **Header Analysis**: Structured display of HTTP headers
- **Performance Metrics**: Min/max/average response time calculations

### Security Considerations

#### File Handling Security
- **Client-side Processing**: All file parsing occurs in the browser; no server upload required
- **File Type Validation**: Restricted to .log and .txt file extensions
- **Size Limitations**: 50MB maximum file size to prevent browser memory issues
- **Content Sanitization**: HTML escaping for all displayed content
- **Local File Access**: Uses File API with user consent for local file operations

#### Proxy Security
- **Header Filtering**: Configurable skipping of sensitive headers (e.g., authorization)
- **Request Logging**: Comprehensive logging while maintaining data privacy
- **Target Configuration**: Secure proxy target configuration in XML

## Browser Compatibility

### Minimum Requirements
- **Chrome/Edge**: Version 80+
- **Firefox**: Version 75+
- **Safari**: Version 13+

### Required Browser APIs
- **File API**: For local file reading and parsing
- **Clipboard API**: For copy-to-clipboard functionality
- **CSS Grid/Flexbox**: For responsive layout
- **ES6 JavaScript**: For modern JavaScript features
- **Web Workers**: Not currently used but available for future enhancements

### Progressive Enhancement
The application provides fallback functionality for older browsers:
- Manual file upload if drag-and-drop unavailable
- Basic text display if JSON formatting fails
- Simplified layout for browsers without CSS Grid support

## Development Notes

### File Structure
```
claude-code-proxy/
├── analyze/                    # Web analysis interface
│   ├── index.html             # Main dashboard with iframes
│   ├── hooks.html             # Hooks log analysis page
│   └── proxy.html             # Proxy log analysis page
├── proxy/                     # Java HTTP proxy server
│   ├── webapps/proxy/         # Web application
│   │   └── WEB-INF/
│   │       ├── classes/       # Compiled Java classes
│   │       ├── lib/           # Dependencies
│   │       └── web.xml        # Servlet configuration
│   ├── conf/                  # Tomcat configuration
│   ├── bin/                   # Tomcat binaries
│   └── logs/                  # Server logs
├── .claude/                   # Claude configuration and hooks logs
├── start.bat                  # Windows startup script
├── start-tomcat.sh           # Unix startup script
└── stop-tomcat.sh            # Unix stop script
```

### Logging Locations
- **Proxy Requests**: `proxy/logs/run.log`
- **Hooks Events**: `.claude/hooks.log`
- **Tomcat Server**: `proxy/logs/catalina.out`

### Performance Considerations
- Large log files (>10MB) may cause UI delays during parsing
- Memory usage scales with file size - consider chunking for very large files
- JSON parsing is synchronous; future versions could use Web Workers
- File reading uses FileReader API for better performance than fetch()

## Troubleshooting

### Common Issues

1. **Port 8888 already in use**
   - Check for other services using the port
   - Modify `proxy/conf/server.xml` to change port

2. **Hooks log not updating**
   - Verify Claude configuration points to correct proxy URL
   - Check proxy server is running and accessible

3. **File upload failures**
   - Verify file extension (.log/.txt)
   - Check file size under 50MB limit
   - Ensure browser supports required APIs

4. **Analysis not displaying data**
   - Check browser console for JavaScript errors
   - Verify log file format matches expected structure
   - Ensure JSON parsing is not failing on malformed data

### Debug Mode
Enable browser developer tools to see:
- File parsing progress in console
- JavaScript errors and warnings
- Network requests (if any)
- Performance timing information

This comprehensive tool provides developers with deep insights into both Claude Hooks behavior and HTTP proxy performance, making it invaluable for debugging, optimization, and monitoring AI-powered applications.