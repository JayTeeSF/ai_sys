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
  #   Official p 485/486
  #   # rel(birthday: Relation, animal: Domain, date: Range)
  #   hmm:
  #   "animal", "birthday", "date"

  def self.rel(domain_category, relation, range_category)
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

  #Return: [obj, err]
  # alias for to_ruby
  def create(options={})
    created = nil
    error = nil
    #lookup category => @domain_category
    _ruby_sub = ::Subcategory.clazz_for(@domain_category, options)
    # _ruby_sub, error = sub.create #(options)
    #no need to check it's subcategories
    _ruby_sub.send(:define_method, "#{@name}=") { |val| instance_variable_set("@name", val) }
    _ruby_sub.send(:define_method, @name) { instance_variable_get("@name") }
    instance = _ruby_sub.new
    created = instance.method(@name)
    unless created
      error = "Failed to create #{@name} relation for #{@domain_category} category"
    end
    [created, error]
  end

  def to_s
    "The #{@name} Relation holds between each #{@domain_category} and some #{@range_category}"
    # "Every #{@domain_category} has a #{@name} with some #{@range_category}"
  end

  def save(store)
    store.save(self.class, {
      NAME => @name,
      DOMAIN_CATEGORY => @domain_category,
      RANGE_CATEGORY => @range_category
    })
  end
end
require_relative "./subcategory"
