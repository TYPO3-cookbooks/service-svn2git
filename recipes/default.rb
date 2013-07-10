#
# Cookbook Name:: service-svn2git
# Recipe:: default
#
# Copyright 2012, TYPO3 Association
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###########################
# IMPORTANT NOTICE:
# In order to work, version 1.8 of Git is required. However, Debian squeeze still has 1.7.* as default
# Some manual commands were executed:
# wget http://ftp.ch.debian.org/debian/pool/main/g/git/git_1.8.3~rc1-1_amd64.deb
# dpkg -i git_1.8.3~rc1-1_amd64.deb

# Install packages
package "php5"
package "php5-cli"
package "git"
package "git-svn"
package "ruby"
package "rubygems"
package "subversion"

# Install gems
gem_package "svn2git"

# Makes sure svn2git is in the path
link "/usr/bin/svn2git" do
  to "/var/lib/gems/1.8/bin/svn2git"
end

# Create a User
user "svn2git" do
  comment "User for svn2git Virtual Host"
  shell "/bin/bash"
  home "/home/svn2git"
  supports :manage_home => true
end

# Create some directories if not yet created
%w{.ssh Scripts}.each do |directory|
  directory "/home/svn2git/#{directory}" do
    owner "svn2git"
    group "svn2git"
    mode "0700"
    action :create
  end
end

templates = {
  # For (my) convenience sake, add some git default shortcut
  'gitconfig.erb' => {
    :path => '.gitconfig',
    :permission => 0644
  },

  # Authorized key to log-in
  'authorized_keys.erb' => {
    :path => '.ssh/authorized_keys',
    :permission => 0600
  },

  # Script launcher for the Cron job
  'svn2git.sh' => {
    :path => 'Scripts/svn2git.sh',
    :permission => 0755
  }
}

templates.each do|source, template|
  template "/home/svn2git/#{template[:path]}" do
    source "#{source}"
    owner "svn2git"
    group "svn2git"
    mode template[:permission]
  end
end

# Download Repository
bash 'clone-svn2git' do
  cwd '/home/svn2git'
  user "svn2git"
  group "svn2git"
  code <<-EOH

  git clone git://github.com/TYPO3/Svn2Git.git

  EOH
  not_if { ::File.exists? "/home/svn2git/Svn2Git" }
end

# Add cron task
cron "reset-demo" do
  hour "1,13"
  minute "0"
  user "root"
  mailto "fabien.udriot@typo3.org"
  command "schroot -c sid64 /home/svn2git/Scripts/svn2git.sh"
  #command "cd /home/svn2git/Svn2Git; /usr/bin/flock -n /tmp/svn2git.lockfile /usr/bin/php console.php"
end
