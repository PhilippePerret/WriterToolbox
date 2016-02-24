# encoding: UTF-8
raise_unless_admin
class Forum
class Sujet
  DATA_REFUS = {
    deontologie: {
      raison: "Ne correspond pas à la déontologie du site."
    },
    doublure: {
      raison: "Cette question ou ce sujet est déjà traité."
    },
    hors_sujet:{
      raison: "Cette question ou ce sujet n'ont rien à voir avec l'objet de ce site."
    }
  }
  # Attention : Il ne faut pas mettre `refuser` car la méthode serait
  # appelée par le programme, par défaut.
  def do_refuser

    # On prend les raisons invoquées
    data_refus = param(:refus)
    raisons = Array::new
    DATA_REFUS.each do |kid, kdata|
      if data_refus[kid] == 'on'
        raisons << kdata[:raison]
      end
    end

    data_mail = {
      subject:    "Votre sujet/question a malheureusement été refusé/e",
      message:    message_refus(raisons),
      formated:   true
    }
    debug "data-mail : #{data_mail.pretty_inspect}"
    creator.send_mail( data_mail )
    delete
    flash "Sujet refusé."
    redirect_to 'forum/dashboard'
  end
  def message_refus(raisons)
    raisons_str = raisons.collect{|p| p.in_li}.join.in_ul
    @message_refus ||= <<-HTML
<p>#{creator.pseudo},</p>
<p>J'ai le regret de vous annoncer que votre question/sujet ci-dessous a été refusé.</p>
<p>Question/sujet : #{name}</p>
<p>Les raisons en sont les suivantes :</p>
#{raisons_str}
    HTML
  end
end #/Sujet
end #/Forum

case param(:operation)
when 'refuser_sujet'
  site.objet.do_refuser
end
