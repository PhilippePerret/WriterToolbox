# encoding: UTF-8
raise_unless( user.admin? || user.unanunscript? )

class Unan
class Program

  DATA_RAISONS = [
    "non définie",
    "Malheureusement, je n'ai plus le temps",
    "Je n'arrive pas à suivre",
    "Je n'arrive pas à me motiver pour poursuivre",
    "Ce programme est trop difficile",
    "Ce programme est trop facile pour moi",
    "Ce programme n'est pas adapté à mon niveau",
    "Ce programme, c'est n'importe quoi !",
    "Autre raison"
  ]

  class << self

    def datakill
      @datakill ||= param(:killing)
    end
    def destroy_program_user_courant

      # Avertir l'administration (en précisant si l'auteur
      # demande le remboursement de son programme)
      rembourser      = datakill[:remboursement] == 'on'
      iraison          = datakill[:raison].to_i
      @datakill.merge!(
        program_id:       user.program.id,
        current_pday:     user.program.current_pday,
        rembourser:       rembourser,
        iraison:          iraison,
        raison:           DATA_RAISONS[iraison],
        raison_detailed:  datakill[:raison_detailed].nil_if_empty,
        suggestions:      datakill[:suggestions].nil_if_empty
      )

      # Détruire le programme
      # (en fait, on ne fait que mettre son statut à "détruit")
      user.program.abandonne

      data_mail = {
        from:           user.mail,
        subject:        "ABANDON D'UN PROGRAMME UAUS",
        message:        message_admin_abandon,
        formated:       true,
        force_offline:  true
      }
      site.send_mail(data_mail)

      flash "Votre programme a été détruit, #{user.pseudo}… Au regret de vous voir abandonner."
      redirect_to :home
    end

    def message_admin_abandon
      <<-HTML
<p>Phil</p>
<p>Je t'informe d'un ABANDON de programme #{Unan::PROGNAME_DIM_MAJ}.</p>
<pre style="font-size:11pt">
    User             : #{user.pseudo} (##{user.id})
    Date             : #{Today.as_jj_mm_yy}
    Program ID       : ##{datakill[:program_id]}
    Jour-programme   : #{datakill[:current_pday]}
    Remboursement    : #{datakill[:rembourser] ? 'OUI' : 'non'}
    Raison (menu)    : (#{datakill[:iraison]}) #{datakill[:raison]}
    Raison détaillée : #{datakill[:raison_detailed] || "aucune"}
    Suggestions      : #{datakill[:suggestions] || "aucune"}
</pre>
      HTML
    end

    # ---------------------------------------------------------------------
    #   Méthodes d'helper
    # ---------------------------------------------------------------------
    def menu_raison_abandon
      DATA_RAISONS.each_with_index.collect do |title, index|
        title.in_option(value:index)
      end.join('').in_select(name:'killing[raison]', id:'killing_raison')
    end
  end #/<< self
end #/Program
end #/Unan

dk = Unan::Program::datakill
if dk != nil &&  dk[:operation] == 'kill' && dk[:confirmation_kill] == "1"
  Unan::Program::destroy_program_user_courant
end
