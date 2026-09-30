return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  priority = 1000,
  keys = {
    -- stylua: ignore start
    -- Navigating
    { "<c-h>", function() require("smart-splits").move_cursor_left() end,  desc = "Resize left",  mode = {"n", "t", "x"} },
    { "<c-j>", function() require("smart-splits").move_cursor_down() end,  desc = "Resize down",  mode = {"n", "t", "x"} },
    { "<c-k>", function() require("smart-splits").move_cursor_up() end,    desc = "Resize up",    mode = {"n", "t", "x"} },
    { "<c-l>", function() require("smart-splits").move_cursor_right() end, desc = "Resize right", mode = {"n", "t", "x"} },
    -- Resizing
    { "<c-a-h>", function() require("smart-splits").resize_left() end,  desc = "Resize left",  mode = {"n", "t", "x"} },
    { "<c-a-j>", function() require("smart-splits").resize_down() end,  desc = "Resize down",  mode = {"n", "t", "x"} },
    { "<c-a-k>", function() require("smart-splits").resize_up() end,    desc = "Resize up",    mode = {"n", "t", "x"} },
    { "<c-a-l>", function() require("smart-splits").resize_right() end, desc = "Resize right", mode = {"n", "t", "x"} },
    -- stylua: ignore end
  },
}
