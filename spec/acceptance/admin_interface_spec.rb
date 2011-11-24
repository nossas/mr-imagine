# coding: utf-8

require 'acceptance/acceptance_helper'

feature 'Admin interface', %q{
  In order to manage ramify contents
  As a root user
  I want to see admin options for root admin
} do

  scenario 'I log in and visit the admin path and I should see links for content administration' do
    visit('/fake_login?root_admin=true')
    #visit fake_login_url('root_admin=true')
    find("#user_menu").find('.user').click
    find_link('Painel administrativo').visible?

    visit(admin_dashboard_path)
    find_link('Dashboard')
    find_link('Categorias')
    find_link('Configuraçãos')
    find_link('Ideias')
    find_link('Oauth Providers')
    find_link('Usuários')
    end
end

