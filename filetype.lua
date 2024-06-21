-- Add php.wp filetype for WordPress PHP files
vim.filetype.add({
    filename = {
        ['object-cache.php'] = 'php.wp',
        ['advanced-cache.php'] = 'php.wp',
    },
    pattern = {
        ['.*/wp%-includes/*.php'] = 'php.wp',
        ['.*/wp%-admin/*.php'] = 'php.wp',
        ['.*/wp%-content/*.php'] = 'php.wp',
        ['.*/wp%-.*.php'] = 'php.wp',
        ['.*/class%-.*.php'] = 'php.wp',
        ['.*/interface%-.*.php'] = 'php.wp',
    },
})

-- Add javascript.wp filetype for WordPress JavaScript files
vim.filetype.add({
    pattern = {
        ['.*/wp%-includes/*.js'] = 'javascript.wp',
        ['.*/wp%-admin/*.js'] = 'javascript.wp',
        ['.*/wp%-content/*.js'] = 'javascript.wp',
        ['.*/wp%-.*.js'] = 'javascript.wp',
    },
})
