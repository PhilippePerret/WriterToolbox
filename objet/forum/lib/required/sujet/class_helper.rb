# encoding: UTF-8
class Forum
class Sujet
  class << self

    # {StringHTML} Un formulaire pour ajouter un sujet
    def new_sujet_form
      <<-HTML
  <form action="forum/new_topic" method="POST" class='small'>
    <div class="row">
      <span class="value"><input type="text" name="new_topic_name" placeholder="Sujet" value="" class="w300" /></span>
      <input type="submit" value="Initier ce nouveau sujet" class='btn' />
    </div>
  </form>

      HTML
    end
  end # <<self
end #/Sujet
end #/Forum
