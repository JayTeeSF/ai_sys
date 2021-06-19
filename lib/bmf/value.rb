# aka: assigning a value to a relation
# for a particular instance
# x.birthday = "value"
class Value
  RELATION="relation"
  INDIVIDUAL="individual"
  VALUE="value"

  # def self.val(individual, relation, value)
  def self.val(relation, individual, value)
    val = new(
      INDIVIDUAL => individual,
      RELATION => relation,
      VALUE => value
    )
    puts val
    val
  end

  def initialize(options={})
    @individual = options.delete(INDIVIDUAL) # just the name!
    @relation = options.delete(RELATION)
    @value = options.delete(VALUE)
  end

  #def create
  def create(options={})
    puts "Adding a value, such that, #{self}"
  # ais.val("pj", "birthday", "1999-05-20") # this should update the ind. called pj!
    #lookup Individual => @individual
    #give it a relation if it doesn't have one...
    #assign value to it's relation
    #false

    # we haven't defined method calling:
    instance_of_individual.send("#{@relation}=", @value)
    @value == instance_of_individual.send(@relation)
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

  private

  def instance_of_individual
    Individual.find(@individual)
  end
end
