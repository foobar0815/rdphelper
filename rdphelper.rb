#!/usr/bin/env ruby

require 'fuzz'
require 'yaml'

windowwidth = 1350
windowheigt = 800
keyboardlayout = 0x00010407 # German (IBM)

# picker = Fuzz::DmenuPicker.new
# picker = Fuzz::PecoPicker.new
# picker = Fuzz::PickPicker.new
picker = Fuzz::RofiPicker.new
# picker = Fuzz::SelectaPicker.new

class Host
  attr_accessor :displayname, :address, :username, :domain, :password

  def initialize(displayname, address, username, domain, password)
    @displayname = displayname
    @address = address
    @username = username
    @domain = domain
    @password = password
  end

  def to_s
    displayname
  end
end

hostgroupsfn = 'hostgroups.yaml'
hostgroupsfile = File.join('~/.config/rdphelper', hostgroupsfn)

if File.file?(hostgroupsfile)
  hostgroups = YAML.load_file(hostgroupsfile)
else
  hostgroupsfile = File.join(File.dirname(__FILE__), hostgroupsfn)
  if File.file?(hostgroupsfile)
    hostgroups = YAML.load_file(hostgroupsfile)
  else
    exit
  end
end

hostgroups = YAML.load_file(File.join(File.dirname(__FILE__), 'hostgroups.yaml'))

groups = []
hostgroups.each do |g, _|
  groups.push(g)
end

chosen_group = Fuzz::Selector.new(groups, picker: picker).pick

hosts = []
hostgroups[chosen_group]['hosts'].each do |h|
  host = Host.new(h['displayname'], h['address'], nil, nil, nil)
  h['username'] ? host.username = h['username'] : host.username = hostgroups[chosen_group]['defaults']['username']
  h['domain'] ? host.domain = h['domain'] : host.domain = hostgroups[chosen_group]['defaults']['domain']
  h['password'] ? host.password = h['password'] : host.password = hostgroups[chosen_group]['defaults']['password']
  hosts.push(host)
end

chosen_host = Fuzz::Selector.new(hosts, picker: picker).pick
# secret-tool store --label "administrator@corp.contoso.com" application rdphelper username administrator@corp.contoso.com
unless chosen_host.password 
  chosen_host.password = %x(secret-tool lookup application rdphelper username #{chosen_host.username}@#{chosen_host.domain})
end

system('xfreerdp',
       "/u:#{chosen_host.username}",
       "/d:#{chosen_host.domain}",
       "/p:#{chosen_host.password}",
       "/v:#{chosen_host.address}",
       "/kbd:#{keyboardlayout}",
       "/w:#{windowwidth}",
       "/h:#{windowheigt}",
       '/dynamic-resolution',
       '/cert-tofu')
