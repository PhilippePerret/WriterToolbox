# encoding: UTF-8
class Page

  # Utiliser `page.no_left_margin` pour ne pas afficher la
  # marge gauche
  def left_margin?
    !(@no_left_margin == true)
  end

  # Plus tard, il faudra que chaque administrateur puisse décider s'il veut
  # voir ou non ce widget
  def widget_taches?
    (user.id == 1) && !(@no_widget_taches == true || site.display_widget_taches == false)
  end

  def no_left_margin
    @no_left_margin = true
  end

  def no_widget_taches
    @no_widget_taches = true
  end

end #/Page
