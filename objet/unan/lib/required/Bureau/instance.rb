# encoding: UTF-8
class Unan
class Bureau
  include Singleton
  def bind; binding() end
end #/Bureau
end #/Unan

def bureau
  @bureau ||= Unan::Bureau::instance
end
