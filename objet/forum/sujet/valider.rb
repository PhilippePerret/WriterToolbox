# encoding: UTF-8
raise_unless_admin
class Forum
class Sujet

  def validate
    opts = "#{options}"
    opts[0] = "1"
    debug "options : #{opts}"
    set(options: opts)
    data_mail = {
      subject:  "Validation de votre sujet/question",
      message:  message_validation,
      formated: true
      }
    # debug "data mail : #{data_mail.pretty_inspect}"
    creator.send_mail(data_mail)
    flash "Sujet ##{id} validé."
  end

  def message_validation
    <<-HTML
<p>Bonjour #{creator.pseudo},</p>
<p>J'ai le plaisir de vous annoncer que votre question/sujet ci-dessous a été validé/e par l'administration du forum.</p>
<p>Question/sujet : #{name}</p>
<p>Vous pourrez la/le retrouver sur le #{lien.forum('forum', distant:true)} du site.</p>
    HTML
  end

end #/Sujet
end #/Forum

# ---------------------------------------------------------------------
#

sujet = site.objet
sujet.validate
# Prévenir l'auteur
redirect_to :last_route

#
# ---------------------------------------------------------------------
