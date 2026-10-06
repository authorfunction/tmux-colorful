#!/usr/bin/env bash
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

get_percent()
{
  case $(uname -s) in
    Linux)
      if [ -r /proc/stat ]; then
        file="/tmp/.tmux_colorful_cpu_${UID:-1000}"
        read -r _ u n s i w _ < /proc/stat
        used=$((u + n + s))
        total=$((used + i + w))
        if [ -f "$file" ]; then
          read -r p_used p_total < "$file"
          diff_used=$((used - p_used))
          diff_total=$((total - p_total))
          if [ $diff_total -gt 0 ]; then
            LC_ALL=C awk "BEGIN {printf \"%.1f\", ($diff_used / $diff_total) * 100}"
          else
            echo "0.0"
          fi
        else
          echo "0.0"
        fi
        echo "$used $total" > "$file"
      else
        percent=$(LC_ALL=C top -bn2 -d 0.01 2>/dev/null | grep "Cpu(s)" | tail -1 | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | LC_ALL=C awk '{print 100 - $1}')
        echo "$percent"
      fi
      ;;

    Darwin)
      cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
      cpucores=$(sysctl -n hw.logicalcpu)
      cpuusage=$(( cpuvalue / cpucores ))
      percent="$cpuusage"
      echo $percent
      ;;

  esac
}

main()
{
  # storing the refresh rate in the variable RATE, default is 5
  cpu_percent=$(get_percent)
  echo "$cpu_percent"
}

# run main driver
main
