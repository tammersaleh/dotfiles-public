-- Filetype detection

vim.filetype.add({
  extension = {
    smd = 'slack',
    slack = 'slack',
  },
  filename = {
    ['.envrc'] = 'sh',
    ['Gemfile'] = 'ruby',
    ['Vagrantfile'] = 'ruby',
    ['Berksfile'] = 'ruby',
    ['.terraformrc'] = 'terraform',
  },
})
