# encoding: UTF-8
class User
  def do_after_login
    # Suivant les préférences du site, on prévient l'administration
    # d'une connexion au site.
    case site.alert_apres_login
    when :never, :jamais
    when :now, :tout_de_suite
      send_admin_new_connexion
    when :one_a_day, :une_par_jour
    when :one_a_week, :une_par_semaine
    when :one_a_month, :une_par_mois
    end
  end

  # À faire après un chargement de page
  #
  def do_after_load

    # On ajoute toujours une connexion
    site.add_connexion( ip )

    # On passe les adresses des moteurs de recherche
    return if moteur_recherche?

    # Si cet utilisateur a déjà été signalé, on ne fait rien
    # Noter qu'il faut mettre ça ici et pas avec le
    # `site.add_connexion` car la méthode add_connexion doit
    # fonctionner en toute circonstance
    return if param(:user_already_signaled) == "1"

    require './data/secret/known_ips.rb'

    if BLACK_IPS_LIST.has_key?(self.ip)
      exit( "Vous n'êtes pas le bienvenu, désolé.<br>You're not welcome, sorry." )
    end

    app.session['user_already_signaled'] = "1"
  end

  # Méthode utilisée pour envoyer une alerte à l'administrateur
  # suite à une nouvelle connexion.
  def send_admin_new_connexion
    User::get(1).send_mail(
      subject:  "Nouvelle connexion",
      formated: true,
      message: <<-MAIL
<p>Phil, je t'informe d'une nouvelle identification :</p>
<pre style="font-size:11pt">
  Pseudo  : #{pseudo} (##{id})
  Date    : #{NOW.as_human_date(true, true, ' ')}
  IP      : #{ip}
  Session : #{app.session.session_id}
</pre>
      MAIL
    )
  end

end
