# encoding: UTF-8

# On ajoute aussi les tests mini du login
require _('../mini/login_spec.rb', __FILE__)

test_form "user/login", dform, "Un user ne peut pas s'identifier avec un mauvais login" do |f|

  f.fill_and_submit( login_mail: "" )
  f.has_error "Il faut fournir votre mail."

  f.fill_and_submit(login_password: "")
  f.has_error "Il faut fournir votre mot de passe."

  f.fill_and_submit(login_mail: "bad@mail.fr", login_password: "mauvaismotdepasse")
  f.has_error "Je ne vous reconnais pas. Merci d'essayer encore."
end
