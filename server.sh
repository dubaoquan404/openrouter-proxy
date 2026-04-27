#!/bin/bash
# server.sh - Manage the OpenRouter Proxy server
# Usage: ./server.sh {start|stop|restart|status}

PID_FILE="proxy.pid"
NODE_CMD="node proxy.js"
LOG_FILE="proxy.log"

start() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "Proxy is already running (PID $(cat $PID_FILE))"
    exit 0
  fi
  nohup $NODE_CMD > "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  echo "Proxy started (PID $!)"
}

stop() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 $PID 2>/dev/null; then
      kill $PID
      echo "Proxy stopped (PID $PID)"
    else
      echo "No running process found for PID $PID. Removing stale PID file."
    fi
    rm -f "$PID_FILE"
  else
    # Try to find node process on port 8999
    PID=$(lsof -ti tcp:8999 -sTCP:LISTEN -c node)
    if [ -n "$PID" ]; then
      kill $PID
      echo "Proxy process on port 8999 stopped (PID $PID)"
    else
      echo "Proxy is not running."
    fi
  fi
}

status() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "Proxy is running (PID $(cat $PID_FILE))"
  else
    echo "Proxy is not running."
  fi
}

restart() {
  stop
  sleep 1
  start
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
