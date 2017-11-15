every 1.hours do
  # remove tmp dirs that haven't been used in the last hour
  command "[ -d /tmp/metaflop ] && find /tmp/metaflop -maxdepth 1 -type d -mtime 0.042 -exec rm -r '{}' \\;"
end
