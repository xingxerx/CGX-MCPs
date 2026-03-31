# Unified MCP Stack

A plug-and-play token-efficient MCP system for Claude Code and Claude Desktop.
Works on Windows, macOS, and Linux via Docker Desktop.

-----

## What’s included

|Server              |Role                                                                             |Token savings|
|--------------------|---------------------------------------------------------------------------------|-------------|
|**jCodeMunch**      |Symbol-level retrieval — finds exact functions/classes without reading full files|80–99%       |
|**mcp-agent-opt**   |Logic-only compression — strips comments, docstrings, boilerplate                |20–97%       |
|**GitMCP**          |Remote repo context — pulls docs and signatures directly from GitHub             |varies       |
|**Token Compressor**|Response proxy — compresses all MCP output before it hits context                |60–90%       |

Each layer targets a different part of the token pipeline. Together they stack.

-----

## Quick Start

### 1. Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- A GitHub account (for `GITHUB_TOKEN`)
- An Anthropic account (for `ANTHROPIC_API_KEY` — optional but recommended)

### 2. Add your repos

Open `docker-compose.yml` and add your repo paths under each service.
Look for the `# ADD YOUR REPOS HERE` comments.

**Windows (Docker Desktop):**

```yaml
volumes:
  - /d/MyProject:/workspace/MyProject:ro
  - /d/AnotherRepo:/workspace/AnotherRepo:ro
```

**macOS / Linux:**

```yaml
volumes:
  - /home/yourname/MyProject:/workspace/MyProject:ro
  - /home/yourname/AnotherRepo:/workspace/AnotherRepo:ro
```

> All mounts use `:ro` (read-only) — containers cannot modify your code.

### 3. Configure environment

```bash
cp .env.example .env
```

Edit `.env` and fill in your tokens.

### 4. Start the stack

**Windows:**

```
start.bat
```

**macOS / Linux:**

```bash
docker compose up -d
```

### 5. Configure Claude

#### Claude Desktop

Copy `claude_desktop_config.json` to:

- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux:** `~/.config/claude/claude_desktop_config.json`

If you already have a config, merge the `mcpServers` block into it.

#### GitMCP (remote repos)

In `claude_desktop_config.json`, update the GitMCP entries with your GitHub username and repo names:

```json
"gitmcp-my-repo": {
  "url": "https://gitmcp.io/your-username/your-repo"
}
```

Add one entry per repo. No container needed — GitMCP is fully remote.

### 6. Restart Claude Desktop / Claude Code

-----

## Adding more repos later

1. Add volume lines in `docker-compose.yml` under each service
1. Add a GitMCP entry in `claude_desktop_config.json`
1. Run `docker compose restart`

-----

## Useful commands

```bash
# Start stack
docker compose up -d

# Stop stack
docker compose down

# View all logs
docker compose logs -f

# View one service
docker compose logs -f jcodemunch

# Restart one service
docker compose restart jcodemunch

# Force re-index (wipes jCodeMunch symbol cache)
docker compose rm -f jcodemunch
docker volume rm mcp-stack_codemunch-index
docker compose up -d jcodemunch
```

-----

## Notes

- **jCodeMunch** builds its index on first run — takes 1–2 min per repo depending on size
- **Token Compressor** starts after the other services are up (`depends_on`)
- **GitMCP** is remote — no container, always pulls fresh from GitHub
- All containers restart automatically unless you explicitly stop them
- Both `GITHUB_TOKEN` and `ANTHROPIC_API_KEY` are optional — the stack works without them, just with reduced functionality

-----

## Troubleshooting

**Container won’t start**

```bash
docker compose logs jcodemunch
```

**Claude can’t see the MCP servers**

- Make sure containers are running: `docker compose ps`
- Make sure the config file is in the right location and Claude was restarted

**jCodeMunch not finding local files**

- Check your volume mount paths — on Windows, `D:\` maps to `/d/` in Docker
- Verify the repo path exists on your machine

**Token Compressor fails to install**

- Comment out the `token-compressor` service in `docker-compose.yml`
- The other 3 servers work independently without it
