# encoding: UTF-8

class User

  BIT_SIMP_ANALYSTE = 1   # À proposer sa participation accepté
                          #  Pas encore de points d'abonnements
  BIT_REAL_ANALYSTE = 2   # À fourni un travail suffisant pour avoir
                          # des points d'abonnements.
  BIT_ANALYSTE_REDA = 4   # Analyste rédacteur, qui peut rédiger des
                          # comptes-rendus d'analyste
  BIT_ANALYSTE_CONF = 8   # Analyste qui peut se débrouiller seul, sans
                          # que ses documents soient modérés ou aient
                          # Ses documents n'ont plus besoin d'être validés
                          # pour être publiés.
                          # besoin d'être validés.
  BIT_ANALYSTE_CHEF = 16

  def set_simple_analyste
    unless user.admin? || user.analyste_chef?
      raise "Vous ne pouvez pas exécuter cette opération sans être administrateur ou chef-analyste…"
    end
    cur_option = get_option(:analyse)
    set_option(:analyse, cur_option|BIT_SIMP_ANALYSTE )
  end
  def set_real_analyste
    unless user.admin? || user.analyste_chef?
      raise "Vous ne pouvez pas exécuter cette opération sans être administrateur ou chef-analyste…"
    end
    cur_option = get_option(:analyse)
    set_option(:analyse, cur_option|BIT_REAL_ANALYSTE )
  end
  def set_analyste_redactor
    unless user.admin? || user.analyste_chef?
      raise "Vous ne pouvez pas exécuter cette opération sans être administrateur ou chef-analyste…"
    end
    cur_option = get_option(:analyse)
    set_option(:analyse, cur_option|BIT_ANALYSTE_REDA )
  end
  def set_analyste_confirmed
    unless user.admin? || user.analyste_chef?
      raise "Vous ne pouvez pas exécuter cette opération sans être administrateur ou chef-analyste…"
    end
    cur_option = get_option(:analyse)
    set_option(:analyse, cur_option|BIT_ANALYSTE_CONF )
  end
  def set_analyste_chef
    unless user.admin? # seulement un admin peut faire ça, ici
      raise "Vous ne pouvez pas exécuter cette opération sans être administrateur…"
    end
    cur_option = get_option(:analyse)
    set_option(:analyse, cur_option|BIT_ANALYSTE_CHEF )
  end



  # Retourne true si l'user est un simple analyste, c'est-à-dire
  # qu'il a proposé sa participation mais qu'il n'a pas encore
  # produit assez de travail pour pouvoir vraiment le considérer
  # comme un analyste confirmé.
  # Un simple analyste ne peut pas tout consulter.
  def simple_analyste?
    get_option(:analyse) & BIT_SIMP_ANALYSTE > 0
  end
  # Travail suffisant pour être consiéré comme introduit dans
  # le cercle des analystes. Il a produit assez d'analyses pour
  # pouvoir consulter la rubrique n'importe quand.
  def real_analyste?
    get_option(:analyse) & BIT_REAL_ANALYSTE > 0
  end
  def analyste_redacteur?
    get_option(:analyse) & BIT_ANALYSTE_REDA > 0
  end
  alias :analyste_redactor? :analyste_redacteur?
  # Retourne true si l'utilisateur est un analyste confirmé.
  # On n'a plus besoin de valider son travail avant de le
  # publier
  def analyste_confirmed?
    get_option(:analyse) & BIT_ANALYSTE_CONF > 0
  end
  def chef_analyste?
    get_option(:analyse) & BIT_ANALYSTE_CHEF > 0
  end
end
