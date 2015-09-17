# Copyright 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# = Resource: zoidberg::instance
#
# Resource to set up a running instance of zoidberg.
#
# example usage:
#
#  include zoidberg
#  zoidberg::instance{ '/path/to/config/file.yaml': }
#
define zoidberg::instance (
  $ensure  = 'running',
  $logfile = '',
) {

  if ($logfile != '') {
    $process = "zoidbergd -c $title --logfile $logfile"
  } else {
    $process = "zoidbergd -c $title"
  }

  $pid_finder = "ps ax | grep \"$process\"|grep -v grep|awk '{print \$1}'"

  if (!defined(File[$title])) {
    $subscribe = []
  } else {
    $subscribe = File[$title]
  }

  service { $title:
    provider => base,
    ensure => $ensure,
    start => "$process &",
    stop => "kill -TERM `$pid_finder`",
    pattern => $process,
    subscribe => $subscribe,
    require => $subscribe,
  }
}
