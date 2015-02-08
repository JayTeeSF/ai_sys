# aka: assigning a value to a relation
# for a particular instance
# x.birthday = "value"
class Value
  RELATION="relation"
  INDIVIDUAL="individual"
  VALUE="value"

  def self.val(individual, relation, value)
    val = new(
      INDIVIDUAL => individual,
      RELATION => relation,
      VALUE => value
    )
    puts val
    val
  end

  def initialize(options={})
    @individual = options.delete(INDIVIDUAL)
    @relation = options.delete(RELATION)
    @value = options.delete(VALUE)
  end

  def to_s
    "#{@individual}'s #{@relation} is #{@value}"
  end

  def save(store)
    store.save(self.class, {
      INDIVIDUAL => @individual,
      RELATION => @relation,
      VALUE => @value,
    })
  end
end
