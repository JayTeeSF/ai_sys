class StorageWrapper
  LATEST = -1
  DEFAULT_BASENAME = "storage"
  DB_DIR = File.expand_path("../../../db", __FILE__)
  DB_FILE_GLOB = "#{DB_DIR}/*"

  def initialize(options={})
    @repo = options.delete(:repo) || {}
  end

  # the finders will be key!
  def find(lookup_hash, _class_name)
    puts "looking-up (& instantiating) object for: #{lookup_hash.inspect}"
    _all_class_attrs = (@repo[_class_name]||[])

    # Find a stored hash that matches the key-value-pairs in the
    # incoming lookup_hash
    result = _all_class_attrs.detect do |stored_attr_hash|
      lookup_hash.all? do |lookup_attr, lookup_value|
        lookup_value == stored_attr_hash[lookup_attr]
      end
    end

    # NOT dup'ing the result, before calling .new(result) leads to a BUG
    # that modifies @repo !?
    return result ? result.dup : result
  end

  def restore(version=LATEST)
    print "restoring"
    current_db_files = dbs
    if LATEST == version
      puts " the latest version..."
      db_file = current_db_files.first
    else
      puts " version: #{version}..."
      db_file = current_db_files.detect do |f|
        file_to_extension_number(f) == version
      end
    end

    # unmarshall
    if db_file
      @repo = reload(db_file)
      true
    else
      puts "no-op (no db(s))"
      false
    end
  end

  def persist
    print "storing to"
    file_name = new_db
    if file_name
      print " new_db: "
    else
      if file_name = default_db
        print " default_db: "
      else
        return false
      end
    end
    _data_dump = data_dump
    if _data_dump == latest_data_load
      puts " no-op (duplicate)..."
      false
    else
      puts " #{file_name}..."
      store(_data_dump, file_name)
      true
    end
  end

  def save(key, attributes={})
    key = key.to_s
    unless @repo[key]
      puts "REPO adding array of: #{key}'s"
      @repo[key] = []
    end
    if @repo[key].include?(attributes)
      puts "REPO[#{key}]: no-op (duplicate)"
    else
      puts "REPO[#{key}] << #{attributes.inspect}"
      @repo[key].<<(attributes)
    end
  end


  private

  def data_dump
    Marshal.dump(@repo)
  end

  def reload(db_file)
    Marshal.load(data_load(db_file))
  end

  def data_load(db_file)
    File.read(db_file)
  end

  def latest_data_load
    return unless latest_db
    data_load(latest_db)
  end

  def default_db_basename
    "#{DB_DIR}/#{DEFAULT_BASENAME}"
  end

  def default_db
    pieces_to_file_name(
      [default_db_basename, 1]
    )
  end

  def latest_db
    dbs.first
  end

  def new_db
    if file_name = latest_db
      pieces = file_pieces(file_name)
      extension = pieces.pop.to_i
      pieces << extension + 1
      pieces_to_file_name(pieces)
    end
  end

  def store(data, file_name)
    File.open(file_name, 'w') { |f| f.write(data) }
  end

  # reverse sort files by extension
  def dbs
    db_files.sort do |a,b|
      file_to_extension_number(b) <=> file_to_extension_number(a)
    end
  end

  def db_files
    Dir.glob(DB_FILE_GLOB)
  end

  def pieces_to_file_name(pieces)
    pieces.join('.')
  end

  def file_pieces(file_name)
    file_name.split('.')
  end

  def file_to_extension_number(file_name)
    file_name.match(/\.(\d+)$/)[1].to_i
  end
end
