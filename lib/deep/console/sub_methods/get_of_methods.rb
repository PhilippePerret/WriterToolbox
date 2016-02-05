# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  def get_of_exec wanted, foo, foo_id
    site.require_objet 'unan'
    site.require_objet 'unan_admin'
    foo_id = foo_id.to_i
    # debug "wanted:#{wanted.inspect} / foo:#{foo.inspect} / foo_id:#{foo_id.inspect}"

    ichose = case foo
    when "work", "works"
      foo = "work"
      Unan::require_module "abs_work" # et notamment 'getof_methods.rb'
      Unan::Program::AbsWork::get(foo_id)
    when "page_cours", "pages_cours"
      foo = "page_cours"
      Unan::require_module "page_cours"
      Unan::Program::PageCours::get(foo_id)
    when "pday", "pdays"
      foo = "pday"
      Unan::require_module "abs_pday"
      Unan::Program::AbsPDay::get(foo_id)
    when "exemple", "exemples"
      foo = "exemple"
      Unan::require_module "exemple"
      Unan::Program::Exemple::get(foo_id)
    when "quiz"
      Unan::require_module "quiz"
      Unan::Quiz::get(foo_id)
    else raise "La chose `#{foo}` est inconnu…"
    end

    wanted = case wanted
    when 'exemples'     then 'exemple'
    when 'quizes'       then 'quiz'
    when 'pages_cours'  then 'page_cours'
    when 'works'        then 'work'
    when 'pdays'        then 'pday'
    else wanted
    end

    # Il faut requérir le module qui traite les méthodes
    # get-of en fonction de l'objet sujet
    (site.folder_lib_optional + "console/modules_getof/#{foo}.rb").require

    # Il suffit ensuite d'appeler la méthode utilitaire
    # getof_<wanted> de l'instance
    getof_method = "getof_#{wanted}".to_sym
    if ichose.respond_to?(getof_method)
      ichose.send(getof_method)
    else
      raise "La méthode #{getof_method.inspect} est inconnue de #{foo}"
    end
  rescue Exception => e
    debug e
    error e.message
    "FAILURE"
  else
    "OK"
  end

end #/Console
end #/Admin
end #/SiteHtml
