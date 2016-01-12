# encoding: UTF-8
=begin

Extension de la class Unan::Projet pour l'édition

=end
raise_unless_identified
site.require 'form_tools'
(site.folder_deeper_module + 'data_checker.rb').require

class Unan
class Projet

  include DataChecker

  class << self

    def edit
      if user.projet != nil
        flash "Je dois éditer le projet ##{user.projet.id}"
      else
        flash "Vous n'avez aucun projet à éditer."
      end
    end

    def save
      if data_valide?
        Unan::table_projets.update(projet_id, data2save)
        flash "#{new? ? ' Nouveau p' : 'P'}rojet ##{projet_id} sauvé."
      else
      end
    end

    # Permet aussi de créer le projet, à la création de
    # l'auteur d'un nouveau programme. Cela permet de ne
    # conserver qu'à un seul endroit les données, pour
    # modification ultérieure.
    # Retourne l'ID du nouveau projet
    def create_with data
      @param_data = data
      d2save = data2save
      d2save.delete(:id)
      d2save.merge!(created_at: NOW.to_i)
      projet_id = Unan::table_projets.insert(d2save)
    end

    # Les données exactes à sauver
    def data2save
      @data2save ||= begin
        {
          id:           param_data[:id].to_i_inn,
          auteur_id:    param_data[:auteur_id].to_i,
          program_id:   param_data[:program_id].to_i,
          titre:        param_data[:titre],
          resume:       param_data[:resume],
          specs:        rebuild_specs,
          updated_at:   NOW.to_i
        }
      end
    end

    def data_valide?
      retour = data2save.check_data(definition_data)
      if retour.ok
        @data2save = retour.objet
        true
      else
        error retour.errors
      end
    end

    # Définition des données, pour DataChecker
    def definition_data
      @definition_data ||= {
        id:           {type: :fixnum, defined:true },
        program_id:   {type: :fixnum, defined:true },
        auteur_id:    {type: :fixnum, defined:true },

        titre:        {type: :string, max: 256},
        resume:       {type: :string, max: 1000}
      }
    end

    # Reconstruction de la données `specs` d'après
    # les données du formulaire
    # Cf. dans la définition du schéma de la table la signification
    # de chaque bit.
    def rebuild_specs
      @specs ||= "#{param_data[:typeP]}0#{param_data[:sharing]}"
    end

    # ---------------------------------------------------------------------
    #   Data
    # ---------------------------------------------------------------------
    def projet_id
      param_data[:id].nil_if_empty.to_i_inn
    end

    def param_data
      @param_data ||= param(:projet) || Hash::new
    end

  end # << self

end #/Projet
end #/Unan

case param(:operation)
when 'save_data_projet'
  Unan::Projet::save
# Inutile de tester 'edit_data_projet' puisque la méthode
# Unan::Projet#edit est systématiquement appelée par la route
# du formulaire et la route unique qui sert à venir ici.
# when 'edit_data_projet'
#   Unan::Projet::edit
end
