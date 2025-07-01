local on_attach = function(client, bufnr)
  -- Mappings.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- Find root directory
local find_root = function(patterns)
  local path = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(path, ':h')
  while dir ~= '/' do
    for _, pattern in ipairs(patterns) do
      if vim.fn.filereadable(dir .. '/' .. pattern) == 1 then
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ':h')
  end
  return nil
end

-- General LSP keymaps
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Autocmd to start LSP servers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    vim.lsp.start_client({
      name = 'rust-analyzer',
      cmd = { 'rust-analyzer' },
      root_dir = find_root({ 'Cargo.toml' }),
      on_attach = on_attach,
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'typescript', 'javascript', 'typescriptreact', 'javascriptreact'},
  callback = function()
    vim.lsp.start_client({
      name = 'typescript-language-server',
      cmd = { 'typescript-language-server', '--stdio' },
      root_dir = find_root({ 'package.json' }),
      on_attach = on_attach,
    })
  end,
})
