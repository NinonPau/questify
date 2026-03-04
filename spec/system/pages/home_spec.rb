require "rails_helper"

RSpec.describe 'Home page', type: :system do
  before { driven_by :rack_test }
  it 'shows the login link' do
    visit root_path
    expect(page).to have_link('Log In', href: new_user_session_path)
  end

  it 'shows the signup link' do
    visit root_path
    expect(page).to have_link('Sign Up', href: new_user_registration_path)
  end
end
