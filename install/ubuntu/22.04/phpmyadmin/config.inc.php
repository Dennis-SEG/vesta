<?php
/**
 * phpMyAdmin 5.2+ Configuration for Vesta Control Panel
 * Ubuntu 22.04 LTS
 *
 * This configuration is optimized for security and multi-user hosting
 */

declare(strict_types=1);

/**
 * Blowfish secret for cookie authentication
 * IMPORTANT: Generate a unique 32-character random string
 */
$cfg['blowfish_secret'] = '%BLOWFISH_SECRET%'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */

/**
 * Server(s) configuration
 */
$i = 0;

/* Server 1 - Local MariaDB/MySQL */
$i++;
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
$cfg['Servers'][$i]['AllowRoot'] = false;
$cfg['Servers'][$i]['hide_db'] = '^(information_schema|performance_schema|mysql|sys)$';

/**
 * Directories for saving/uploading files
 */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

/**
 * Security settings
 */
$cfg['CheckConfigurationPermissions'] = true;
$cfg['AllowArbitraryServer'] = false;
$cfg['ArbitraryServerRegexp'] = '/^127\.0\.0\.1$/';
$cfg['LoginCookieValidity'] = 1800; // 30 minutes
$cfg['LoginCookieStore'] = 0;
$cfg['LoginCookieDeleteAll'] = true;

/**
 * SQL query history
 */
$cfg['QueryHistoryDB'] = false;
$cfg['QueryHistoryMax'] = 25;

/**
 * Restrict database creation/deletion to admins
 */
$cfg['AllowUserDropDatabase'] = false;

/**
 * Confirm before running potentially dangerous queries
 */
$cfg['Confirm'] = true;

/**
 * Default language
 */
$cfg['DefaultLang'] = 'en';
$cfg['ServerDefault'] = 1;
$cfg['VersionCheck'] = true;

/**
 * Theme
 */
$cfg['ThemeDefault'] = 'pmahomme';

/**
 * Console settings
 */
$cfg['Console']['Mode'] = 'collapse';
$cfg['Console']['AlwaysExpand'] = false;
$cfg['Console']['EnterExecutes'] = false;
$cfg['Console']['DarkTheme'] = false;
$cfg['Console']['Height'] = 92;

/**
 * Navigation panel settings
 */
$cfg['NavigationTreeDefaultTabTable'] = 'structure';
$cfg['NavigationTreeDefaultTabTable2'] = null;
$cfg['NavigationTreeEnableGrouping'] = true;
$cfg['NavigationTreeDbSeparator'] = '_';
$cfg['NavigationTreeTableSeparator'] = '__';
$cfg['NavigationWidth'] = 240;

/**
 * Performance optimizations
 */
$cfg['MaxTableList'] = 250;
$cfg['ShowHint'] = true;
$cfg['MaxCharactersInDisplayedSQL'] = 1000;
$cfg['PersistentConnections'] = false;

/**
 * Export settings
 */
$cfg['Export']['format'] = 'sql';
$cfg['Export']['charset'] = 'utf-8';
$cfg['Export']['compression'] = 'none';
$cfg['Export']['sql_structure_or_data'] = 'structure_and_data';

/**
 * Import settings
 */
$cfg['Import']['charset'] = 'utf-8';

/**
 * Temp directory
 */
$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp/';

/**
 * Hide certain features for security
 */
$cfg['ShowServerInfo'] = false;
$cfg['ShowPhpInfo'] = false;
$cfg['ShowDbStructureCreation'] = false;
$cfg['ShowDbStructureLastUpdate'] = false;
$cfg['ShowDbStructureLastCheck'] = false;

/**
 * Send error reports
 */
$cfg['SendErrorReports'] = 'never';

/**
 * Enable zero configuration mode
 */
$cfg['ZeroConf'] = false;

/**
 * Disable Git version check
 */
$cfg['VersionCheck'] = false;

/**
 * Custom header (Vesta branding)
 */
$cfg['TitleDefault'] = 'phpMyAdmin - Vesta Control Panel';
