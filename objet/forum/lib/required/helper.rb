# encoding: UTF-8
=begin
Méthodes d'helper pour le forum
=end
class Forum

  # {StringHTML} Un formulaire pour ajouter un sujet
  def formulaire_new_topic
    <<-HTML
<form action="forum/new_topic" method="POST" class='small'>
  <div class="form_row">
    <span class="value"><input type="text" name="new_topic_name" placeholder="Sujet" value="" class="w300" /></span>
    <input type="submit" value="Initier ce nouveau sujet" class='btn' />
  </div>
</form>

    HTML
  end

end
