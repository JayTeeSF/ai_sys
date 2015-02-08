# aka: a Class / SubClass hierarchy
class Subcategory
  SUBCATEGORY_KEY = "subcategory"
  CATEGORY_KEY    = "category"
  CONTEXT_KEY     = "context"

  def self.sub(subcategory, category, options={})
    attrs = {
      SUBCATEGORY_KEY => subcategory,
      CATEGORY_KEY    => category
    }
    sub = new( attrs )
    puts sub
    sub
  end

  def self.find_by(lookup_hash, store=AiSys::DEFAULT_STORE)
    return nil unless lookup_hash
    puts "finding rules for: #{lookup_hash.inspect}"
    store.find_by(lookup_hash)
  end

  def initialize(options={})
    @subcategory = options.delete(SUBCATEGORY_KEY)
    @category = options.delete(CATEGORY_KEY)
    @context = options.delete(CONTEXT_KEY) || Object
    unless options.key?(AiSys::STORE_KEY)
      options.merge!({AiSys::STORE_KEY => AiSys::DEFAULT_STORE})
    end
    @store = options.delete(AiSys::STORE_KEY)
    fail("missing store") unless @store
    fail("missing subcat") unless @subcategory
    fail("missing cat") unless @category
  end

  def to_s
    "#{@subcategory} is a subcategory of #{@category}"
  end

  def superclass
    unless @superclass
      if @context.const_defined?(superclass_name)
        @superclass = @context.const_get(superclass_name)
        if !@superclass.is_a?(Class)
          warn "Unexpected constant type for #{@category}"
        end
      else
        # Run extant "rules" that define @category as @subcategory
        #if parent_category_rule = Subcategory.find_by({CATEGORY_KEY => @category}, @store)
        if parent_category_rule = Subcategory.find_by({SUBCATEGORY_KEY => @category}, @store)
          @superclass = parent_category_rule.subclass
        else
          # there is no superclass rule...
          # set parent/category to Object
          current_context = @context
          current_context.const_set(superclass_name, Class.new)
          @superclass = current_context.const_get(superclass_name)
        end
      end
    end
    @superclass
  end

  def subclass
    unless @subclass
      puts "got superclass: #{superclass}"
      @context.const_set(subclass_name, Class.new(superclass))
      @subclass = @context.const_get(subclass_name)
      puts "#{@subclass} is_a?(#{superclass}): #{@subclass < superclass}"
    end
    @subclass
  end

  def superclass_name
    AiSys.classify(@category)
  end

  def subclass_name
    AiSys.classify(@subcategory)
  end

  def create
    puts "creating #{subclass_name} as subclass of #{superclass.inspect}"
    subclass
    subclass < superclass
  end

  def save(store=@store)
    store.save(AiSys.classify(self.class), {
      SUBCATEGORY_KEY => @subcategory,
      CATEGORY_KEY    => @category,
    })
  end
end
