# encoding: UTF-8
class Forum
class Sujet
  class << self

    # {StringHTML} Un formulaire pour ajouter un sujet
    def form_new
      <<-HTML
<form action="sujet/new?in=forum" method="POST" class='dim3070'>
  <div class="row">
    <span class="libelle">
      <input type="submit" value="Initier ce nouveau sujet" class='btn small' />
    </span>
    <span class="value">
      <input type="text" name="new_topic_name" placeholder="Sujet" value="" />
    </span>
  </div>
</form>

      HTML
    end
  end # <<self
end #/Sujet
end #/Forum
