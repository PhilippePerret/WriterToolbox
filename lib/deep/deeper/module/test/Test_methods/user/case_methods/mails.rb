# encoding: UTF-8
class SiteHtml
class TestSuite
class TestUser < DSLTestMethod

  # Teste si l'user a reçu un mail
  def has_mail data_mail, inverse=false

    debug "-> has_mail(data_mail: #{data_mail.inspect})"

    options = {}
    options.merge!(
      strict:     !!data_mail.delete(:strict),
      count:      data_mail.delete(:count),
      evaluate:   !!data_mail.delete(:evaluate)
    )

    ok          = nil
    is_success  = nil
    # Liste des messages d'erreur, if any.
    # Ce sera une liste des messages d'erreur rencontrés ou
    # restera à nil
    message_errors = nil
    subject_errors = nil

    # Pour recueillir les mails valides (pour tester leur
    # nombre)
    mails_ok = []

    # Pour le message de retour, pour spécifier le mail
    # qu'on doit trouver ou ne pas trouver.
    dmail_human = []
    data_mail[:subject] && begin
      sbj = data_mail[:subject].in_array.collect{|e| "“#{e}”"}.pretty_join
      dmail_human << "SUJET avec #{sbj}"
    end
    data_mail[:message] && begin
      msg = data_mail[:message].in_array.collect{|e| "“#{e}”"}.pretty_join
      dmail_human << "MESSAGE avec #{msg}"
    end
    dmail_human = dmail_human.pretty_join

    no_mails      = mails.empty?
    nombre_mails  = mails.count


    if no_mails

      debug "  = no_mails"

      if inverse == false && options[:count] != 0
        # Produit forcément un échec
        mess_retour = "Aucun mail n'a été envoyé à #{pseudo}."
        is_success = false
      else
        # Produit forcément un succès
        mess_retour = "Aucun mail n'a été envoyé à #{pseudo} (OK)."
        is_success = true
      end

      debug "  = is_success = #{is_success.inspect}"

    else

      # ------------------
      # S'il y a des mails
      # ------------------

      debug "  = Il y a des mails (#{nombre_mails})"

      # Boucle sur chaque mail
      #
      # Si c'est un test droit (non inverse), on cherche un mail
      # qui contient tous les textes transmis. Si un mail ne
      # correspond pas, ça ne provoque pas forcément une erreur,
      # l'erreur ne tient qu'au fait que AUCUN mail ne correspond
      # à la recherche.
      # Si c'est un test inverse, on génère une erreur dès
      # qu'un mail correspond aux critères.
      mails.each do |dmail|

        tsujet    = TString.new(self, dmail[:subject])
        tmessage  = TString.new(self, dmail[:message])

        ok = true

        data_mail.each do |k, v|

          ok = ok &&
            case k
            when :sent_after, :send_after
              dmail[:created_at] > v
            when :sent_before, :send_before
              dmail[:created_at] < v
            when :message
              ok = tmessage.has?(v, options)
              message_errors = tmessage.errors
              ok
            when :subject, :sujet
              ok = tsujet.has?(v, options)
              subject_errors = tsujet.errors
              ok
            end

          # Si c'est un test "droit" (non inverse) et qu'une
          # condition est false, on peut s'arrêter tout de
          # suite pour passer au mail suivant
          break if inverse == false && ok == false

        end

        # On mémorise ce mail OK
        mails_ok << dmail if ok

        if inverse == true && ok == true
          # Si c'est une inversion, c'est-à-dire qu'il ne faut
          # pas trouver de mail et qu'un mail répond pourtant aux
          # conditions, il faut produire une failure
          is_success = false
          break
        end

      end #/fin de boucle sur tous les mails

    end # /fin du else de "si no_mails"

    # Si c'est un test droit, il faut qu'il y ait au moins
    # un mail trouvé.
    if inverse == false && mails_ok.count > 0
      # Ça peut être un succès, sauf si un nombre de mails
      # précis à été demandé
      if options[:count]

        # SUCCESS DROIT : LE NOMBRE DE MAIL TROUVÉS
        mails_ok.count == options[:count]

      else

        # SUCCESS DROIT : UN MAIL TROUVÉ
        mess_retour = "Un mail correspondant aux critères #{dmail_human} a été trouvé."
        is_success = true

      end
    end

    debug "  Fin de test des mails"

    if is_success === nil
      is_success = begin
        ok != nil || raise("ok ne devrait pas être nil si is_success n'est pas défini (#{__FILE__}:#{__LINE__})…")
        # Si is_success n'a toujours pas été défini
        ok == !inverse
      end
    end

    debug "  * Composition du message de retour"

    # Composition du message de retour
    mess_retour ||= begin
      opt_count   = options[:count]
      s_mail      = ( opt_count.nil? ? '' : (opt_count > 1 ? 's' : '') )
      if is_success
          # SUCCESS
          if inverse == false
            # SUCCESS DROIT
            if opt_count
              "#{opt_count} mail#{s_mail} correspondant à #{dmail_human} ont été envoyés."
            else
              "Un mail correspondant à #{dmail_human} a été envoyé."
            end
          else
            # SUCCESS INVERSE
            if opt_count
              "Il n'y pas eu #{opt_count} mail#{s_mail} correspondant à #{dmail_human} envoyés."
            else
              "Aucun mail correspondant à #{dmail_human} n'a été envoyé (OK)."
            end
          end
        else
          # FAILURE
          errs = []
          message_errors.nil? || (
            errs << 'le message ' + message_errors.pretty_join
            )
          subject_errors.nil? || (
            errs << 'le sujet ' + subject_errors.pretty_join
          )
          errs = errs.join(', ')
          if inverse == false
            # FAILURE DROITE
            if opt_count
              "On devait trouver #{opt_count} mail#{s_mail} correspondant à #{dmail_human}. Nombre trouvés : #{mails_ok.count} (#{errs})."
            else
              "Aucun mail (sur #{nombre_mails}) ne correspond à la recherche : #{errs}."
            end
          else
            # FAILURE INVERSE
            if opt_count
              "On ne devrait pas trouver #{opt_count} mail#{s_mail} correspondant à #{dmail_humain} (#{errs})."
            else
              "Aucun mail ne devrait correspondre à #{dmail_human} (#{errs})."
            end
          end
        end
    end

    debug " = mess_retour: #{mess_retour.inspect}"

    options[:evaluate] && ( return is_success )

    # Production du cas
    SiteHtml::TestSuite::Case::new(
      self,
      result:   is_success,
      message:  mess_retour
    ).evaluate

  end


  def has_not_mail(data_mail); has_mail(data_mail true) end
  def has_mail?(data_mail); has_mail(data_mail.merge(evaluate: true)) end
  def has_not_mail?(data_mail); has_mail(data_mail.merge(evaluate: true), true) end

  # Tous les mails de l'auteur.
  # C'est un Array de Hash contenant les données des mails tels
  # qu'enregistrés dans le dossier `tmp/mails`
  def mails
    @mails ||= begin
      Dir["./tmp/mails/**/*.msh"].collect do |pmail|
        dmail = Marshal.load(SuperFile::new(pmail).read)
        dmail[:to] == data[:mail] ? dmail : nil
      end.compact
    end
  end

end #/TestUser
end #/TestSuite
end #/SiteHtml
