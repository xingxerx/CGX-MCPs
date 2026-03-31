@echo off
echo Starting MCP stack...
docker compose up -d
if %errorlevel% neq 0 (
    echo.
    echo Failed to start. Is Docker Desktop running?
    pause
    exit /b 1
)
echo.
echo MCP stack is running.
echo.
docker compose ps
echo.
pause
