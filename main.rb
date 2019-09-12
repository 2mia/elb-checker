require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?

set :bind, '0.0.0.0'
# set :port, 443

ips = {}

get '/lb/:host' do
  content_type :json
  # should be adobe.io
  top_domain = params[:host].split('.').last(2).join('.')
  # resolver
  dns_servers = `whois #{top_domain} | grep "Name Server" -i | head -3`.split("\n").map {|line| line.split(" ").last.downcase}
  resp = {:host => params[:host], :ips => []}
  resp["resolver"] = dns_servers

  dns_servers.each {|resolver|
     8.times do |i|
        o =`dig @#{resolver} #{params[:host]} | grep "^#{params[:host]}" | expand`
        o.split("\n").each_with_index {|line, index| resp[:ips] << line.split(" ").last }
     end
     sleep(1.0/24.0) # wait a bit for ips to be distributed
  }
  resp[:ips].sort!.uniq!
  ips[params[:host]] = resp[:ips]
  resp.to_json
end

get '/check/:host' do
  content_type :json
  if ips[params[:host]]
    ips[params[:host]].map {|ip| {ip => isUp(ip)}}.to_json
  else
    {}.to_json
  end
 
end

get '/is-up/:ip' do
  if isUp(params[:ip]) == true
    "true"
  else
   status 418
   "false"
  end
end

#------------------------------------
def isUp(ip)
  needle = "openresty"
  output = `curl -s -H 'Connection: close' --connect-timeout 3 -m 4 #{ip}/version -I 2>&1`
  if output.include? needle
    true
  else
    puts "XXX: #{ip} #{output}"
    output
  end
end

