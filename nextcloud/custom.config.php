<?php
/**
 * Nextcloud Configuration - SOC-PME Full Stack
 * À placer dans /var/www/html/config/custom.config.php
 */

$CONFIG = array(
  // ============================================
  // TRUSTED DOMAINS & PROXIES
  // ============================================
  'trusted_domains' => array(
    0 => 'localhost',
    1 => 'cloud.soc-pme.local',
    2 => 'nextcloud.soc-pme.local',
    3 => '172.16.20.1',
    4 => '172.18.0.20',
  ),
  
  'trusted_proxies' => array(
    0 => '172.18.0.2',  // Traefik
    1 => '172.18.0.0/24',
  ),
  
  'overwriteprotocol' => 'https',
  'overwritehost' => 'cloud.soc-pme.local',
  
  // ============================================
  // DATABASE
  // ============================================
  'dbtype' => 'pgsql',
  'dbhost' => 'postgres',
  'dbname' => 'nextcloud',
  'dbuser' => 'socpme',
  
  // ============================================
  // REDIS CACHE
  // ============================================
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => array(
    'host' => 'redis',
    'port' => 6379,
    'timeout' => 0.0,
  ),
  
  // ============================================
  // PERFORMANCE
  // ============================================
  'filelocking.enabled' => true,
  'filesystem_check_changes' => 0,
  'htaccess.RewriteBase' => '/',
  
  // ============================================
  // SECURITY
  // ============================================
  'default_language' => 'fr',
  'default_locale' => 'fr_FR',
  'default_phone_region' => 'FR',
  
  // Password policy
  'password_policy' => array(
    'minLength' => 10,
    'enforceNumericCharacters' => true,
    'enforceUpperLowerCase' => true,
    'enforceSpecialCharacters' => true,
  ),
  
  // Brute force protection
  'auth.bruteforce.protection.enabled' => true,
  'auth.bruteforce.protection.testing' => false,
  
  // Security headers
  'forwarded_for_headers' => array(
    'HTTP_X_FORWARDED_FOR',
  ),
  
  // ============================================
  // COLLABORA ONLINE
  // ============================================
  'richdocuments' => array(
    'wopi_url' => 'http://collabora:9980',
  ),
  
  // ============================================
  // MAIL
  // ============================================
  'mail_smtpmode' => 'smtp',
  'mail_smtphost' => 'mailu-smtp',
  'mail_smtpport' => 25,
  'mail_smtpsecure' => '',
  'mail_from_address' => 'cloud',
  'mail_domain' => 'soc-pme.local',
  
  // ============================================
  // LOGGING (for SIEM)
  // ============================================
  'log_type' => 'file',
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'loglevel' => 1,
  'logdateformat' => 'Y-m-d H:i:s',
  
  // Audit logging (requires app)
  'log.condition' => array(
    'apps' => array('admin_audit'),
  ),
  
  // ============================================
  // APPS
  // ============================================
  'apps_paths' => array(
    array(
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    array(
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  
  // Disable app store if needed
  // 'appstoreenabled' => false,
  
  // ============================================
  // PREVIEW
  // ============================================
  'enable_previews' => true,
  'preview_max_x' => 2048,
  'preview_max_y' => 2048,
  'preview_max_filesize_image' => 50,
  
  // ============================================
  // UPLOAD
  // ============================================
  'max_chunk_size' => 10485760,  // 10 MB
);
