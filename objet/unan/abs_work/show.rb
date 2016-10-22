# encoding: UTF-8
raise_unless user.unanunscript? || user.admin?

Unan.require_module 'abs_work'
