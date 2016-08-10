# encoding: UTF-8

=begin
Crée un nouveau sujet et le met en édition
=end

# L'user doit avoir le grade suffisant
raise_unless user.grade > 4

sujet = Forum::Sujet.new
sujet.name = param(:new_topic_name)
sujet.create
redirect_to "sujet/#{sujet.id}/edit?in=forum"
