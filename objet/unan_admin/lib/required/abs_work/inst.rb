# encoding: UTF-8
site.require_objet 'unan'

class UnanAdmin
class AbsWork

  include MethodesObjetsBdD

  # ---------------------------------------------------------------------
  #   Instance
  #
  #   ATTENTION
  #   Il s'agit des instances dans UnanAdmin (UnanAdmin::AbsWork) et
  #   non pas des instance dans Unan (Unan::Program::Abswork)
  #   On implémente cette classe pour pouvoir utiliser l'édition, même
  #   si ça me semble un peu compliqué de faire comme ça, mais bon…
  # ---------------------------------------------------------------------
  attr_reader :id
  attr_reader :real_abswork
  attr_reader :titre

  def initialize wid
    wid = wid.to_i
    @id = wid
    @real_abswork = Unan::Program::AbsWork::new(wid)
  end

  def method_missing method, *args, &block
    yield real_abswork.send(method, args)
  end

  def table
    @table ||= Unan::table_absolute_works
  end

end #/AbsWork
end #/UnanAdmin
