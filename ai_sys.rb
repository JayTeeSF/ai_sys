# irb -r "./ai_sys.rb"
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


require_relative "./individual"
require_relative "./relation"
require_relative "./value"
require_relative "./subcategory"
require_relative "./storage_wrapper"

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

  DEFAULT_STORE = StorageWrapper.new
  def initialize
    @store = DEFAULT_STORE
  end

  def repo
    @store
  end

  #individual.rb
  def ind(individual, category)
    ind = ::Individual.ind(individual, category, @store)
    #ind.save(@store)
    if ind.create
      ind.save #(@store)
    else
      warn "failed to create #{individual} as an instance of #{category}"
    end
  end

  #relation.rb
  def rel(range_category, domain_category, relation)
    rel = ::Relation.rel(domain_category, relation, range_category)
    rel.save(@store)
  end

  #value.rb
  def val(individual, relation, value)
    val = ::Value.val(individual, relation, value)
    #val.create
    val.save(@store)
  end

  #subcategory.rb
  def sub(subcategory, category, options={})
    sub = ::Subcategory.sub(subcategory, category, options)
    if sub.create
      sub.save #(@store)
    else
      warn "failed to create class hierarcy"
    end
  end
end
