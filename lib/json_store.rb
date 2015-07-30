require 'json'
require 'pstore'

class JsonStore < PStore
  def dump(table)
    JSON.pretty_generate(table)
  end

  def load(content)
    JSON.parse(content)
  end
end
