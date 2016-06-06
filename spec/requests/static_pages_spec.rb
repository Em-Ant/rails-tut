require 'rails_helper'

describe "Static pages" do

  describe "Home page" do
    it "should have the content 'Sample App'" do
      visit '/static_pages/home'
      expect(page).to have_selector('h1', :text => 'Sample App')
    end

    it "should have the base title" do
      visit '/static_pages/home'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App")
    end

    it "should not have the cutom title" do
      visit '/static_pages/home'
      expect(page).not_to have_title("| Home")
    end

  end

  describe "Help Page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_selector('h1', :text => 'Help')
    end

    it "should have the base title" do
      visit '/static_pages/help'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App")
    end

    it "should have the custom title'" do
      visit '/static_pages/help'
      expect(page).to have_title("| Help")
    end
  end

  describe "About Page" do
    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_selector('h1', :text => 'About Us')
    end

    it "should have the base title'" do
      visit '/static_pages/about'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App")
    end

    it "should have the custom title'" do
      visit '/static_pages/about'
      expect(page).to have_title("| About")
    end
  end

end
