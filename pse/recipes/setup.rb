# GRP deploy
group node['deployer']['group'] do
  gid       5000
end

# USER deploy
user node['deployer']['user'] do
  comment   'The deployment user'
  uid       5000
  gid       5000
  shell     '/bin/bash'
  home      node['deployer']['home']
  supports  :manage_home => true
end

# DIR /home/{user}/.ssh
directory "#{node['deployer']['home']}/.ssh" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0700'
  recursive true
end

# TMPL /home/{user}/.ssh/authorized_keys
cookbook_file "#{node['deployer']['home']}/.ssh/authorized_keys" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0400'
end

# appdata and www directories
directory "/appdata/www" do
  owner     root
  group     root
  mode      '0755'
  recursive true
end