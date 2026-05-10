-- Override astrocommunity harpoon mappings to avoid clashes with C-x/C-n/C-p
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      -- nuke clashing maps from astrocommunity harpoon pack
      maps.n["<C-x>"] = false
      maps.n["<C-p>"] = false
      maps.n["<C-n>"] = false

      local prefix = "<Leader><Leader>"
      maps.n[prefix .. "n"] = {
        function() require("harpoon"):list():next() end,
        desc = "Harpoon next mark",
      }
      maps.n[prefix .. "p"] = {
        function() require("harpoon"):list():prev() end,
        desc = "Harpoon prev mark",
      }
      -- jump to mark 1..4 with <Leader>1..4
      for i = 1, 4 do
        maps.n["<Leader>" .. i] = {
          function() require("harpoon"):list():select(i) end,
          desc = "Harpoon mark " .. i,
        }
      end
    end,
  },
}
