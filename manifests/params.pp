#MOTD params
class neb0t_motd::params {
  $alert      = "root@localhost"
  $contact    = "root@localhost"

  # You shouldn't need to change these
  $templates  = "/etc/motd.d"
  $head       = "motd.head"
  $tail       = "motd.tail"

  # Commands to get system info
  $cputime = "ps -eo pcpu | awk 'NR>1' | awk '{tot=tot+\$1} END {print tot}'"
  $cpucores = "cat /proc/cpuinfo | grep -c processor"
  $loadavg = "cat /proc/loadavg | awk '{print \$1 \"  \" \$2 \"  \" \$3}'"
  $freemem = "free -m | head -n 2 | tail -n 1 | awk '{ print \$2 }'"
  $realmem = "free -m | head -n 2 | tail -n 1 | awk '{ print \$3 }'"
  $cachemem = "free -m | head -n 3 | tail -n 1 | awk '{ print \$4 }'"
  $swapmem = "free -m | tail -n 1 | awk {'print \$3'}"
  # in minutes
  $poll = 5
}
