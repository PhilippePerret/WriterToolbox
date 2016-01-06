# encoding: UTF-8
=begin

Class User
----------
Instance

=end
class User

  # Identifiant de l'user dans la table
  attr_reader :id

  # Instanciation, à l'aide de l'ID optionnel
  def initialize uid = nil
    @id = uid
  end

  # Obtenir la valeur d'une propriété de l'user
  def get key
    return nil if @id.nil?
    table_users.get(id, colonnes:[key])[key]
  end
  def set hdata
    table_users.set(id, hdata)
    hdata.each { |k, v| instance_variable_set("@#{k}", v) }
  end

  # Définir la valeur d'une option
  # +index+ Offset de l'option (0-start, de 0 à 31)
  # +value+ Valeur à lui donner, de 0 à 9
  def set_option index, value
    opts = options.dup
    opts[index] = value.to_s
    set( options: opts )
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
