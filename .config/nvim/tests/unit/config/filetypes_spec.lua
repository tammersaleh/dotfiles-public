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

  it("detects .aws/config as confini", function()
    assert.equals('confini', detect('/home/user/.aws/config'))
  end)

  it("detects .aws/credentials as confini", function()
    assert.equals('confini', detect('/home/user/.aws/credentials'))
  end)
end)
