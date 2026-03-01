# ============================================
# LABSOC HOME - Zeek Minimal Configuration
# Works with Zeek 8.x on macOS
# ============================================

# Core frameworks
@load base/frameworks/logging
@load base/frameworks/notice
@load base/frameworks/analyzer

# Protocol analyzers
@load base/protocols/conn
@load base/protocols/dns
@load base/protocols/http
@load base/protocols/ssl
@load base/protocols/ssh

# JSON output for Filebeat
redef LogAscii::use_json = T;
redef LogAscii::json_timestamps = JSON::TS_ISO8601;

# Network configuration
redef Site::local_nets += { 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12 };
