# encoding: UTF-8
=begin

Class User
----------
Instance

=end
class User

  include MethodesObjetsBdD

  # Identifiant de l'user dans la table
  attr_reader :id

  # Instanciation, à l'aide de l'ID optionnel
  def initialize uid = nil
    @id = uid
    # Initialisation de propriétés volatiles utiles
    @preferences = Hash::new
  end

  def bind; binding() end

  def pseudo      ; @pseudo     ||= get(:pseudo)      end
  def mail        ; @mail       ||= get(:mail)        end
  def sexe        ; @sexe       ||= get(:sexe)        end
  def patronyme   ; @patronyme  ||= get(:patronyme)   end
  def options     ; @options    ||= get(:options)     end
  def session_id  ; @session_id ||= get(:session_id)  end
  def created_at  ; @created_at ||= get(:created_at)  end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

end