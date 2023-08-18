# This program creates an APIC tenant along with child objects such as VRF, BD, AP, EPG

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
    puts "\n \n Response: #{response.code} ; exiting"
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

    # Input the Tenant name
    print "\n Tenant: "
    tenant = gets.chomp
    # If the input is empty or contains any special characters, exit the program
    if tenant.empty? || tenant.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the VRF name
    print "\n VRF: "
    vrf = gets.chomp
    if vrf.empty? || vrf.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the BD name
    print "\n Bridge Domain: "
    bd = gets.chomp
    if bd.empty? || bd.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the AP name
    print "\n Application Profile: "
    ap = gets.chomp
    if ap.empty? || ap.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Input the EPG name
    print "\n EPG: "
    epg = gets.chomp
    if epg.empty? || epg.match(/[^\p{Alnum}_-]/)
        puts "\n Invalid input or special characters detected ; exiting"
        exit
    end

    # Use the bearer token and cookie for subsequent POST request to create tenant objects
    response = HTTParty.post("#{apic_url}/api/node/mo/uni/tn-#{tenant}.json", verify: false,
    body: {
        "totalCount": "1",
        "imdata": [
            {
                "fvTenant": {
                    "attributes": {
                        "annotation": "",
                        "descr": "",
                        "name": "#{tenant}",
                        "nameAlias": "",
                        "ownerKey": "",
                        "ownerTag": "",
                        "userdom": ":all:"
                    },
                    "children": [
                        {
                            "fvCtx": {
                                "attributes": {
                                    "annotation": "",
                                    "bdEnforcedEnable": "no",
                                    "descr": "",
                                    "ipDataPlaneLearning": "enabled",
                                    "knwMcastAct": "permit",
                                    "name": "#{vrf}",
                                    "nameAlias": "",
                                    "ownerKey": "",
                                    "ownerTag": "",
                                    "pcEnfDir": "ingress",
                                    "pcEnfPref": "enforced",
                                    "userdom": ":all:",
                                    "vrfIndex": "0"
                                },
                                "children": [
                                    {
                                        "fvRsVrfValidationPol": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnL3extVrfValidationPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "vzAny": {
                                            "attributes": {
                                                "annotation": "",
                                                "descr": "",
                                                "matchT": "AtleastOne",
                                                "name": "",
                                                "nameAlias": "",
                                                "prefGrMemb": "disabled",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsOspfCtxPol": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnOspfCtxPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsCtxToEpRet": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnFvEpRetPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsCtxToExtRouteTagPol": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnL3extRouteTagPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsBgpCtxPol": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnBgpCtxPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    }
                                ]
                            }
                        },
                        {
                            "fvBD": {
                                "attributes": {
                                    "OptimizeWanBandwidth": "no",
                                    "annotation": "",
                                    "arpFlood": "yes",
                                    "descr": "",
                                    "epClear": "no",
                                    "epMoveDetectMode": "",
                                    "hostBasedRouting": "no",
                                    "intersiteBumTrafficAllow": "no",
                                    "intersiteL2Stretch": "no",
                                    "ipLearning": "yes",
                                    "ipv6McastAllow": "no",
                                    "limitIpLearnToSubnets": "yes",
                                    "llAddr": "::",
                                    "mac": "00:22:BD:F8:19:FF",
                                    "mcastARPDrop": "yes",
                                    "mcastAllow": "no",
                                    "multiDstPktAct": "bd-flood",
                                    "name": "#{bd}",
                                    "nameAlias": "",
                                    "ownerKey": "",
                                    "ownerTag": "",
                                    "type": "regular",
                                    "unicastRoute": "yes",
                                    "unkMacUcastAct": "proxy",
                                    "unkMcastAct": "flood",
                                    "userdom": ":all:",
                                    "v6unkMcastAct": "flood",
                                    "vmac": "not-applicable"
                                },
                                "children": [
                                    {
                                        "fvRsMldsn": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnMldSnoopPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsIgmpsn": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnIgmpSnoopPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsCtx": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnFvCtxName": "#{vrf}",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsBdToEpRet": {
                                            "attributes": {
                                                "annotation": "",
                                                "resolveAct": "resolve",
                                                "tnFvEpRetPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    },
                                    {
                                        "fvRsBDToNdP": {
                                            "attributes": {
                                                "annotation": "",
                                                "tnNdIfPolName": "",
                                                "userdom": "all"
                                            }
                                        }
                                    }
                                ]
                            }
                        },
                        {
                            "fvRsTenantMonPol": {
                                "attributes": {
                                    "annotation": "",
                                    "tnMonEPGPolName": "",
                                    "userdom": "all"
                                }
                            }
                        },
                        {
                            "fvAp": {
                                "attributes": {
                                    "annotation": "",
                                    "descr": "",
                                    "name": "#{ap}",
                                    "nameAlias": "",
                                    "ownerKey": "",
                                    "ownerTag": "",
                                    "prio": "unspecified",
                                    "userdom": ":all:"
                                },
                                "children": [
                                    {
                                        "fvAEPg": {
                                            "attributes": {
                                                "annotation": "",
                                                "descr": "",
                                                "exceptionTag": "",
                                                "floodOnEncap": "disabled",
                                                "fwdCtrl": "",
                                                "hasMcastSource": "no",
                                                "isAttrBasedEPg": "no",
                                                "matchT": "AtleastOne",
                                                "name": "#{epg}",
                                                "nameAlias": "",
                                                "pcEnfPref": "unenforced",
                                                "prefGrMemb": "exclude",
                                                "prio": "level3",
                                                "shutdown": "no",
                                                "userdom": ":all:"
                                            },
                                            "children": [
                                                {
                                                    "fvRsCustQosPol": {
                                                        "attributes": {
                                                            "annotation": "",
                                                            "tnQosCustomPolName": "",
                                                            "userdom": "all"
                                                        }
                                                    }
                                                },
                                                {
                                                    "fvRsBd": {
                                                        "attributes": {
                                                            "annotation": "",
                                                            "tnFvBDName": "#{bd}",
                                                            "userdom": "all"
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
                }
            }
        ]
    }.to_json,
    headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })

# Process the response
json_response = JSON.pretty_generate(response.parsed_response)
puts "\n Response: #{response.code} ; tenant objects created!"

# Else when the response code is not 200, exit the program
else 
    puts "\n Response: #{response.code} ; exiting"
    exit
end

# Create more tenant objects
while true do
    print "\n Would you like to create more tenant objects in this fabric? [y/n] "
    create_tenant = gets.chomp

    # If the user wants to create more tenant objects, continue with the program
    if create_tenant == "y"
        # Input the Tenant name
        print "\n Tenant: "
        tenant = gets.chomp
        # If the input is empty or contains any special characters, exit the program
        if tenant.empty? || tenant.match(/[^\p{Alnum}_-]/)
            puts "\n Invalid input or special characters detected ; exiting"
            exit
        end

        # Input the VRF name
        print "\n VRF: "
        vrf = gets.chomp
        if vrf.empty? || vrf.match(/[^\p{Alnum}_-]/)
            puts "\n Invalid input or special characters detected ; exiting"
            exit
        end

        # Input the BD name
        print "\n Bridge Domain: "
        bd = gets.chomp
        if bd.empty? || bd.match(/[^\p{Alnum}_-]/)
            puts "\n Invalid input or special characters detected ; exiting"
            exit
        end

        # Input the AP name
        print "\n Application Profile: "
        ap = gets.chomp
        if ap.empty? || ap.match(/[^\p{Alnum}_-]/)
            puts "\n Invalid input or special characters detected ; exiting"
            exit
        end

        # Input the EPG name
        print "\n EPG: "
        epg = gets.chomp
        if epg.empty? || epg.match(/[^\p{Alnum}_-]/)
            puts "\n Invalid input or special characters detected ; exiting"
            exit
        end

        # Use the bearer token and cookie for subsequent POST request to create tenant objects
        response = HTTParty.post("#{apic_url}/api/node/mo/uni/tn-#{tenant}.json", verify: false,
        body: {
            "totalCount": "1",
            "imdata": [
                {
                    "fvTenant": {
                        "attributes": {
                            "annotation": "",
                            "descr": "",
                            "name": "#{tenant}",
                            "nameAlias": "",
                            "ownerKey": "",
                            "ownerTag": "",
                            "userdom": ":all:"
                        },
                        "children": [
                            {
                                "fvCtx": {
                                    "attributes": {
                                        "annotation": "",
                                        "bdEnforcedEnable": "no",
                                        "descr": "",
                                        "ipDataPlaneLearning": "enabled",
                                        "knwMcastAct": "permit",
                                        "name": "#{vrf}",
                                        "nameAlias": "",
                                        "ownerKey": "",
                                        "ownerTag": "",
                                        "pcEnfDir": "ingress",
                                        "pcEnfPref": "enforced",
                                        "userdom": ":all:",
                                        "vrfIndex": "0"
                                    },
                                    "children": [
                                        {
                                            "fvRsVrfValidationPol": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnL3extVrfValidationPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "vzAny": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "descr": "",
                                                    "matchT": "AtleastOne",
                                                    "name": "",
                                                    "nameAlias": "",
                                                    "prefGrMemb": "disabled",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsOspfCtxPol": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnOspfCtxPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsCtxToEpRet": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnFvEpRetPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsCtxToExtRouteTagPol": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnL3extRouteTagPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsBgpCtxPol": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnBgpCtxPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "fvBD": {
                                    "attributes": {
                                        "OptimizeWanBandwidth": "no",
                                        "annotation": "",
                                        "arpFlood": "yes",
                                        "descr": "",
                                        "epClear": "no",
                                        "epMoveDetectMode": "",
                                        "hostBasedRouting": "no",
                                        "intersiteBumTrafficAllow": "no",
                                        "intersiteL2Stretch": "no",
                                        "ipLearning": "yes",
                                        "ipv6McastAllow": "no",
                                        "limitIpLearnToSubnets": "yes",
                                        "llAddr": "::",
                                        "mac": "00:22:BD:F8:19:FF",
                                        "mcastARPDrop": "yes",
                                        "mcastAllow": "no",
                                        "multiDstPktAct": "bd-flood",
                                        "name": "#{bd}",
                                        "nameAlias": "",
                                        "ownerKey": "",
                                        "ownerTag": "",
                                        "type": "regular",
                                        "unicastRoute": "yes",
                                        "unkMacUcastAct": "proxy",
                                        "unkMcastAct": "flood",
                                        "userdom": ":all:",
                                        "v6unkMcastAct": "flood",
                                        "vmac": "not-applicable"
                                    },
                                    "children": [
                                        {
                                            "fvRsMldsn": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnMldSnoopPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsIgmpsn": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnIgmpSnoopPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsCtx": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnFvCtxName": "#{vrf}",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsBdToEpRet": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "resolveAct": "resolve",
                                                    "tnFvEpRetPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        },
                                        {
                                            "fvRsBDToNdP": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "tnNdIfPolName": "",
                                                    "userdom": "all"
                                                }
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "fvRsTenantMonPol": {
                                    "attributes": {
                                        "annotation": "",
                                        "tnMonEPGPolName": "",
                                        "userdom": "all"
                                    }
                                }
                            },
                            {
                                "fvAp": {
                                    "attributes": {
                                        "annotation": "",
                                        "descr": "",
                                        "name": "#{ap}",
                                        "nameAlias": "",
                                        "ownerKey": "",
                                        "ownerTag": "",
                                        "prio": "unspecified",
                                        "userdom": ":all:"
                                    },
                                    "children": [
                                        {
                                            "fvAEPg": {
                                                "attributes": {
                                                    "annotation": "",
                                                    "descr": "",
                                                    "exceptionTag": "",
                                                    "floodOnEncap": "disabled",
                                                    "fwdCtrl": "",
                                                    "hasMcastSource": "no",
                                                    "isAttrBasedEPg": "no",
                                                    "matchT": "AtleastOne",
                                                    "name": "#{epg}",
                                                    "nameAlias": "",
                                                    "pcEnfPref": "unenforced",
                                                    "prefGrMemb": "exclude",
                                                    "prio": "level3",
                                                    "shutdown": "no",
                                                    "userdom": ":all:"
                                                },
                                                "children": [
                                                    {
                                                        "fvRsCustQosPol": {
                                                            "attributes": {
                                                                "annotation": "",
                                                                "tnQosCustomPolName": "",
                                                                "userdom": "all"
                                                            }
                                                        }
                                                    },
                                                    {
                                                        "fvRsBd": {
                                                            "attributes": {
                                                                "annotation": "",
                                                                "tnFvBDName": "#{bd}",
                                                                "userdom": "all"
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
                    }
                }
            ]
        }.to_json,
        headers: { "Authorization" => "Bearer #{auth_token}", "Cookie" => cookie, "Content-Type" => "application/json" })

    # Process the response. If the response code is not 200, exit the program; otherwise, continue
    json_response = JSON.pretty_generate(response.parsed_response)
    if response.code != 200
        puts "\n \n Response: #{response.code} ; exiting"
        exit
    else
        puts "\n Response: #{response.code} ; tenant created!"
    end

    # Else if the user doesn't want to create more tenant objects, exit the program
    elsif create_tenant == "n"
        puts "\n Enjoy your day!"
        exit

    # Else any response other than y/n, exit the program
    else
        puts "\n Invalid input, only y/n is accepted ; exiting"
        exit
    end
end
