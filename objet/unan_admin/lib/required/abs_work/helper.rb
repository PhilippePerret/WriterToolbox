class Unan
class Program
class AbsWork

  # {StringHTML} Retourne un lien permettant de lire le
  # travail.
  def lien_show titre_lien = nil, attrs = nil
    titre_lien ||= self.titre
    attrs ||= Hash::new
    ktype, context = ktype_and_context
    attrs.merge!(href: "#{ktype}/#{id}/show?in=#{context}")
    titre_lien.in_a(attrs)
  end

  def ktype_and_context
    return ['work', 'unan'] if data_type_w.nil? # c'est une erreur, mais bon
    case data_type_w[:id_list]
    when :pages then ['page_cours', 'unan']
    when :quiz  then ['quiz', 'unan']
    when :forum then ['post', 'forum']
    else # :tasks
      ['work', 'unan']
    end
  end
end #/AbsWork
end #/Program
end #/Unan
