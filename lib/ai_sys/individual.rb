# aka: instance of a Category
class Individual
  CATEGORY   = "category"
  INDIVIDUAL = "individual"

  def self.find(name, options={})
    return nil unless name
    puts "Finding #{self} named: #{name.inspect}..."
    store = options[AiSys::STORE_KEY] || AiSys::DEFAULT_STORE
    attrs = store.find({INDIVIDUAL => name}, self.to_s)
    attrs ? new(attrs) : attrs
  end

  def self.ind(individual, category, options={})
    ind = new(options.merge({INDIVIDUAL => individual, CATEGORY => category}))
    puts ind
    ind
  end

  def initialize(options={})
    @store = options[AiSys::STORE_KEY] || AiSys::DEFAULT_STORE
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

  def save(store=@store)
    store.save(self.class, {
      INDIVIDUAL => @individual,
      CATEGORY => @category,
    })
  end

  ASSIGNMENT_OPERATOR = '='.freeze
  # handle method calling...
  # TODO: consider restricting to methods created on this instance or a parent-class
  def method_missing(method, *args, &block)
    # check for methods on @individual
    #send(method, *args, &block)
    if ASSIGNMENT_OPERATOR == method[-1]
      # save a Val object:
      method_var = method[0..-2].to_s
      value = args.join(", ")
      val = ::Value.val(method_var, @individual, value)
      val.save(@store)
      #if val.create(AiSys::STORE_KEY => @store)
      #else
      #  warn "failed to save the value: #{value.inspect}"
      #end

      #cache:
      #instance_variable_set("@#{method_var}", value)
    else
      method_var = method.to_s
      # read from the Val object ?!
      val = ::Value.find(method_var, @individual, AiSys::STORE_KEY => @store)
      return val.value
    end
    # or on @category
  end

  private

  def instance_of(category, options={})
    unless @instance
      @instance = Subcategory.clazz_for(category, options).new # create an instance of category...
    end
    @instance
  end
end
require_relative "./subcategory"
