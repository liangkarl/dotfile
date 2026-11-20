-- rmagatti/alternate-toggler
-- https://github.com/rmagatti/alternate-toggler
-- Alternate Toggler is a very small plugin for toggling alternate "boolean" values.

-- {
-- ["true"] = "false",
-- ["True"] = "False",
-- ["TRUE"] = "FALSE",
-- ["Yes"] = "No",
-- ["YES"] = "NO",
-- ["1"] = "0",
-- ["<"] = ">",
-- ["("] = ")",
-- ["["] = "]",
-- ["{"] = "}",
-- ['"'] = "'",
-- ['""'] = "''",
-- ["+"] = "-",
-- ["==="] = "!=="
-- }

return { -- switch boolean value easily,
    'rmagatti/alternate-toggler',
    config = function()
        vim.g.at_custom_alternates = {
            ["=="] = "!=",
            ["y"] = "n",
            ["yes"] = "no",
            ["&&"] = "||",
        }
    end
}
