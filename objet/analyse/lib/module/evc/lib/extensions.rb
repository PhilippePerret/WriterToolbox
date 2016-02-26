# encoding: UTF-8
=begin

Extension de classes, dans le cas où le module serait
utilisé tout seul.

=end

class ::String
  def nil_if_empty ; str = self.strip ; str == "" ? nil : str end
  def to_i_inn     ; self.to_i end
end #/String
class ::NilClass
  def to_i_inn ; nil end
end
class Fixnum
  def to_i_inn ; self.to_i end
end
