def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def sign_in(user, options={})
  if options[:no_capybara]
    if options[:no_it]
      # While testing controllers is not possible to send requests to other controllers
      session[:user_id] = user.id
    else
      post sessions_path, action: "create", controller: "sessions", session: { email:      user.email,
                                  password:    user.password,
                                  remember_me: 0 }
    end
  else
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end
