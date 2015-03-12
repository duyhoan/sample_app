module SessionsHelper
	def log_in(user)
		session[:user_id] = user.id
		session[:user_email] = user.email
	end

	def log_out
		forget(current_user)
		session.delete(:user_id)
		session.delete(:user_email)
		@current_user = nil
	end

	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)	
	end

	def remember(user)
		user.remember
    	cookies.permanent.signed[:user_id] = user.id
    	cookies.permanent[:remember_token] = user.remember_token
	end

	def current_user
		if session[:user_id]
			@current_user ||= User.find_by(id: session[:user_id])
		elsif cookies.signed[:user_id]
			user = User.find_by(id: cookies.signed[:user_id])
			if user && user.authenticate?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end

	# Redirects to stored location (or to the default).
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	# Stores the URL trying to be accessed.
	def store_location
		session[:forwarding_url] = request.url if request.get?
	end

	def logged_in?
		!current_user.nil?
	end
end
