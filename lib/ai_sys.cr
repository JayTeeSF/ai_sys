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


require "./ai_sys/individual.cr"
require "./ai_sys/relation.cr"
require "./ai_sys/value.cr"
require "./ai_sys/subcategory.cr"
require "./ai_sys/storage_wrapper.cr"

class AiSys
  STORE_KEY = "store"

  def self.classify(str)
    # do we convert _[a-z] => A-Z
    camelize(str.to_s.sub(/.*\./, ""))
  end

  # thx to ActiveSupport::Inflector
  def self.camelize(term)
    string = term.to_s.dup
    if string[0] =~ /[a-z\d]/
      string.capitalize!
    end
    #string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    string.gsub!("/", "::")
    string
  end

  def self.restore(options={String => Array})
    it = new(options)
    puts "empty-repo: #{it.repo.inspect}"
    it.restore
    puts "restored-repo: #{it.repo.inspect}"
    it
  end

  DEFAULT_STORE = StorageWrapper.new
  def initialize(options={String => Array})
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
    puts "persisted-repo: #{repo.inspect}"
    result
  end

  #individual.rb
  def ind(individual, category)
    ind = ::Individual.ind(individual, category)
    if ind.create(AiSys::STORE_KEY => @store)
      ind.save(@store)
    else
      warn "failed to create #{individual} as an instance of #{category}"
    end
    ind
  end

  #relation.rb
  def rel(range_category, domain_category, relation)
    rel = ::Relation.rel(domain_category, relation, range_category)
    if rel.create
      rel.save(@store)
    else
      warn "failed to save the rel"
    end
    rel
  end

  #value.rb
  def val(individual, relation, value)
    val = ::Value.val(individual, relation, value)
    if val.create
      val.save(@store)
    else
      warn "failed to save the value"
    end
    val
  end

  #subcategory.rb
  def sub(subcategory, category)
    sub = ::Subcategory.sub(subcategory, category)
    if sub.create
      sub.save(@store)
    else
      warn "failed to create class hierarcy"
    end
    sub
  end
end
