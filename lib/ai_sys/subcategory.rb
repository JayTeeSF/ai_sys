require_relative "./overrides"
# aka: a Class / SubClass hierarchy
class Subcategory
  SUBCATEGORY_KEY = "subcategory"
  CATEGORY_KEY    = "category"
  CONTEXT_KEY     = "context"

  # FIXME: duplicated code (see subcategory#subclass)
  # lookup the class associated with category
  def self.clazz_for(category, options={})
    unless @clazz
      # these so-called "rules" are actually objects of type category
      if sub_category_rule = Subcategory.find_by({Subcategory::SUBCATEGORY_KEY => category}, options)
        @clazz = sub_category_rule.subclass(options)
      elsif super_category_rule = Subcategory.find_by({Subcategory::CATEGORY_KEY => category}, options)
        @clazz = super_category_rule.superclass(options)
      else
        current_context = Object
        unless current_context.const_defined?(category)
          current_context.const_set(category, Class.new)
        end
        @clazz = current_context.const_get(category)
      end
    end
    @clazz
  end

  def self.find_all_by(lookup_hash, options={})
    return [] unless lookup_hash
    puts "\nFinding All #{self} rules for: #{lookup_hash.inspect}...\n"
    store = options[AiSys::STORE_KEY] || AiSys::DEFAULT_STORE
    all_attrs = store.find_all(lookup_hash, self.to_s)

    return all_attrs.map { |attrs|
      attrs ? new(attrs) : attrs
    }
  end

  def self.find_by(lookup_hash, options={})
    return nil unless lookup_hash # or do we return anything or the first thing!?
    puts "\nFinding #{self} rules for: #{lookup_hash.inspect}...\n"
    store = options[AiSys::STORE_KEY] || AiSys::DEFAULT_STORE
    attrs = store.find(lookup_hash, self.to_s)
    attrs ? new(attrs) : attrs
  end

  def self.sub(subcategory, category, options={})
    sub = new(options.merge({
      SUBCATEGORY_KEY => subcategory,
      CATEGORY_KEY    => category
    }))
    puts
    puts sub
    sub
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

  # Return: [obj, err]
  def create(options={})
    error = nil
    puts "\nCREATING #{subclass_name} as subclass of #{superclass(options).inspect}"
    created = subclass(options)
    unless created < superclass(options)
      error = "Failed to create subcategory"
      puts "\t! subclass(#{created.inspect}) < superclass(#{superclass(options).inspect})"
    end
    # need to find all relations that are stored specifically for this
    # class (i.e. subclass)
    # and define them on this subclass
    puts
    [created, error]
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
      puts "\tgot superclass: #{superclass(options)}"
      # FORCE subclassing... to fix hierarchy bug !?
      suppress_warnings {
        @context.const_set(subclass_name, Class.new(superclass(options)))
      }
      @subclass = @context.const_get(subclass_name)
      unless @subclass < superclass(options)
        warn "class-hierarchy ordering bug"
      end
      puts "\t#{@subclass} is_a?(#{superclass(options)}): #{@subclass < superclass(options)}\n"
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
