# encoding: UTF-8
=begin

  Méthodes support pour les formulaires courants, à commencer
  celui qui permet de s'inscrire

=end

# Remplissage du formulaire d'inscription avec les données +duser+
# qui peuvent être valident ou invalides.
def fill_signup_form_with duser, options = nil
  options ||= Hash.new
  options[:abonnement]  ||= false
  options[:submit]      ||= false

  within("form##{FORM_SIGNUP_ID}") do
    fill_in('user[pseudo]',                 with: duser[:pseudo])
    fill_in('user[patronyme]',              with: duser[:pseudo])
    fill_in('user[mail]',                   with: duser[:mail])
    fill_in('user[mail_confirmation]',      with: duser[:mail])
    fill_in('user[password]',               with: duser[:password])
    fill_in('user[password_confirmation]',  with: duser[:password])
    select(duser[:hsexe],                    from: 'user[sexe]')
    if options[:abonnement]
      check('user[subscribe]')
    else
      uncheck('user[subscribe]')
    end
    fill_in('user[captcha]',                with: '366')

    click_button FORM_SIGNUP_SUBMIT_BUTTON
  end

end
