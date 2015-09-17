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
# = Class: zoidberg
#
# Class to install common zoidberg items.
#
class zoidberg (
  $install_from = 'pip',
) {

  case $install_from {
    'pip': {
      package { 'zoidberg':
        ensure   => 'present',
        provider => 'pip',
      }
    }

    'git': {
      $source_path = '/opt/zoidberg/src'
      $virtualenv_path = '/opt/zoidberg/venv'

      vcsrepo { $source_path:
        ensure   => latest,
        provider => 'git',
        source   => 'https://github.com/notnownikki/zoidberg.git',
        revision => 'master',
      }

      exec { 'create-zoidberg-virtualenv':
        command => "/usr/local/bin/virtualenv ${virtualenv_path}",
        creates => $virtualenv_path,
      }

      exec { 'install-zoidberg':
        command     => "${virtualenv_path}/bin/pip install ${source_path}",
        refreshonly => true,
        subscribe   => Vcsrepo[$source_path],
        require     => [
          Vcsrepo[$source_path],
          Exec['create-zoidberg-virtualenv'],
        ],
      }
    }

    default: {
      fail("Unsupported install source: $install_from")
    }
  }
}
