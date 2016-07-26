=begin

  Module pour tester la méthode autologin qui doit permettre de s'autologuer.
  Pour la tester en réel, on crée un ticket qui contient un code permettant
  de l'appeler.
  Ce code génère aussi un message flash qu'on doit trouver sur la page,
  l'administrateur doit être loggué et on peut rejoindre le tableau de
  bord administration.
  
=end

feature "Méthode User#autologin" do
  before(:all) do
    # On crée un ticket
    now = Time.now
    message = "Autologin du #{now} de \#{user.pseudo}"
    @message_formated = "Autologin du #{now} de Phil"
    code_ticket = "User.new(1).autologin(route:'admin/dashboard');flash(\"#{message}\")"
    ticket = app.create_ticket(nil, code_ticket)
    @route = "site/home?tckid=#{ticket.id}"
  end
  scenario "La méthode autologin permet de s'identifier" do
    visite_route 'site/home'
    expect(page).not_to have_link 'Déconnexion'
    visite_route @route
    shot 'route-after-ticket'
    expect(page).to have_notice(@message_formated)
    # S'il l'user est identifié, on doit trouver le lien de déconnexion
    expect(page).to have_link 'Déconnexion'
    # Mais surtout, on doit avoir rejoint le dashbord d'administration
    expect(page).to have_tag('h1', text: /Tableau de bord/)
  end
end
