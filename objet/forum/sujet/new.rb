# encoding: UTF-8

=begin
Crée un nouveau sujet et le met en édition
=end
sujet = Forum::Sujet::new
sujet.name = param(:new_topic_name)
sujet.create
redirect_to "sujet/#{sujet.id}/edit?in=forum"
