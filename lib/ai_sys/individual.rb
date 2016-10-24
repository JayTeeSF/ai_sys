# aka: instance of a Category
class Individual
  CATEGORY   = "category"
  INDIVIDUAL = "individual"

  def self.ind(individual, category)
    ind = new(INDIVIDUAL => individual, CATEGORY => category)
    puts
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

  # Return: [obj, err]
  def create(options={})
    error = nil
    puts "\nCREATING #{@individual} as an instance of #{@category.inspect}\n"
    created = instance_of(@category, options)
    if created.is_a?(Subcategory.clazz_for(@category, options))
      error = "Failed to create individual"
    end
    # lookup and extend any relations
    # lookup any values and assign them
    [created, error]
  end

  def save(store)
    store.save(self.class, {
      INDIVIDUAL => @individual,
      CATEGORY => @category,
    })
  end

  def instance_of(category, options={})
    unless @instance
      @instance = Subcategory.clazz_for(category, options).new # create an instance of category...
    end
    @instance
  end
end
require_relative "./subcategory"
