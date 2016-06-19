# encoding: UTF-8

=begin
Crée une nouvelle question
=end

# L'user doit être au moins identifié pour pouvoir
# poser une question technique.
raise_unless_identified
class Forum
  def self.save_question
    hquestion = param(:question)
    question  = hquestion[:question].strip
    categorie = hquestion[:categorie].to_i # Un nombre, ID de la catégorie
    raise "Il faut fournir la question." if question.empty?
    question_existe_deja = Forum::table_sujets.count( where: { titre: question } ) > 0
    raise "Cette question a déjà été posée." if question_existe_deja

    sujet = Sujet::new
    sujet.titre           = question
    sujet.type_s          = 2
    sujet.bit_validation  = ( user.grade > 3 ? 1 : 0 )
    sujet.categorie       = categorie
    sujet.create

    # Si l'utilisateur veut suivre le sujet, on l'ajoute à la
    # liste des followers et on ajoute ce sujet à sa liste
    # de sujets suivis.
    if hquestion[:suivre] == 'on'
      sujet.add_follower( user )
      mess_suivi = " (vous suivez cette question et serez donc averti#{user.f_e} en cas de réponse)"
    else
      mess_suivi = ""
    end
    # redirect_to "sujet/#{sujet.id}/edit?in=forum"
    flash "Votre question a bien été enregistrée#{mess_suivi}."
    redirect_to param(:question_last_route)
  rescue Exception => e
    error e.message
    debug e
  end
end #/Forum

case param(:operation)
when 'save_question'
  Forum::save_question
end
