# aka: a Class / SubClass hierarchy
class Subcategory
  SUBCATEGORY_KEY = "subcategory"
  CATEGORY_KEY    = "category"
  CONTEXT_KEY     = "context"

  def self.sub(subcategory, category, options={})
    sub = new(options.merge({
      SUBCATEGORY_KEY => subcategory,
      CATEGORY_KEY    => category
    }))
    puts sub
    sub
  end

  def self.find_by(lookup_hash, options={})
    return nil unless lookup_hash # or do we return anything or the first thing!?
    puts "Finding #{self} rules for: #{lookup_hash.inspect}..."
    store = options[AiSys::STORE_KEY] || AiSys::DEFAULT_STORE
    attrs = store.find(lookup_hash, self.to_s)
    attrs ? new(attrs) : attrs
  end

  def initialize(options={})
    @subcategory = options.delete(SUBCATEGORY_KEY)
    @category = options.delete(CATEGORY_KEY)
    @context = options.delete(CONTEXT_KEY) || Object
    fail("missing subcat") unless @subcategory
    fail("missing cat") unless @category
  end

  def to_s
    "#{@subcategory} is a subcategory of #{@category}"
  end

  def create(options={})
    puts "creating #{subclass_name} as subclass of #{superclass(options).inspect}"
    subclass(options)
    subclass(options) < superclass(options) # true/false
  end

  def save(store=@store)
    store.save(AiSys.classify(self.class), {
      SUBCATEGORY_KEY => @subcategory,
      CATEGORY_KEY    => @category,
    })
  end

  def superclass(options={})
    unless @superclass
      if @context.const_defined?(superclass_name)
        @superclass = @context.const_get(superclass_name)
        if !@superclass.is_a?(Class)
          warn "Unexpected constant type for #{@category}"
        end
      else
        # Run extant "rules" that define @category as @subcategory
        #if parent_category_rule = Subcategory.find_by({CATEGORY_KEY => @category}, @store)
        if parent_category_rule = Subcategory.find_by({SUBCATEGORY_KEY => @category}, options) #, @store)
          @superclass = parent_category_rule.subclass(options)
        else
          # there is no superclass rule...
          # set parent/category to Object
          current_context = @context
          # FIXME: duplicated code (see #subclass as well as, individual#clazz)
          unless current_context.const_defined?(superclass_name)
            current_context.const_set(superclass_name, Class.new)
          end
          @superclass = current_context.const_get(superclass_name)
        end
      end
    end
    @superclass
  end

  # FIXME: duplicated code (see individual#clazz)
  def subclass(options={})
    unless @subclass
      puts "got superclass: #{superclass(options)}"
      unless @context.const_defined?(subclass_name)
        @context.const_set(subclass_name, Class.new(superclass(options)))
      end
      @subclass = @context.const_get(subclass_name)
      puts "#{@subclass} is_a?(#{superclass(options)}): #{@subclass < superclass(options)}"
    end
    @subclass
  end

  def superclass_name
    AiSys.classify(@category)
  end

  def subclass_name
    AiSys.classify(@subcategory)
  end
end
