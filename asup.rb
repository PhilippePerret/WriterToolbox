class Person
  attr_reader :name
  def initialize prenom
    @name = prenom
  end
  # def to_s
  #   self.name
  # end
  def to_str
    self.name
  end
end

pat   = Person.new('Pat')
phil  = Person.new('Phil')

if (pat > phil)
  puts "Pat est après"
else
  puts "Pat est avant"
end
