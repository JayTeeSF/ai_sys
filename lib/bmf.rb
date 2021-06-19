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
    camelize(str.to_s.sub(/.*\./, ""))
  end

  # thx to ActiveSupport::Inflector
  def self.camelize(term)
    string = term.to_s.dup
    #string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    if string[0] =~ /[a-z\d]/
      string.capitalize!
    end
    string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    string.gsub!("/", "::")
    string
  end

  def self.restore(options={})
    it = new(options)
    puts "empty-repo: #{it.repo.inspect}"
    it.restore
    puts "restored-repo: #{it.repo.inspect}"
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
  #def rel(range_category, domain_category, relation)
  def rel(relation, domain_category, range_category)
    # rel = ::Relation.rel(domain_category, range_category, relation)
    rel = ::Relation.rel(relation, domain_category, range_category)
      #domain_category, relation, range_category)
    #if rel.create
    if rel.create(AiSys::STORE_KEY => @store)
      rel.save(@store)
    else
      warn "failed to save the rel"
    end
    rel
  end

  #value.rb
  # def val(individual, relation, value)
  def val(relation, individual, value)
    # val = ::Value.val(individual, relation, value)
    val = ::Value.val(relation, individual, value)
    # if val.create
    if val.create(AiSys::STORE_KEY => @store)
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
