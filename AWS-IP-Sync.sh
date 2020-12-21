#!/bin/bash
curl -L https://ip-ranges.amazonaws.com/ip-ranges.json > /tmp/aws_ip_ranges.json
jq -r '.prefixes[] | [.ip_prefix, .region, .service, .network_border_group] | @csv' /tmp/aws_ip_ranges.json > /tmp/aws_ip_ranges_v4.csv
jq -r '.ipv6_prefixes[] | [.ipv6_prefix, .region, .service, .network_border_group] | @csv' /tmp/aws_ip_ranges.json > /tmp/aws_ip_ranges_v6.csv
# ADD firewall Group 
awk -F, '{
        gsub(/"/,"");
        split($1, ipaddr, "/");
        if(length($1) > 5 && ipaddr[2] < 32)
            {
                cmd="set firewall group network-group AWS_IP_RANGES network " $1;
                print cmd;
            }
        }' /tmp/aws_ip_ranges_v4.csv
awk -F, '{
        gsub(/"/,"");
        split($1, ipaddr, "/");
        if(length($1) > 5 && ipaddr[2] < 128)
            {
                cmd="set firewall group network-group V6_AWS_IP_RANGES network " $1;
                print cmd;
            }
        }' /tmp/aws_ip_ranges_v6.csv
