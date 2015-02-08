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
  def self.rel(range_category, domain_category, relation)
    rel = new(
      RANGE_CATEGORY => range_category,
      DOMAIN_CATEGORY => domain_category,
      NAME => relation
    )
    puts rel
    rel
  end

  def initialize(options={})
    @name = options.delete(NAME)
    @domain_category = options.delete(DOMAIN_CATEGORY)
    @range_category = options.delete(RANGE_CATEGORY)
  end

  def to_s
    "Every #{@domain_category} has a #{@name} with some #{@range_category}"
  end

  def save(store)
    store.save(self.class, {
      NAME => @name,
      DOMAIN_CATEGORY => @domain_category,
      RANGE_CATEGORY => @range_category
    })
  end
end
