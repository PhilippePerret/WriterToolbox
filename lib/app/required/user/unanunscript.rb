# encoding: UTF-8
=begin

  Extension de la classe User pour le programme
  ÉCRIRE UN FILM/ROMAN EN UN AN

=end
class User

  def program
    @program ||= begin
      site.require_objet 'unan'
      begin
        raise "ID NE DEVRAIT PAS ÊTRE NIL DANS User#program" if self.id.nil?
      rescue Exception => e
        debug e.message
        debug e.backtrace.join("\n")
      end
      Unan::Program.get_current_program_of(self.id)
    end
  end
  # /program

  # Retourne le bon menu en fonction du fait que l'user
  # développe un roman ou développe un film (pour un affichage
  # tout à fait adapté)
  def menu_unan_name
    @menu_name ||= begin
      chose =
        case unan_projet_type
        when 2 then 'ROMAN' # '1 An 1 Roman'
        when 3 then 'BD'    # '1 An 1 BD'
        when 4 then 'JEU'   #'1 An 1 Jeu'
        else        'FILM'  # '1 An 1 Film'
        end
      as_main_link("1 AN 1 #{chose}", 'font-size:14pt')
    end
  end
  #/menu_unan_name

  # Return le bit 1 des specs du projet de l'user
  def unan_projet_type
    @projet_type ||= begin
      drequest = {
        where: {auteur_id: self.id},
        order: 'created_at DESC',
        limit: 1,
        colonnes: [:specs]
      }
      site.dbm_table(:unan, 'projets').get(drequest)[:specs][0].to_i
    end
  end
  # /projet_type

end
