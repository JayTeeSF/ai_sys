class StorageWrapper
  def initialize(options={})
    @repo = options.delete(:repo) || {}
  end

  #def find(key)
  #end

  # the finders will be key!
  def find_by(query_hash)
    class_name = nil
    class_attrs = {}
    #search_key = query_hash.keys.first
    #search_value = query_hash.values.first
    puts "=========================> REPO: #{@repo.inspect}"
    @repo.detect{|_class_name,_all_class_attrs|
      puts "------------------------> _class_name: #{_class_name.inspect}, _all_class_attrs: #{_all_class_attrs.inspect}"
      #found_key = _class_attrs.keys.first
      #found_value = _class_attrs.values.first
      
      #if ( (search_key == found_key) && (search_value == found_value))
      # Find a stored hash that matches the key-value-pairs in the
      # incoming query_hash
      _class_attrs = _all_class_attrs.detect{|stored_attr_hash|
        query_hash.all? {|query_attr, query_value|
          query_value == stored_attr_hash[query_attr]
        }
      }
      if _class_attrs
        class_name = AiSys.classify(_class_name)
        class_attrs = _class_attrs
        true
      else
        false
      end
    }
    if class_name
      if Object.const_defined?(class_name)
        _class = Object.const_get(class_name)
        return _class.new( class_attrs )
      else
        warn "#{search_key} found but not defined: #{search_value}"
      end
    end
    puts "returning nil"
    return nil
  end

  def save(key, attributes={})
    key = key.to_s
    unless @repo[key]
      @repo[key] = []
    end
    @repo[key] << attributes
  end
end
