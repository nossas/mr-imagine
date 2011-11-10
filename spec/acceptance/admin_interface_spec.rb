# coding: utf-8

require 'acceptance/acceptance_helper'

feature 'Admin interface', %q{
  In order to manage ramify contents
  As a root user
  I want to see admin options for root admin
} do

  scenario 'I visit admin interface and I should see links for content administration' do
    visit fake_login('root_admin=true')
    page.should have_link('Painel administrativo')

    find("a.user").click
    page.should have_link('Painel administrativo')
    visit admin_dashboard_path
    page.should have_link('Dashboard')
    page.should have_link('Categorias')
    page.should have_link('Usuários')
    page.should have_link('Configuraçãos')
    page.should have_link('Ideia')
    page.should have_link('Oauth Providers')
  end
end

