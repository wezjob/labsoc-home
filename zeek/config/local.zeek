# ============================================
# LABSOC HOME - Zeek Local Configuration
# ============================================

# Load standard frameworks
@load base/frameworks/logging
@load base/frameworks/notice
@load base/frameworks/input
@load base/frameworks/cluster
@load base/frameworks/sumstats

# Load protocol analyzers
@load base/protocols/conn
@load base/protocols/dns
@load base/protocols/ftp
@load base/protocols/http
@load base/protocols/smtp
@load base/protocols/ssh
@load base/protocols/ssl
@load base/protocols/dhcp
@load base/protocols/ntlm
@load base/protocols/smb
@load base/protocols/dce-rpc
@load base/protocols/rdp

# File extraction and analysis
@load base/files/extract
@load base/files/hash
@load frameworks/files/hash-all-files

# Load policy scripts
@load policy/protocols/conn/known-hosts
@load policy/protocols/conn/known-services
@load policy/protocols/conn/mac-logging

@load policy/protocols/dns/auth-addl
@load policy/protocols/dns/detect-external-names

@load policy/protocols/http/detect-sqli
@load policy/protocols/http/detect-webapps
@load policy/protocols/http/software
@load policy/protocols/http/var-extraction-cookies
@load policy/protocols/http/var-extraction-uri

@load policy/protocols/smtp/detect-suspicious-orig
@load policy/protocols/smtp/software

@load policy/protocols/ssh/detect-bruteforcing
@load policy/protocols/ssh/geo-data
@load policy/protocols/ssh/interesting-hostnames
@load policy/protocols/ssh/software

@load policy/protocols/ssl/expiring-certs
@load policy/protocols/ssl/extract-certs-pem
@load policy/protocols/ssl/heartbleed
@load policy/protocols/ssl/known-certs
@load policy/protocols/ssl/log-hostcerts-only
@load policy/protocols/ssl/notary
@load policy/protocols/ssl/validate-certs
@load policy/protocols/ssl/weak-keys

@load policy/frameworks/software/version-changes
@load policy/frameworks/software/vulnerable

@load policy/misc/capture-loss
@load policy/misc/detect-traceroute
@load policy/misc/loaded-scripts
@load policy/misc/stats
@load policy/misc/weird-stats
@load policy/misc/scan

# Tuning
@load tuning/defaults

# JSON logging for ELK integration
@load policy/tuning/json-logs

redef LogAscii::use_json = T;

# Network configuration
redef Site::local_nets += {
    192.168.0.0/16,
    10.0.0.0/8,
    172.16.0.0/12
};

# ============================================
# Custom Detection Scripts
# ============================================

# DNS Tunneling Detection
module DNSTunneling;

export {
    redef enum Notice::Type += {
        DNS_Tunneling_Detected
    };
}

event dns_request(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count)
{
    if (|query| > 50) {
        NOTICE([
            $note=DNS_Tunneling_Detected,
            $conn=c,
            $msg=fmt("Possible DNS tunneling detected: long query '%s'", query),
            $sub=query,
            $identifier=cat(c$id$orig_h)
        ]);
    }
}

# ============================================
# Suspicious Connections
# ============================================

module SuspiciousConnections;

export {
    redef enum Notice::Type += {
        Suspicious_Port_Connection,
        Large_Data_Transfer
    };
    
    const suspicious_ports: set[port] = {
        4444/tcp, 5555/tcp, 6666/tcp, 7777/tcp, 8888/tcp, 31337/tcp
    };
}

event connection_established(c: connection)
{
    if (c$id$resp_p in suspicious_ports) {
        NOTICE([
            $note=Suspicious_Port_Connection,
            $conn=c,
            $msg=fmt("Connection to suspicious port %s", c$id$resp_p),
            $identifier=cat(c$id$orig_h, c$id$resp_p)
        ]);
    }
}

event connection_state_remove(c: connection)
{
    if (c?$orig && c$orig?$size && c$orig$size > 10000000) {
        NOTICE([
            $note=Large_Data_Transfer,
            $conn=c,
            $msg=fmt("Large outbound data transfer: %d bytes", c$orig$size),
            $identifier=cat(c$id$orig_h, c$id$resp_h)
        ]);
    }
}

# ============================================
# TLS/SSL Monitoring
# ============================================

module TLSMonitoring;

export {
    redef enum Notice::Type += {
        Self_Signed_Certificate,
        Expired_Certificate,
        Weak_Cipher
    };
}

event ssl_established(c: connection)
{
    if (c?$ssl && c$ssl?$cert_chain && |c$ssl$cert_chain| > 0) {
        local cert = c$ssl$cert_chain[0];
        
        # Check for self-signed
        if (cert?$x509 && cert$x509?$certificate) {
            local x = cert$x509$certificate;
            if (x?$issuer && x?$subject && x$issuer == x$subject) {
                NOTICE([
                    $note=Self_Signed_Certificate,
                    $conn=c,
                    $msg="Self-signed certificate detected",
                    $identifier=cat(c$id$resp_h, c$id$resp_p)
                ]);
            }
        }
    }
}

# ============================================
# HTTP Monitoring
# ============================================

module HTTPMonitoring;

export {
    redef enum Notice::Type += {
        Suspicious_User_Agent,
        Possible_SQL_Injection,
        Executable_Download
    };
    
    const suspicious_user_agents: pattern = /PowerShell|curl|wget|python-requests|Go-http-client/;
}

event http_header(c: connection, is_orig: bool, name: string, value: string)
{
    if (is_orig && name == "USER-AGENT" && suspicious_user_agents in value) {
        NOTICE([
            $note=Suspicious_User_Agent,
            $conn=c,
            $msg=fmt("Suspicious User-Agent: %s", value),
            $identifier=cat(c$id$orig_h, value)
        ]);
    }
}

event http_reply(c: connection, version: string, code: count, reason: string)
{
    if (c?$http && c$http?$mime_type) {
        if (/application\/x-msdownload|application\/x-executable|application\/x-dosexec/ in c$http$mime_type) {
            NOTICE([
                $note=Executable_Download,
                $conn=c,
                $msg=fmt("Executable download detected: %s", c$http$mime_type),
                $identifier=cat(c$id$orig_h, c$http$uri)
            ]);
        }
    }
}
