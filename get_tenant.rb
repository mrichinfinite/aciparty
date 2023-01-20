# This program queries an APIC tenant and writes all the child objects contained within that tenant to a JSON file

# Require
require 'httparty'
require 'uri'
require 'json'
require 'io/console'

# Input the APIC URL
print "APIC URL: "
apic_url = gets.chomp

# If the URL is valid, continue; else, exit the program
if apic_url =~ URI.regexp
  # URL is valid
else
  puts "\n URL is invalid, be sure to start with http:// or https:// ; exiting"
  exit
end

# Input the username and password, and don't show password characters
print "Username: "
username = gets.chomp
print "Password: "
password = STDIN.noecho(&:gets).chomp

# Login to the APIC
response = HTTParty.post("#{apic_url}/api/aaaLogin.json", verify: false,
  body: {
"aaaUser": {
  "attributes": {
    "name": username,
    "pwd": password
  }
}
}.to_json,
  headers: { "Content-Type" => "application/json" }
)

# If the response code is not 200, exit the program; otherwise, continue
if response.code != 200
  puts "\n \n Response: #{response.code} ; exiting"
  exit
else
  puts "\n \n Success!"
end

# When the response code is 200, continue with the program
case response.code
when 200
  # Extract the bearer token from the response
  auth_token = response["Authorization"]

  # Extract the cookie from the headers
  cookie = response.headers["set-cookie"]
  
  # Input the tenant name
  print "\n Tenant: "
  tenant = gets.chomp
  
  # Use the bearer token and cookie for subsequent GET request to query tenant
  response = HTTParty.get("#{apic_url}/api/node/mo/uni/tn-#{tenant}.json?rsp-subtree=full", verify: false,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie }
  )
  
  # Process the response and write it to a file in the current working directory
  json_response = JSON.pretty_generate(response.parsed_response)
  File.write("tn-#{tenant}.json", json_response)
  puts "\n Response: #{response.code}, check JSON file in current working directory for output"

# Else when the response code is not 200, exit the program
else
  puts "\n Response: #{response.code}"
  exit
end

# Get another tenant
while true do
  print "\n Would you like to get another tenant from this fabric? [y/n] "
  get_tenant = gets.chomp
  
  # If the user wants to get another tenant, continue with the program
  if get_tenant == "y"
    # Input the tenant name
    print "\n Tenant: "
    tenant = gets.chomp
    
    # Make another GET request to query tenant
    response = HTTParty.get("#{apic_url}/api/node/mo/uni/tn-#{tenant}.json?rsp-subtree=full", verify: false,
      headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie }
    )

  # Process the response and write it to a file in the current working directory
  json_response = JSON.pretty_generate(response.parsed_response)
  File.write("tn-#{tenant}.json", json_response)
  puts "\n Response: #{response.code}, check JSON file in current working directory for output"

  # Else if the response code is not 200, exit the program
  elsif response.code != 200
    puts "\n \n Response: #{response.code} ; exiting"
    exit
  
  # Else if the user doesn't want to get another tenant, exit the program
  elsif get_tenant == "n"
    puts "\n Enjoy your day!"
    exit
  
  # Else any response other than y/n, exit the program
  else
    puts "\n Invalid input, only y/n is accepted ; exiting"
    exit
  end
end
