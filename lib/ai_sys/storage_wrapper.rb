class StorageWrapper
  def initialize(options={})
    @repo = options.delete(:repo) || {}
  end

  # the finders will be key!
  def find(lookup_hash, _class_name)
    puts "looking-up (& instantiating) object for: #{lookup_hash.inspect}"
    puts "=========================> REPO: #{@repo[_class_name].inspect}"
    _all_class_attrs = (@repo[_class_name]||[])
    puts "------------------------> _all_class_attrs: #{_all_class_attrs.inspect}"

    # Find a stored hash that matches the key-value-pairs in the
    # incoming lookup_hash
    result = _all_class_attrs.detect{|stored_attr_hash|
      lookup_hash.all? {|lookup_attr, lookup_value|
        lookup_value == stored_attr_hash[lookup_attr]
      }
    }

    # NOT dup'ing the result, before calling .new(result) leads to a BUG
    # that modifies @repo !?
    return result ? result.dup : result
  end

  def load
    # from some file
    # unmarshall
  end

  def persist
    #marshall.dump @repo
    # to some file
  end

  def save(key, attributes={})
    key = key.to_s
    unless @repo[key]
      puts "XXXXXXXX no #{key} in repo!"
      @repo[key] = []
    end
    if @repo[key].include?(attributes)
      puts "XXXXXXXX modifying repo[#{key}]: no-op"
    else
      puts "XXXXXXXX modifying repo[#{key}]: #{attributes.inspect}"
      @repo[key].<<(attributes)
    end
  end
end
