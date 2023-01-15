require 'httparty'
require 'uri'
require 'json'

begin
  # Input the APIC URL
  print "APIC URL: "
  apic_url = gets.chomp

  # Input the username and password
  print "Username: "
  username = gets.chomp
  print "Password: "
  password = gets.chomp

  # Input the tenant name
  print "Tenant: "
  tenant = gets.chomp

  # Validate the URL
  base_url = URI(apic_url)

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
  
  # Check the response code
  case response.code
  when 200
    
    # Extract the bearer token from the response
    auth_token = response["Authorization"]

    # Extract the cookie from the headers
    cookie = response.headers["set-cookie"]

    # Use the bearer token and cookie for subsequent GET request to query tenant
    response = HTTParty.get("#{base_url}/api/node/mo/uni/tn-#{tenant}.json", verify: false,
      headers: { 'Authorization' => "Bearer #{auth_token}", 'Cookie' => cookie }
    )
    
    # Process the response
    puts JSON.pretty_generate(response.parsed_response)
  when 401
    puts "Unauthorized: Invalid username or password"
  when 403
    puts "Forbidden: Access denied"
  when 500
    puts "Internal Server Error"
  when 503
    puts "Service Unavailable"
  else
    puts "Error: #{response.code}"
  end

# If APIC URL is invalid, throw an error  
rescue URI::InvalidURIError
  puts "Invalid URL"
end