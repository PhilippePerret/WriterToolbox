# Ruby

* [Changer de version de Ruby](#pourchangerdeversionderuby)
<a name='pourchangerdeversionderuby'></a>

## Changer de version de Ruby

    > ssh serveur_boa
    ssh> rbenv install <version de ruby>
    ssh> rbenv rehash
    ssh> rbenv global <version de ruby>

* [Installation de rbenv](#installationrbenv)
<a name='installationrbenv'></a>

## Installation de rbenv

Nécessaire pour utiliser `rbenv install`

    ssh> git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    ssh> echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    ssh> echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    ssh> git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
