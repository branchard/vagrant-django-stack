# -*- mode: ruby -*-
# vi: set ft=ruby :

# General project settings
##############################

# IP adress for the host only network
ip_address = "127.168.10.14"

# Set the name of your project directory which is in projects/,
# if doesn't exist a new Django project will be created with the project name.
# The project name serves to database name and for virtualenv name
project_name = "myproject"

# Chose 32 or 64 for the vm architecture
vm_architecture = "32"

# MySQL password
database_password = "root"

# Python version (3 is recomended)
python_version = "3"

# Django version
django_version = "1.8.1"

# Vagrant init
##############################

Vagrant.configure(2) do |config|

  # checking settings
  if ip_address == nil
    ip_address = "127.168.10.12"
  end
  if project_name == nil
    project_name = "default"
  end
  if vm_architecture == nil || (vm_architecture != "32" && vm_architecture != "64")
    vm_architecture = "32"
  end
  if database_password == nil
    database_password = "root"
  end
  if python_version == nil || (python_version.to_f < 2.4 && python_version.to_f > 3.4)
    python_version = "2.7"
  end
  if django_version == nil
    django_version = "1.8"
  end

  config.vm.box = "precise" + vm_architecture
  config.vm.box_url = "http://files.vagrantup.com/precise" + vm_architecture + ".box"

  config.vm.network "public_network", ip: ip_address
  config.vm.hostname = project_name + ".dev"

  # allow ports
  config.vm.network "forwarded_port", guest: "80", host: "80", auto_correct: true # need privilege

  # to allow this projet to be a submodule of an existing django project
  config.vm.synced_folder "./", "/vagrant/"

  # To remove 'stdin: is not a tty' error
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.provision :shell, :path => "bootstrap.sh",\
    :args => project_name + " " + database_password + " " + \
    python_version + " " + django_version
end
