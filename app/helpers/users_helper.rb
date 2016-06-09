module UsersHelper
  def gravatar_for(user, options={})
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    size = (options[:size] || 90).to_s
    image_tag(gravatar_url, alt: user.name, class: 'gravatar', size: size)
  end
end
