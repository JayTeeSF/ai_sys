#Perhaps (re-/)open a mixin <class:Animal>Relation
# then add the method or attribute
# tbd, how-to enable a function (not just a static-value)
# ...what ?common? arguments to pass
###
# aka: a method / attribute of a class
# perhaps it's an instance-method and its argument/return-value:
# class Animal
#   def birthday(date?!)
#     @birthday # (some date)
#   end
#   # or
#   Birthday = lambda {|date| }
#   # or
#   @birthday = lambda {|date| }
#
#   # or ...see Value...
#   def birthday=(date?!)
#     @birthday = date
#   end
# end
class Relation
  NAME = "name"
  DOMAIN_CATEGORY = "domain_category"
  RANGE_CATEGORY = "range_category"

  # rel birthday animal date
  #     relation domain range
  # => the birthday relation holds between each animal and some date
  # (range: "date", domain: "animal", relation: "birthday")
  #def self.rel(range_category, domain_category, relation)
  def self.rel(relation, domain_category, range_category)
    rel = new(
      NAME => relation,
      DOMAIN_CATEGORY => domain_category,
      RANGE_CATEGORY => range_category
    )
    puts
    puts rel
    rel
  end

  def initialize(options={})
    @name = options.delete(NAME)
    @domain_category = options.delete(DOMAIN_CATEGORY)
    @range_category = options.delete(RANGE_CATEGORY)
  end

  # def create
  def create(options={})
    puts "Adding a relation, such that, #{self}"
    relation(options)
    clazz(options).instance_methods.include?(@name.to_sym) &&
      clazz(options).instance_methods.include?("#{@name}=".to_sym)
  end

  def to_s
    "Every #{@domain_category}(d) has a #{@name} with some #{@range_category}(r)"
  end

  def save(store)
    store.save(self.class, {
      NAME => @name,
      DOMAIN_CATEGORY => @domain_category,
      RANGE_CATEGORY => @range_category
    })
  end

  private

  #FIXME: what (context?!) persists these method definitions in the class,
  #the next time the class is looked-up?!
  def relation(options={})
    unless @relation
      _clazz = clazz(options)
      # TBD: restrict these methods to only accept/return
      # objects of type @domain_category
      _clazz.send(:define_method, "#{@name}=") { |value|
        instance_variable_set("@#{@name}", value)
      }
      _clazz.send(:define_method, @name) {
        instance_variable_get("@#{@name}")
      }
      @relation = true
    end
    @relation
  end

  # FIXME: duplicated code (see subcategory#subclass)
  # lookup the class associated with @domain_category
  def clazz(options={})
    unless @clazz
      # these so-called "rules" are actually objects of type @domain_category
      if sub_category_rule = Subcategory.find_by({Subcategory::SUBCATEGORY_KEY => @domain_category}, options)
        @clazz = sub_category_rule.subclass(options)
      elsif super_category_rule = Subcategory.find_by({Subcategory::CATEGORY_KEY => @domain_category}, options)
        @clazz = super_category_rule.superclass(options)
      else
        current_context = Object
        unless current_context.const_defined?(@domain_category)
          current_context.const_set(@domain_category, Class.new)
        end
        @clazz = current_context.const_get(@domain_category)
      end
    end
    @clazz
  end
end
require_relative "./subcategory"
