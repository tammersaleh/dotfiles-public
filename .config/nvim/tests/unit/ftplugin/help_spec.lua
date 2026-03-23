local h = require('helpers')

describe("ftplugin/help", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'help'
  end)

  it("maps K to jump to tag", function()
    h.assert_buf_keymap('n', 'K', '<C-]>')
  end)

  it("maps Enter to jump to tag", function()
    h.assert_buf_keymap('n', '<CR>', '<C-]>')
  end)
end)
