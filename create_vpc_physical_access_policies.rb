# This program creates access policies on an APIC specifically for LLDP-enabled leaf access ports using a physical domain

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
    headers: { "Content-Type" => "application/json" })

# If the response code is not 200, exit the program; otherwise, continue
if response.code != 200
    puts "\n \n Response: #{response.code} #{response.message} ; exiting"
    exit
else
    puts "\n \n Login successful!"
end

# When the response code is 200, continue with the program
case response.code
when 200
    # Extract the bearer token from the response
    auth_token = response["Authorization"]

    # Extract the cookie from the headers
    cookie = response.headers["set-cookie"]

    # Input the Leaf Profile name
    print "\n Enter the Leaf Profile name: "
    leaf_profile = gets.chomp
    # If the input is empty or contains any special characters, exit the program
    if leaf_profile.empty? || leaf_profile.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Leaf Selector name
    print "\n Enter the Leaf Selector name: "
    leaf_selector = gets.chomp
    if leaf_selector.empty? || leaf_selector.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the first Leaf ID
    print "\n Enter the first Leaf ID in the range (e.g. 101): "
    leaf_start = gets.chomp
    # If the input is empty or contains any special characters, exit the program
    if leaf_start.empty? || leaf_start.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the last Leaf ID
    print "\n Enter the last Leaf ID in the range (e.g. 102): "
    leaf_end = gets.chomp
    # If the input is empty or contains any special characters, exit the program
    if leaf_end.empty? || leaf_end.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Interface Selector Profile name
    print "\n Enter the Interface Selector Profile name: "
    interface_selector_profile = gets.chomp
    if interface_selector_profile.empty? || interface_selector_profile.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Interface Selector name
    print "\n Enter the Interface Selector name: "
    interface_selector = gets.chomp
    if interface_selector.empty? || interface_selector.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the first Port Module
    print "\n Enter the first port module in the range (e.g. 1): "
    port_module_start = gets.chomp
    if port_module_start.empty? || port_module_start.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end    

    # Input the first Port
    print "\n Enter the first port in the range (e.g. 1): "
    port_start = gets.chomp
    if port_start.empty? || port_start.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the last Port Module
    print "\n Enter the last port module in the range (e.g. 1): "
    port_module_end = gets.chomp
    if port_module_end.empty? || port_module_end.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end    

    # Input the last Port
    print "\n Enter the last port in the range (e.g. 2): "
    port_end = gets.chomp
    if port_end.empty? || port_end.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Interface Policy Group name
    print "\n Enter the Interface Policy Group name: "
    interface_policy_group = gets.chomp
    if interface_policy_group.empty? || interface_policy_group.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Explicit VPC Protection Group name
    print "\n Enter the Explicit VPC Protection Group name: "
    vpc_pg = gets.chomp
    if vpc_pg.empty? || vpc_pg.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the first leaf ID in the VPC PG
    print "\n Enter the first leaf ID in the group (e.g. 101): "
    vpc_pg_start = gets.chomp
    if vpc_pg_start.empty? || vpc_pg_start.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the last leaf ID in the VPC PG
    print "\n Enter the last leaf ID in the group (e.g. 102): "
    vpc_pg_end = gets.chomp
    if vpc_pg_end.empty? || vpc_pg_end.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Attachable Entity Profile name
    print "\n Enter the Attachable Entity Profile name: "
    attachable_entity_profile = gets.chomp
    if attachable_entity_profile.empty? || attachable_entity_profile.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the Domain name
    print "\n Enter the Domain name: "
    domain = gets.chomp
    if domain.empty? || domain.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the VLAN Pool name
    print "\n Enter the VLAN Pool name: "
    vlan_pool = gets.chomp
    if vlan_pool.empty? || vlan_pool.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the first Encap Block
    print "\n Enter the first VLAN in the range (e.g. 10): "
    vlan_start = gets.chomp
    if vlan_start.empty? || vlan_start.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the last Encap Block
    print "\n Enter the last VLAN in the range (e.g. 20): "
    vlan_end = gets.chomp
    if vlan_end.empty? || vlan_end.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Create VLAN Pool
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/infra/vlanns-%5B#{URI.encode_www_form_component(vlan_pool)}%5D-static.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "fvnsVlanInstP": {
                    "attributes": {
                        "allocMode": "static",
                        "annotation": "",
                        "descr": "",
                        "dn": "uni/infra/vlanns-[#{vlan_pool}]-static",
                        "name": "#{vlan_pool}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": "",
                        "userdom": ":all:"
                    },
                    "children": [
                        {
                            "fvnsEncapBlk": {
                                "attributes": {
                                    "allocMode": "static",
                                    "annotation": "",
                                    "descr": "",
                                    "from": "vlan-#{vlan_start}",
                                    "name": "",
                                    "nameAlias": "",
                                    "role": "external",
                                    "to": "vlan-#{vlan_end}",
                                    "userdom": ":all:"
                                }
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })

    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; VLAN pool created!"
    
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; VLAN pool not created!; exiting"
        exit
    end

    # Create Domain
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/phys-#{domain}.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "physDomP": {
                    "attributes": {
                        "annotation": "",
                        "dn": "uni/phys-#{domain}",
                        "name": "#{domain}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": "",
                        "userdom": ":all:"
                    },
                    "children": [
                        {
                            "infraRsVlanNs": {
                                "attributes": {
                                    "annotation": "",
                                    "tDn": "uni/infra/vlanns-[#{vlan_pool}]-static",
                                    "userdom": ":all:"
                                }
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })

    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; domain created!"
        
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; domain not created!; exiting"
        exit
    end

    # Create AEP
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/infra/attentp-#{attachable_entity_profile}.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "infraAttEntityP": {
                    "attributes": {
                        "annotation": "",
                        "descr": "",
                        "dn": "uni/infra/attentp-#{attachable_entity_profile}",
                        "name": "#{attachable_entity_profile}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": "",
                        "userdom": ":all:"
                    },
                    "children": [
                        {
                            "infraRsDomP": {
                                "attributes": {
                                    "annotation": "",
                                    "tDn": "uni/phys-#{domain}",
                                    "userdom": ":all:"
                                }
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })

    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; AEP created!"
        
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; AEP not created!; exiting"
        exit
    end

    # Create VPC PG
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/fabric/protpol.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "fabricProtPol": {
                    "attributes": {
                        "annotation": "",
                        "descr": "",
                        "dn": "uni/fabric/protpol",
                        "name": "default",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": "",
                        "pairT": "explicit"
                    },
                    "children": [
                        {
                            "fabricExplicitGEp": {
                                "attributes": {
                                    "annotation": "",
                                    "id": "1",
                                    "name": "#{vpc_pg}"
                                },
                                "children": [
                                    {
                                        "fabricRsVpcInstPol": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnVpcInstPolName": "default"
                                            }
                                        }
                                    },
                                    {
                                        "fabricNodePEp": {
                                            "attributes": {
                                                "annotation": "",
                                                "descr": "",
                                                "id": "#{vpc_pg_start}",
                                                "name": "",
                                                "nameAlias": "",
                                                "podId": "1"
                                            }
                                        }
                                    },
                                    {
                                        "fabricNodePEp": {
                                            "attributes": {
                                                "annotation": "",
                                                "descr": "",
                                                "id": "#{vpc_pg_end}",
                                                "name": "",
                                                "nameAlias": "",
                                                "podId": "1"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
        headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })

    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; VPC PG created!"
            
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; VPC PG not created!; exiting"
        exit
    end

    # Create vPC IPG
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/infra/funcprof/accbundle-#{interface_policy_group}.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "infraAccBndlGrp": {
                    "attributes": {
                        "annotation": "",
                        "descr": "",
                        "dn": "uni/infra/funcprof/accbundle-#{interface_policy_group}",
                        "lagT": "node",
                        "name": "#{interface_policy_group}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": ""
                    },
                    "children": [
                        {
                            "infraRsStpIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnStpIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsQosLlfcIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnQosLlfcIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsQosIngressDppIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnQosDppPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsStormctrlIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnStormctrlIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsQosEgressDppIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnQosDppPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsMonIfInfraPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnMonInfraPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsMcpIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnMcpIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsMacsecIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnMacsecIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsQosSdIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnQosSdIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsAttEntP": {
                                "attributes": {
                                    "annotation": "",
                                    "tDn": "uni/infra/attentp-#{attachable_entity_profile}"
                                }
                            }
                        },
                        {
                            "infraRsCdpIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnCdpIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsL2IfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnL2IfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsQosDppIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnQosDppPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsCoppIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnCoppIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsLldpIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnLldpIfPolName": "system-lldp-enabled"
                                }
                            }
                        },
                        {
                            "infraRsFcIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnFcIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsQosPfcIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnQosPfcIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsHIfPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnFabricHIfPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsL2PortSecurityPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnL2PortSecurityPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsL2PortAuthPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnL2PortAuthPolName": ""
                                }
                            }
                        },
                        {
                            "infraRsLacpPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnLacpLagPolName": "system-lacp-active"
                                }
                            }
                        },
                        {
                            "infraRsLinkFlapPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnFabricLinkFlapPolName": ""
                                }
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })
    
    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; IPG created!"
            
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; IPG not created!; exiting"
        exit
    end

    # Create Interface Profile
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/infra/accportprof-#{interface_selector_profile}.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "infraAccPortP": {
                    "attributes": {
                        "annotation": "",
                        "descr": "",
                        "dn": "uni/infra/accportprof-#{interface_selector_profile}",
                        "name": "#{interface_selector_profile}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": "",
                        "userdom": ":all:"
                    },
                    "children": [
                        {
                            "infraHPortS": {
                                "attributes": {
                                    "annotation": "",
                                    "descr": "",
                                    "name": "#{interface_selector}",
                                    "nameAlias": "",
                                    "ownerKey": "",
                                    "ownerTag": "",
                                    "type": "range",
                                    "userdom": ":all:"
                                },
                                "children": [
                                    {
                                        "infraRsAccBaseGrp": {
                                            "attributes": {
                                                "annotation": "",
                                                "fexId": "101",
                                                "tDn": "uni/infra/funcprof/accbundle-#{interface_policy_group}",
                                                "userdom": ":all:"
                                            }
                                        }
                                    },
                                    {
                                        "infraPortBlk": {
                                            "attributes": {
                                                "annotation": "",
                                                "descr": "",
                                                "fromCard": "#{port_module_start}",
                                                "fromPort": "#{port_start}",
                                                "name": "block2",
                                                "nameAlias": "",
                                                "toCard": "#{port_module_end}",
                                                "toPort": "#{port_end}",
                                                "userdom": ":all:"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })
        
    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; interface profile created!"
                
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; interface profile not created!; exiting"
        exit
    end

    # Create Leaf Profile
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/infra/nprof-#{leaf_profile}.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "infraNodeP": {
                    "attributes": {
                        "annotation": "",
                        "descr": "",
                        "dn": "uni/infra/nprof-#{leaf_profile}",
                        "name": "#{leaf_profile}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": ""
                    },
                    "children": [
                        {
                            "infraRsAccPortP": {
                                "attributes": {
                                    "annotation": "",
                                    "tDn": "uni/infra/accportprof-#{interface_selector_profile}"
                                }
                            }
                        },
                        {
                            "infraLeafS": {
                                "attributes": {
                                    "annotation": "",
                                    "descr": "",
                                    "name": "#{leaf_selector}",
                                    "nameAlias": "",
                                    "ownerKey": "",
                                    "ownerTag": "",
                                    "type": "range"
                                },
                                "children": [
                                    {
                                        "infraNodeBlk": {
                                            "attributes": {
                                                "annotation": "",
                                                "descr": "",
                                                "from_": "#{leaf_start}",
                                                "name": "143ae0ab2cbfc060",
                                                "nameAlias": "",
                                                "to_": "#{leaf_end}"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })
            
    # Process the response
    if response.code == 200
        json_response = JSON.pretty_generate(response.parsed_response)
        puts "\n Response: #{response.code} #{response.message} ; leaf profile created!"
                    
    # Else if the response code is not 200, exit the program
    elsif response.code != 200 
        puts "\n Response: #{response.code} #{response.message}; leaf profile not created!; exiting"
        exit
    end
end