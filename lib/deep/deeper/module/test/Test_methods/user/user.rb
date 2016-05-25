# encoding: UTF-8
class SiteHtml
class TestSuite
class TestUser < DSLTestMethod

  # {Any} La référence de l'auteur transmise à la
  # méthode. Ça peut être l'identifiant (valeur préférée) ou
  # un hash définissant une donnée de l'auteur qui permettra
  # de le retrouver, par exemple {pseudo: "Sonpseudo"} ou
  # {mail: "son@mail.fr"}.
  attr_reader :ref_user

  # {Fixnum} ID de l'user dans la table
  attr_reader :user_id

  # {Hash} Données de l'auteur
  # Noter qu'elles peuvent être {} si l'auteur n'existe pas
  # dans la base de données. Il faut tester alors la
  # méthode `exist?`
  attr_reader :data

  def initialize tfile, ref_user, options=nil, &block
    @ref_user = ref_user
    analyze_ref_user
    super(tfile, &block)
  end

  # Fonctionne comme `method_missing` mais method_missing
  # est déjà défini pour la class `Object` dont héritent toutes
  # les classes. Pour faire une propre captation, il faut
  # donc définir self_method_missing qui sera appelé par
  # method_missing
  def self_method_missing method_name, *args, &block
    if self.user.respond_to?(method_name)
      if block_given?
        self.user.send(method_name, &block)
      elsif args
        self.user.send(method_name, *args)
      else
        self.user.send(method_name)
      end
    else
      raise "La méthode #{method_name.inspect} est inconnue de l'user courant."
    end
  end

  def description_defaut
    @description_defaut ||= "TEST USER ##{data[:id]} #{pseudo}"
  end

  # Retourne true si l'user existe
  def exists?
    data != {}
  end
  alias :exist? :exists?

  # Méthode qui analyse la référence à l'auteur transmise pour
  # le retrouver dans la base de données
  def analyze_ref_user
    @data = case ref_user
    when Fixnum
      @user_id = ref_user
      User::table_users.get(@user_id)
    else
      User::table_users.select(where: ref_user).values.first || {}
    end
  end

  # Instance de l'user courant
  def user
    @user ||= User.get(data[:id])
  end

  # Pseudo de l'user
  def pseudo
    @pseudo ||= data[:pseudo]
  end

end #/TestUser
end #/TestSuite
end #/SiteHtml
