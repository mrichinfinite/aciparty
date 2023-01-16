# Require
require 'httparty'
require 'uri'
require 'json'
require 'io/console'

begin
  # Input the APIC URL
  print "APIC URL: "
  apic_url = gets.chomp

  # Validate the APIC URL
  base_url = URI(apic_url)

  # If the APIC URL is invalid, throw an error and exit the program
rescue URI::InvalidURIError
  puts "\n Invalid URL"
  exit
end

  # Input the username and password, and don't show password characters
  print "Username: "
  username = gets.chomp
  print "Password: "
  password = STDIN.noecho(&:gets).chomp

  # Login to the APIC
  response = HTTParty.post("#{base_url}/api/aaaLogin.json", verify: false,
    body: {
  "aaaUser": {
    "attributes": {
      "name": username,
      "pwd": password
    }
  }
}.to_json,
    headers: { 'Content-Type' => 'application/json' }
  )

  # If the response code is not 200, exit the program; otherwise, continue
  if response.code != 200
    puts "\n Response: #{response.code}"
    exit
  else
    puts "Success"
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
    response = HTTParty.get("#{base_url}/api/node/mo/uni/tn-#{tenant}.json?query-target=children", verify: false,
      headers: { 'Authorization' => "Bearer #{auth_token}", 'Cookie' => cookie }
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
      print "Tenant: "
      tenant = gets.chomp

      # Make another GET request to query tenant
      response = HTTParty.get("#{base_url}/api/node/mo/uni/tn-#{tenant}.json?query-target=children", verify: false,
        headers: { 'Authorization' => "Bearer #{auth_token}", 'Cookie' => cookie }
      )

      # Process the response
      puts JSON.pretty_generate(response.parsed_response)
      puts "\n Response: #{response.code}"
    
    # Break out of program if user doesn't want to get another tenant  
    elsif get_tenant == "n"
      puts "\n Enjoy your day!"
      break
    
    # If any response other than y/n, throw an error
    else
      puts "\n Invalid input, exiting"
      break
    end   
end
