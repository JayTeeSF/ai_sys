# irb -r "./lib/ai_sys.rb"
#> ais = AiSys.new
#> ais.public_methods(false)
#> ais.sub("cat", "animal")
#> ais.ind("pj", "cat")
#> ais.sub("dog", "wolf")
#> ais.sub("wolf", "animal")
#  1) can we treat repo like an event-log (i.e. replayable)
#  2) can we dynamically setup class hierarchies
#     i.e. make dog a subclass of wolf a subclass of animal a subclass of Category
#> ais.repo
# => #<StorageWrapper:0x007f82a101b578 @repo={
# "Subcategory"=>[{"subcategory"=>"cat", "category"=>"animal"},
#                 {"subcategory"=>"wolf", "category"=>"animal"},
#                 {"subcategory"=>"dog", "category"=>"wolf"}],
# "Individual"=>[{"individual"=>"pj", "category"=>"cat"}]
# }>


require_relative "./ai_sys/individual"
require_relative "./ai_sys/relation"
require_relative "./ai_sys/value"
require_relative "./ai_sys/subcategory"
require_relative "./ai_sys/storage_wrapper"

class AiSys
  STORE_KEY = "store"

  def self.classify(str)
    # do we convert _[a-z] => A-Z
    camelize(str.to_s.sub(/.*\./, ''))
  end

  # thx to ActiveSupport::Inflector
  def self.camelize(term)
    string = term.to_s
    string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    string.gsub!('/', '::')
    string
  end

  def self.restore(options={})
    it = new(options)
    puts "\nStarting with an Empty Repo: #{it.repo.inspect}"
    it.restore
    puts "Continuing with Repo: #{it.repo.inspect}\n\n"
    it
  end

  DEFAULT_STORE = StorageWrapper.new
  def initialize(options={})
    @store = options.delete(AiSys::STORE_KEY) || DEFAULT_STORE
  end

  def repo
    @store
  end

  def restore
    @store.restore
  end

  def save
    result = @store.persist
    puts "\nPersisted Repo: #{repo.inspect}\n"
    result
  end

  #individual.rb
  def ind(individual, category)
    ind = ::Individual.ind(individual, category)
    _ruby_ind, error = ind.create(AiSys::STORE_KEY => @store)
    if error
      warn "\t*** FAILED: to create #{individual} as an instance of #{category}: #{error}\n"
    else
      ind.save(@store)
    end
    ind
  end

  #relation.rb
  def rel(domain_category, relation, range_category)
    rel = ::Relation.rel(domain_category, relation, range_category)
    _ruby_rel, error = rel.create #(AiSys::STORE_KEY => @store)
    if error
      warn "\t*** FAILED: to save the rel: #{error}\n"
    else
      rel.save(@store)
    end
    rel
  end

  #value.rb
  def val(individual, relation, value)
    val = ::Value.val(individual, relation, value)
    # if val.create
    _ruby_val, error = val.create(AiSys::STORE_KEY => @store)
    if error
      warn "\t*** FAILED: to save the value: #{error}\n"
    else
      val.save(@store)
    end
    val
  end

  #subcategory.rb
  def sub(subcategory, category)
    sub = ::Subcategory.sub(subcategory, category)
    _ruby_sub, error = sub.create
    if error
      warn "\t*** FAILED: to create class hierarcy: #{error}\n"
    else
      sub.save(@store)
    end
    sub
  end
end
