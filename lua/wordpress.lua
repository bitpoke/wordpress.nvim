local intelephense_stubs = {
    'apache', 'bcmath', 'bz2', 'calendar', 'com_dotnet', 'Core', 'ctype', 'curl', 'date', 'dba', 'dom', 'enchant',
    'exif', 'FFI', 'fileinfo', 'filter', 'fpm', 'ftp', 'gd', 'gettext', 'gmp', 'hash', 'iconv', 'imap', 'intl', 'json',
    'ldap', 'libxml', 'mbstring', 'meta', 'mysqli', 'oci8', 'odbc', 'openssl', 'pcntl', 'pcre', 'PDO', 'pdo_ibm',
    'pdo_mysql', 'pdo_pgsql', 'pdo_sqlite', 'pgsql', 'Phar', 'posix', 'pspell', 'readline', 'Reflection', 'session',
    'shmop', 'SimpleXML', 'snmp', 'soap', 'sockets', 'sodium', 'SPL', 'sqlite3', 'standard', 'superglobals', 'sysvmsg',
    'sysvsem', 'sysvshm', 'tidy', 'tokenizer', 'xml', 'xmlreader', 'xmlrpc', 'xmlwriter', 'xsl', 'Zend OPcache', 'zip',
    'zlib'
}
table.insert(intelephense_stubs, 'wordpress')
table.insert(intelephense_stubs, 'memcache')
table.insert(intelephense_stubs, 'memcached')

local phpcs_root_pattern = function(fname) return nil end
if pcall(require, 'null-ls.utils') then
    local root_pattern = require("null-ls.utils").root_pattern
    phpcs_root_pattern = root_pattern("phpcs.xml.dist", "phpcs.xml", ".phpcs.xml.dist", ".phpcs.xml")
end

local _M = {
    intelephense = {
        get_language_id = function() return 'php' end,
        filetypes = { 'php', 'php.wp' },
        settings = {
            intelephense = {
                stubs = intelephense_stubs,
                files = {
                    maxSize = 5000000,
                }
            }
        }
    },
    null_ls_phpcs = {
        timeout = 15000, -- 15s
        -- use WordPress coding standards for files detected as php.wp
        extra_args = function(params)
            if params.ft == "php.wp" then
                -- skip for code under custom phpcs config file
                local local_root = phpcs_root_pattern(params.bufname)
                local args = { '-d', 'memory_limit=1G' }
                if (not local_root) then
                    table.insert(args, '--standard=WordPress')
                end
                return args
            end
        end,
        cwd = function(params)
            local local_root = phpcs_root_pattern(params.bufname)
            return local_root or params.root
        end,
    },
}

function _M.null_ls_formatter(client)
    if client.name == 'null-ls' then
        return true
    end
    return false
end

function _M.setup(opts)
    -- Register cmp source wordpress from cmp_wordpress module
    local has_cmp, cmp = pcall(require, 'cmp')
    if has_cmp then
        cmp.register_source('wordpress', require('cmp_wordpress').new())
    end
end

return _M
