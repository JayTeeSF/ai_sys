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
    puts
    puts val
    val
  end

  def initialize(options={})
    @individual = options.delete(INDIVIDUAL)
    @relation = options.delete(RELATION)
    @value = options.delete(VALUE)
  end

  #Return: [obj, err]
  def create(options={})
    created = error = nil
  # ais.val("pj", "birthday", "1999-05-20") # this should update the ind. called pj!
    #lookup Individual => @individual
    #give it's class a relation if it doesn't have one...
    #call the relation (setter method) and assign value

    puts "\nAdding #{@value} to the #{@relation} relation for #{@individual}\n"
    #FIXME: is there a way to instantiate @individual
    #using and defining (ehr... including) all the methods (ehr.. relations)
    #so that we can simply assign a value to the specified relation ?!
    #can't just add the relation here, cuz we don't know
    #the datatype(s): domain & range
    #
    #plan: get a regular individual:
    #ind = ::Individual.ind(@individual, category)
    #
    #have the class (i.e. subclass/category) lookup
    #(I guess we make a getter/setter by default)
    #the relation & define it:
    #
    #assign value to indiv.relation
    #

#    created = instance(options)
#    if created.is_a?(clazz(options))
#      error = "Failed to create value"
#    end

    error = "Create undefined for Value"
    individual_categories = ::Individual.categories_for(@individual)
    selected_category = individual_categories.select { |cat|
      created_cat = cat.create
      created_cat.respond_to?(@relation)
    }
    if selected_category
      puts "doing it..."
      selected_category.send(@relation, @value)
      error = nil
    else
      error = "Value - Create: unable to identify the _one_ category"
    end

    [created, error]
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
