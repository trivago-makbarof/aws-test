require 'fileutils'

action :deploy do
  log %Q(Deploying build "#{new_resource.build}" for application "#{new_resource.application}")


  # Ensure required attributes are not nil, otherwise error and return
  required_attributes = [:app]
  missing_attributes = required_attributes.keep_if { |attr| new_resource.send(attr).nil? }

  if !missing_attributes.empty?
    missing_attributes.each do |attr|
      ::Chef::Log.error("#{new_resource.resource_name}[#{new_resource.name}] missing required attribute '#{attr}'")
    end
    return
  end

  t = Time.now


  app_user = node['deployer']['user']
  app_group = node['deployer']['group']
  deploy_root = node['deploy']['root_path']
  app = new_resource.app
  app_root = ::File.join(deploy_root, "#{app}_data")
  release_root = ::File.join(app_root, 'releases')
  release_name = t.strftime("%Y%m%d%H%M%S")
  release_path = ::File.join(release_root, release_name)
  directory release_path do
    owner app_user
    group app_group
    mode '0755'
    recursive true
    action :create
  end
  build_file = ::File.join(node['deployer']['home'], "build.tar.gz")

  symlink = ::File.join(app_root, 'live_data')

  ruby_block "build_install" do
    block do

      raise "Build file is not in #{build_file}" unless ::File.size?(build_file)
      Chef::Log.info %Q(Extracting build "#{release_root}")
      `tar -xzf #{build_file} -C #{release_path}`
      raise "Failed to extract '#{release_path}'" unless ::File.exists?(::File.join(release_path, "web"))

      Chef::Log.info %Q(Changing owner of "#{release_path}" to #{app_user}:#{app_group})
      `chown #{app_user}:#{app_group} -R #{release_path}`

      Chef::Log.info %Q(Updating Symlink "#{symlink}")
      # Symlink overwriting seems to do some weird stuff, so remove it first...
      FileUtils::rm symlink, :force => true
      FileUtils::ln_s release_path, symlink


      if ::File.exists? build_file
        Chef::Log.info "Removing build archive"
        begin
          ::File.delete build_file
        rescue
          Chef::Log.warn %Q(Failed to remove "#{build_file}")
        end
      end

    end

  end

  new_resource.updated_by_last_action(true)
end