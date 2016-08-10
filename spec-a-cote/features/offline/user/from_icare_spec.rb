# encoding: UTF-8
#
# Test d'un icarien actif qui arrive sur le BOA pour lire une page de
# la collection narration.
# On doit créer son enregistrement sur la boite, avec les bonnes
# options
feature "Un icarien actif non inscrit crée automatiquement son enregistrement" do
  scenario 'la page narration ne peut pas être atteinte dans son intégralité' do
    visit 'http://localhost/WriterToolbox/page/4/show?in=cnarration'
    # La page ne doit pas être affichée entière
    expect(page).to have_content 'une partie seulement de la page est affichée'
    # Elle ne doit pas avoir l'encart pour l'icarien
    expect(page).not_to have_css('div#cadre_icarien')

  end
  scenario 'l’icarien est reconnu et enregistré' do

    require 'digest/md5'

    # Avant tout on doit détruire l'user s'il existe déjà
    duser = {
      id:         100, # sur icare, pas sur BOA
      mail:       'mailicarien@icare.net',
      pseudo:     'IcarienActif',
      password:   'icarienactif',
      sexe:       'F',
      cpassword:  nil
    }
    duser[:cpassword] = Digest::MD5.hexdigest("#{duser[:password]}#{duser[:mail]}")

    init_count = User.table_users.count

    unless User.table_users.get(where: {mail: duser[:mail]}).nil?
      User.table_users.delete(where: {mail: duser[:mail]})
      expect(User.table_users.count).to eq(init_count - 1)
      init_count = init_count - 1
    end

    durl = {
      fromicare:  '1',
      idicare:    duser[:id],
      cpicare:    duser[:cpassword],
      picare:     duser[:pseudo],
      micare:     duser[:mail],
      xicare:     duser[:sexe],
    }

    url = 'http://localhost/WriterToolbox/page/4/show?in=cnarration'
    durl.each do |k, v| url += "&#{k}=#{v}" end

    # On rejoint le site/la page
    visit url

    # La page ne doit pas être affichée entière
    expect(page).to have_content 'une partie seulement de la page est affichée'

    # Mais un encart doit indiquer à l'user qu'il peut s'identifier
    expect(page).to have_css('div#cadre_icarien')

    # L'user doit être maintenant enregistrée
    du = User.table_users.get(where: {mail: duser[:mail]})
    expect(du).not_to eq(nil)
    expect(du).to be_instance_of Hash
    expect(du[:pseudo]).to eq(duser[:pseudo])
    opts = du[:options]
    expect(opts[2]).to eq('1')
    expect(opts[31]).to eq('1')

  end

end
