# This program queries an APIC tenant and provides a JSON response with all the child objects contained within that tenant

# Require
require 'httparty'
require 'uri'
require 'json'
require 'io/console'

# Input the APIC URL
print "APIC URL: "
apic_url = gets.chomp

# If URL is valid, continue; else, throw an error and exit program
if apic_url =~ URI.regexp
  # URL is valid
else
  puts "\n URL is invalid, be sure to start with http:// or https://, exiting"
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
  puts "\n Response: #{response.code}, exiting"
  exit
else
  puts "\n \n Success!"
end

# If response code is 200, continue with the program
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
  response = HTTParty.get("#{apic_url}/api/node/mo/uni/tn-#{tenant}.json?query-target=children", verify: false,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie }
  )
  
  # Process the response
  puts JSON.pretty_generate(response.parsed_response)
  puts "\n Response: #{response.code}"
else
  puts "\n Response: #{response.code}"
end

# Get another tenant
while true do
  print "\n Would you like to get another tenant from this fabric? [y/n] "
  get_tenant = gets.chomp
  
  # Print output based on user input
  if get_tenant == "y"
    # Input the tenant name
    print "\n Tenant: "
    tenant = gets.chomp
    
    # Make another GET request to query tenant
    response = HTTParty.get("#{apic_url}/api/node/mo/uni/tn-#{tenant}.json?query-target=children", verify: false,
      headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie }
    )

    # Process the response
    puts JSON.pretty_generate(response.parsed_response)
    puts "\n Response: #{response.code}"
  
  # Break out of program if user doesn't want to get another tenant  
  elsif get_tenant == "n"
    puts "\n Enjoy your day!"
    break
  
  # If any response other than y/n, throw an error and break out of program
  else
    puts "\n Invalid input, only y/n is accepted, exiting"
    break
  end
end
