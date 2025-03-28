local source = {}
local wp_filters = {}
local wp_actions = {}

local cmp_types = require("cmp.types")

-- Helper function to get plugin path
local function plugin_path()
    local src = debug.getinfo(2, "S").source:sub(2)
    return vim.fs.dirname(vim.fs.dirname(src)) .. '/wp-hooks/'
end

-- Helper function to read JSON files
local function read_JSON_file(type)
    local path = plugin_path() .. type .. ".json"
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return vim.fn.json_decode(content)
    else
        vim.notify("File " .. path .. " doesn't exist, you need to run ./install.sh on the wp-hooks folder.",
            vim.log.levels.WARN)
        return vim.fn.json_decode('{"hooks": []}')
    end
end

-- Initialize source
function source.new()
    local self = setmetatable({}, { __index = source })
    -- Load hooks data
    wp_filters = read_JSON_file("filters")
    wp_actions = read_JSON_file("actions")
    return self
end

source.get_trigger_characters = function()
    return { "'", '"' }
end

source.get_keyword_pattern = function()
    return [[\k\+]]
end

function source:is_available()
    return vim.bo.filetype == "php.wp"
end

function source:get_debug_name()
    return 'wp_hooks'
end

local function get_documentation(hook)
    local doc = "**" .. hook.name .. "**"

    if hook.doc then
        if hook.doc.description then
            doc = doc .. '\n\n' .. hook.doc.description
        end

        if hook.doc.long_description and #hook.doc.long_description > 0 then
            doc = doc .. '\n\n' .. hook.doc.long_description
        end

        if hook.doc.tags and #hook.doc.tags > 0 then
            -- Print hook arguments firts
            for _, tag in pairs(hook.doc.tags) do
                if tag.variable then
                    doc = doc .. string.format(
                        "\n\n_@%s_ `%s %s`",
                        tag.name, table.concat(tag.types, "|"), tag.variable
                    )
                    if tag.content and #tag.content > 0 then
                        doc = doc .. "\n" .. tag.content
                    end
                end
            end

            -- Prnt other tags
            for _, tag in pairs(hook.doc.tags) do
                if not tag.variable then
                    doc = doc .. string.format(
                        "\n\n_@%s_ %s",
                        tag.name,
                        tag.refers or tag.content
                    )
                end
            end
        end
    end
end

function source:complete(params, callback)
    local line = params.context.cursor_line
    local col = params.context.cursor.col

    -- Get the line up to the cursor
    local current_line = line:sub(1, col)

    -- Determine hook type and get appropriate hooks
    local hooks = {}
    local hook_type = ''
    local hook_match = nil

    if not hook_match then
        hook_match = current_line:match([[add_action%(%s*['"]([^'"]*)]])
        if hook_match then
            hook_type = 'action'
            hooks = wp_actions.hooks
        end
    end
    if not hook_match then
        hook_match = current_line:match([[remove_action%(%s*['"]([^'"]*)]])
        if hook_match then
            hook_type = 'action'
            hooks = wp_actions.hooks
        end
    end
    if not hook_match then
        hook_match = current_line:match([[add_filter%(%s*['"]([^'"]*)]])
        if hook_match then
            hook_type = 'filter'
            hooks = wp_filters.hooks
        end
    end
    if not hook_match then
        hook_match = current_line:match([[remove_filter%(%s*['"]([^'"]*)]])
        if hook_match then
            hook_type = 'filter'
            hooks = wp_filters.hooks
        end
    end
    if not hook_match then
        return
    end

    -- Generate completion items
    local items = {}
    for _, hook in pairs(hooks) do
        if hook.name:sub(1, #hook_match) == hook_match then
            table.insert(items, {
                label = hook.name,
                insertText = hook.name,
                kind = 'WordPress',
                documentation = {
                    kind = "markdown",
                    value = get_documentation(hook),
                },
                cmp = {
                    kind_text = 'WordPress',
                    kind_hl_group = 'CmpItemKindWordPress'
                },
            })
        end
    end

    callback({ items = items, isIncomplete = true })
end

return source
