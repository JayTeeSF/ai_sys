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

  def prepare
    puts "FIXME: make me a child of my category (class: #{self.class.inspect})"
  end

  def to_s
    "#{@individual} is a #{@category}"
  end

  def create(options={String => String})
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
      if sub_category_rule = Subcategory.find_by({Subcategory::SUBCATEGORY_KEY => @category}, options)
        @clazz = sub_category_rule.subclass(options)
      elsif super_category_rule = Subcategory.find_by({Subcategory::CATEGORY_KEY => @category}, options)
        @clazz = super_category_rule.superclass(options)
      else
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
require "./subcategory.cr"
