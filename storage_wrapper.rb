class StorageWrapper
  def initialize(options={})
    @repo = options.delete(:repo) || {}
  end

  #def find(key)
  #end

  # the finders will be key!
  def find_by(attribute_hash)
    class_name = nil
    class_attrs = {}
    search_key = attribute_hash.keys.first
    search_value = attribute_hash.values.first
    @repo.select{|_class_name,_class_attrs|
      found_key = _class_attrs.keys.first
      found_value = _class_attrs.values.first
      if ( (search_key == found_key) && (search_value == found_value))
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
