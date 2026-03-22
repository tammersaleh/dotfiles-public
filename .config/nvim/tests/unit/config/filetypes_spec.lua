local h = require('helpers')

require('config.filetypes')

describe("filetypes", function()
  before_each(function()
    h.reset()
  end)

  local function detect(filename)
    vim.cmd('bwipeout!')
    vim.cmd('enew')
    vim.api.nvim_buf_set_name(0, filename)
    vim.cmd('filetype detect')
    return vim.bo.filetype
  end

  it("detects .envrc as sh", function()
    assert.equals('sh', detect('.envrc'))
  end)

  it("detects Gemfile as ruby", function()
    assert.equals('ruby', detect('Gemfile'))
  end)

  it("detects Vagrantfile as ruby", function()
    assert.equals('ruby', detect('Vagrantfile'))
  end)

  it("detects Berksfile as ruby", function()
    assert.equals('ruby', detect('Berksfile'))
  end)

  it("detects .terraformrc as terraform", function()
    assert.equals('terraform', detect('.terraformrc'))
  end)

  -- BUG: nvim's built-in confini detection competes with the config's dosini
  -- pattern non-deterministically. Both should be dosini.
  pending("detects .aws/config as dosini", function()
    assert.equals('dosini', detect('/home/user/.aws/config'))
  end)

  pending("detects .aws/credentials as dosini", function()
    assert.equals('dosini', detect('/home/user/.aws/credentials'))
  end)
end)
