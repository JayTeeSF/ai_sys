# aka: instance of a Category
class Individual
  CATEGORY   = "category"
  INDIVIDUAL = "individual"

  def self.ind(individual, category)
    ind = new(INDIVIDUAL => individual, CATEGORY => category)
    puts ind
    ind
  end

  def initialize(options={})
    @individual = options.delete(INDIVIDUAL)
    @category = options.delete(CATEGORY)
  end

  def to_s
    "#{@individual} is a #{@category}"
  end

  def create
    puts "creating #{@individual} as instance of #{@category.inspect}"
    instance
    instance.is_a?(clazz)
  end

  def instance
    unless @instance
      @instance = clazz.new
    end
    @instance
  end

  def clazz
    unless @clazz
      if sub_category_rule = Subcategory.find_by({Subcategory::SUBCATEGORY_KEY => @category})
        @clazz = sub_category_rule.subclass
      elsif super_category_rule = Subcategory.find_by({Subcategory::CATEGORY_KEY => @category})
        @clazz = super_category_rule.superclass
      else
        current_context = Object
        current_context.const_set(@category, Class.new)
        @clazz = current_context.const_get(@category)
      end
    end
    @clazz
  end

  def save(store)
    store.save(self.class, {
      INDIVIDUAL => @individual,
      CATEGORY => @category,
    })
  end
end
