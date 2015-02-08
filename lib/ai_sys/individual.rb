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

  def create(options={})
    puts "creating #{@individual} as instance of #{@category.inspect}"
    instance(options)
    instance(options).is_a?(clazz(options))
  end

  def save(store)
    store.save(self.class, {
      INDIVIDUAL => @individual,
      CATEGORY => @category,
    })
  end


  private

  def instance(options={})
    unless @instance
      @instance = clazz(options).new # create an instance of @category...
    end
    @instance
  end

  # FIXME: duplicated code (see subcategory#subclass)
  # lookup the class associated with @category
  def clazz(options={})
    unless @clazz
      # these so-called "rules" are actually objects of type @category
      puts "calling Subcategory.find_by w/ #{options.inspect}"
      if sub_category_rule = Subcategory.find_by({Subcategory::SUBCATEGORY_KEY => @category}, options)
        puts "getting sub_cat.subclass(#{options.inspect})"
        @clazz = sub_category_rule.subclass(options)
      elsif super_category_rule = Subcategory.find_by({Subcategory::CATEGORY_KEY => @category}, options)
        puts "got cat.superclass(#{options.inspect})"
        @clazz = super_category_rule.superclass(options)
      else
      puts "setting up a new obj"
        current_context = Object
        unless current_context.const_defined?(@category)
          current_context.const_set(@category, Class.new)
        end
        @clazz = current_context.const_get(@category)
      end
    end
    @clazz
  end
end
require_relative "./subcategory"
