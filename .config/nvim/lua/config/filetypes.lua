-- Filetype detection

vim.filetype.add({
  filename = {
    ['.envrc'] = 'sh',
    ['Gemfile'] = 'ruby',
    ['Vagrantfile'] = 'ruby',
    ['Berksfile'] = 'ruby',
    ['.terraformrc'] = 'terraform',
  },
  pattern = {
    ['.*/%.aws/config'] = 'dosini',
    ['.*/%.aws/credentials'] = 'dosini',
  },
})
