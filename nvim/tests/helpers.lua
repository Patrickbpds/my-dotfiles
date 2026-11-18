local M = {}

function M.write(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

function M.with_project(files, fn)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")

  for path, content in pairs(files) do
    M.write(dir .. "/" .. path, content)
  end

  local previous = vim.uv.cwd()
  vim.cmd("silent! enew!")
  vim.cmd("cd " .. vim.fn.fnameescape(dir))

  local ok, err = pcall(fn, dir)

  vim.cmd("cd " .. vim.fn.fnameescape(previous))
  vim.fn.delete(dir, "rf")
  assert(ok, err)
end

function M.assert_equal(actual, expected, label)
  assert(actual == expected, string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)))
end

return M
