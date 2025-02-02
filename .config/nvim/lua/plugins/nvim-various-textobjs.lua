return {
  "chrisgrieser/nvim-various-textobjs",
  lazy = false,
  keys = {
    {
      'ii', '<cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
      mode = {'o','x'},
    },
    {
      'ai', '<cmd>lua require("various-textobjs").indentation("outer", "outer")<CR>',
      mode = {'o','x'},
    },
    {
      'I', '<cmd>lua require("various-textobjs").restOfIndentation()<CR>',
      mode = {'o','x'},
    },
    {
      's', '<cmd>lua require("various-textobjs").subword()<CR>',
      mode = {'o','x'},
    },
    {
      'iq', '<cmd>lua require("various-textobjs").anyQuote("inner")<CR>',
      mode = {'o','x'},
    },
    {
      'aq', '<cmd>lua require("various-textobjs").anyQuote("outter")<CR>',
      mode = {'o','x'},
    },
    {
      'io', '<cmd>lua require("various-textobjs").anyBracket("inner")<CR>',
      mode = {'o','x'},
    },
    {
      'ao', '<cmd>lua require("various-textobjs").anyBracket("outter")<CR>',
      mode = {'o','x'},
    },
    {
      'ib', '<cmd>lua require("various-textobjs").entireBuffer()<CR>',
      mode = {'o','x'},
    },
    {
      '|', '<cmd>lua require("various-textobjs").column()<CR>',
      mode = {'o','x'},
    },
    {
      'ik', '<cmd>lua require("various-textobjs").key("inner")<CR>',
      mode = {'o','x'},
    },
    {
      'iv',
      '<cmd>lua require("various-textobjs").value("inner")<CR>',
      mode = {'o','x'},
    },
  },
  opts = {
    keymaps = {
      -- set my own above
      useDefaults = false,
    },

    forwardLooking = {
      -- Number of lines to seek forwards for a text object. See the overview
      -- table in the README for which text object uses which value.
      small = 5,
      big = 15,
    },

    behavior = {
      -- save position in jumplist when using text objects
      jumplist = true,
    },

    -- extra configuration for specific text objects
    textobjs = {
      indentation = {
        -- `false`: only indentation decreases delimit the text object
        -- `true`: indentation decreases as well as blank lines serve as delimiter
        blanksAreDelimiter = false,
      },
      subword = {
        -- When deleting the start of a camelCased word, the result should
        -- still be camelCased and not PascalCased (see #113).
        noCamelToPascalCase = true,
      },
      diagnostic = {
        wrap = true,
      },
      url = {
        patterns = {
          [[%l%l%l-://[^%s)%]}"'`]+]], -- exclude ) for md, "'` for strings, } for bibtex
        },

      },
    }
  }
}
