# encoding: UTF-8

# Seulement pour un administrateur
raise_unless_admin

class Quiz
  class << self

    # Méthode qui crée la nouvelle base de données de quiz
    def create_new_database
      @db_name = param(:new_base_test_name).nil_if_empty
      check_value_new_database || return
      # === CRÉATION DE LA BASE ===
      q = new(nil, @db_name)
      q.database_create
      flash "Création de la nouvelle base de données de quiz : #{@db_name}"
    end

    def check_value_new_database
      @db_name != nil || raise('Il faut donner le nom de la nouvelle base de données.')
      reste = @db_name.gsub(/[a-z_]/,'')
      reste == '' || raise('Le nom ne doit contenir que des minuscules et le trait plat.')
      nexiste_page = (false == all_suffixes_quiz.include?( @db_name ))
      nexiste_page || raise('Cette base de données existe déjà.')
      true
    rescue Exception => e
      error( "Impossible de créer la base de données de quiz “#{@db_name}” : #{e.message}" )
    end
  end #/<<self
end #/Quiz

case param(:operation)
when 'creer_new_base_test'
  Quiz.create_new_database
end
