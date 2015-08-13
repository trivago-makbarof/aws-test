require 'fileutils'


action :prepare_release do
  Chef::Log.info %Q(Preparing release for "#{new_resource.app}")

  app_user = new_resource.user
  app_group = new_resource.group
  deploy_root = new_resource.deploy_root
  app = new_resource.app
  app_root = ::File.join(deploy_root, "#{app}_data")
  release_root = ::File.join(app_root, 'releases')
  release_name = new_resource.version
  Chef::Log.info %Q(Releasing version "#{release_name}")
  release_path = ::File.join(release_root, release_name)
  directory release_path do
    owner app_user
    group app_group
    mode '0755'
    recursive true
    action :create
  end
  build_file = ::File.join(node['deployer']['home'], "build.tar.gz")

  ruby_block "build_install" do
    block do

      raise "Build file is not in #{build_file}" unless ::File.size?(build_file)
      Chef::Log.info %Q(Extracting build "#{release_root}")
      `tar -xzf #{build_file} -C #{release_path}`
      raise "Failed to extract '#{release_path}'" unless ::File.exists?(::File.join(release_path, "web"))

      Chef::Log.info %Q(Changing owner of "#{release_path}" to #{app_user}:#{app_group})
      `chown #{app_user}:#{app_group} -R #{release_path}`


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

action :deploy do
  Chef::Log.info %Q(Deploying application "#{new_resource.app}")
  symlink = ::File.join(app_root, 'live_data')
  deploy_root = new_resource.deploy_root
  app = new_resource.app
  app_root = ::File.join(deploy_root, "#{app}_data")
  release_root = ::File.join(app_root, 'releases')
  release_name = new_resource.version
  Chef::Log.info %Q(Releasing version "#{release_name}")
  release_path = ::File.join(release_root, release_name)
  ruby_block "deploy_release" do
    block do
      Chef::Log.info %Q(Updating Symlink "#{symlink}")
      # Symlink overwriting seems to do some weird stuff, so remove it first...
      FileUtils::rm symlink, :force => true
      FileUtils::ln_s release_path, symlink

      `service apache2 restart`
    end

  end

  new_resource.updated_by_last_action(true)
end