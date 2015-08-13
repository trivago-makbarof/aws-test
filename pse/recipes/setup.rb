# GRP deploy
Chef::Log.info %Q(Creating the group id)
group node['deployer']['group'] do
  gid       5000
end

# USER deploy
Chef::Log.info %Q("Creating the user #{node['deployer']['user']}")
user node['deployer']['user'] do
  comment   'The deployment user'
  uid       5000
  gid       5000
  shell     '/bin/bash'
  home      node['deployer']['home']
  supports  :manage_home => true
end

# DIR /home/{user}/.ssh
Chef::Log.info %Q("Creating ssh directory in #{node['deployer']['home']}/.ssh")
directory "#{node['deployer']['home']}/.ssh" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0700'
  recursive true
end

# TMPL /home/{user}/.ssh/authorized_keys
Chef::Log.info %Q(Adding the authorized keys)
cookbook_file "#{node['deployer']['home']}/.ssh/authorized_keys" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0400'
end

# appdata and www directories
Chef::Log.info %Q(Creating /appdata/www directory)
directory "/appdata/www" do
  owner     root
  group     root
  mode      '0755'
  recursive true
end