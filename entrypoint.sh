#!/bin/bash
# Start the SSH service
/usr/sbin/sshd

# Start ngrok for tunneling SSH over port 22
ngrok tcp 22

# Keep the container running by tailing a log file
tail -f /dev/null
