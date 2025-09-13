local json = require("dkjson")

local function dirname(path)
  return path:match("^(.*)/[^/]+$") or "."
end

function Pandoc(doc)
  if quarto.doc.input_file and quarto.doc.input_file:match("index%.ipynb$") then
    local base_dir = dirname(quarto.doc.input_file)
    local f = io.open("_quarto.yml", "r")
    local content = f:read("*all")
    f:close()

    local items = {}
    for line in content:gmatch("[^\r\n]+") do
      local entry = line:match('^%s*%-%s*"([^"]+%.ipynb)"')
      if entry and entry ~= "index.ipynb" then
        local filepath = base_dir .. "/" .. entry
        local f2 = io.open(filepath, "r")
        if f2 then
          local nbcontent = f2:read("*all")
          f2:close()

          local nb, pos, err = json.decode(nbcontent)
          local title = entry:gsub("%.ipynb$", "")

          if nb and nb.cells then
            for _, cell in ipairs(nb.cells) do
              if cell.cell_type == "markdown" and cell.source then
                for _, line in ipairs(cell.source) do
                  local h1 = line:match("^#%s+(.+)")
                  if h1 then
                    title = h1
                    break
                  end
                end
              end
              if title ~= entry:gsub("%.ipynb$", "") then
                break
              end
            end
          end

          local link = entry:gsub("%.ipynb$", ".html")
          table.insert(items, { pandoc.Plain({ pandoc.Link(title, link) }) })
        end
      end
    end

    if #items > 0 then
      local header = pandoc.Header(2, "목차")
      local list = pandoc.BulletList(items)
      table.insert(doc.blocks, 2, header)
      table.insert(doc.blocks, 3, list)
    end
  end
  return doc
end
