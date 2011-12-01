# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Configuration.create(
  {:name => "git_document_db_url", :value => "http://username:password@localhost:4567/documents"},
  {:name => "api_secret", :value => "AppSecret"}
)

category_1 = Category.create! :name => "Mobilidade urbana", :badge => File.open("#{Rails.root.to_s}/lib/fixtures/mobilidade.png")
category_2 = Category.create! :name => "Violência", :badge => File.open("#{Rails.root.to_s}/lib/fixtures/violencia.png")
category_3 = Category.create! :name => "Catástrofes naturais", :badge => File.open("#{Rails.root.to_s}/lib/fixtures/catastrofes.png")

user = User.create! :provider => 'fake', :uid => 'foo_bar', :name => "Foo Bar"
user_2 = User.create! :provider => 'fake', :uid => 'bar_foo', :name => "Bar Foo"

idea_1 = Idea.create! :user => user, :category => category_1, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :featured => true, :recommended => true, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }
idea_2 = Idea.create! :user => user_2, :category => category_2, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :featured => true, :recommended => true, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }
idea_3 = Idea.create! :user => user, :category => category_3, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :featured => true, :recommended => true, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }
idea_4 = Idea.create! :user => user, :category => category_2, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :featured => true, :recommended => true, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

# Forks
Idea.create! :parent => idea_1, :user => user_2, :category => category_1, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 10, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_2, :user => user, :category => category_2, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 9, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_3, :user => user_2, :category => category_3, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 8, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_4, :user => user_2, :category => category_2, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 7, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_1, :user => user_2, :category => category_1, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 6, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_2, :user => user, :category => category_2, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 5, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_3, :user => user_2, :category => category_3, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 4, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }

Idea.create! :parent => idea_4, :user => user_2, :category => category_2, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar.", :likes => 3, :document => { :description => "Descrição da ideia", :have => "O que eu já tenho", :need => "O que eu preciso" }
