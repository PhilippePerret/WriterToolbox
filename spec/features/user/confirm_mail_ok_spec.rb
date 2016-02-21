feature 'Confirmation du mail et donc de l’inscription à l’aide du ticket' do
  scenario "Une visiteuse confirme son inscription et mail par le mail" do
    # Dégel du gel après l'inscription de l'user
    degel 'testint-apres-signup-valide'

    # Le principe est le suivant : on doit pouvoir tout de suite exécuter
    # l'opération avec l'adresse contenu dans le mail. On reconstitue
    # cette adresse en récupérant le dernier ticket créé, qui est forcément
    # le ticket pour cette inscription.
    site.require_module 'ticket'
    ticket = app.table_tickets.select(where:"code LIKE 'User::get%confirm_mail'",order:"created_at DESC").values.first
    puts ticket.inspect
    ticket_id = ticket[:id]

    visit "#{home}?tckid=#{ticket_id}"

    sleep 2

    # ON fait un gel final
    # gel 'testint-after-confirmation-mail'
  end
end
