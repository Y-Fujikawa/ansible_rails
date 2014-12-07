require 'rake'
require 'rspec/core/rake_task'
require 'yaml'

# param: none
# return: @playbook, @inventoryfile
def load_ansiblespec()
  f = '.ansiblespec'
  if File.exist?(f)
    y = YAML.load_file(f)
    @playbook = y[0]['playbook']
    @inventoryfile = y[0]['inventory']
  else
    @playbook = 'site.yml'
    @inventoryfile = 'hosts'
  end
  if File.exist?(@playbook) == false
    puts 'Error: ' + @playbook + ' is not Found. create site.yml or /.ansiblespec  See https://github.com/volanja/ansible_spec'
    exit 1
  elsif File.exist?(@inventoryfile) == false
    puts 'Error: ' + @inventoryfile + ' is not Found. create hosts or /.ansiblespec  See https://github.com/volanja/ansible_spec'
    exit 1
  end
end

# param: inventory file of Ansible
# return: Hash {"active_group_name" => ["192.168.0.1","192.168.0.2"]}
def load_host(file)
  hosts = File.open(file).read
  active_group = Hash.new
  active_group_name = ''
  hosts.each_line{|line|
    line = line.chomp
    next if line.start_with?('#')
    if line.start_with?('[') && line.end_with?(']')
      active_group_name = line.gsub('[','').gsub(']','')
      active_group["#{active_group_name}"] = Array.new
    elsif active_group_name.empty? == false
      next if line.empty? == true
      active_group["#{active_group_name}"] << line
    end
  }
  return active_group
end

# main
load_ansiblespec
load_file = YAML.load_file(@playbook)

# e.g. comment-out
if load_file === false
  puts 'Error: No data in site.yml'
  exit
end

properties = Array.new
load_file.each do |site|
  if site.has_key?("include")
    properties.push YAML.load_file(site["include"])[0]
  else
    properties.push site
  end
end


#load inventry file
hosts = load_host(@inventoryfile)
properties.each do |var|
  if hosts.has_key?("#{var["hosts"]}")
    var["hosts"] = hosts["#{var["hosts"]}"]
  end
end

namespace :serverspec do
  properties.each do |var|
    var["hosts"].each do |host|
      desc "Run serverspec for #{var["name"]}"
      RSpec::Core::RakeTask.new(var["name"].to_sym) do |t|
        puts "Run serverspec for #{var["name"]} to #{host}"
        ENV['TARGET_HOST'] = host
        ENV['TARGET_PRIVATE_KEY'] = '~/.ssh/id_rsa'
        ENV['TARGET_USER'] = var["user"]
        t.pattern = 'roles/{' + var["roles"].join(',') + '}/spec/*_spec.rb'
      end
    end
  end
end

