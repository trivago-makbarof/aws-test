actions :prepare_release, :deploy
default_action :prepare_release

attribute :app, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String, :required => true
attribute :group, :kind_of => String, :required => true
attribute :deploy_root, :kind_of => String, :required => true
attribute :version, :kind_of => String, :required => true