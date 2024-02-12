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

vim.g.at_custom_alternates = {
    ["=="] = "!=",
    ["y"] = "n",
    ["yes"] = "no",
    ["&&"] = "||",
}
