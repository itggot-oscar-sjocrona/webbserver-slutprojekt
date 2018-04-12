class App < Sinatra::Base

	require_relative 'module.rb'
	include Database
	enable :sessions

	get '/' do
		slim(:home)
	end

	get('/error') do
		if session[:error_msg] == nil
			redirect('/')
		end
		slim(:error, locals:{error_msg:session[:error_msg], direction:session[:direction]})
	end

	get('/main') do
		slim(:main, locals:{user:session[:user]})
	end

	post '/login' do
		username = params["username"]
		password = params["password"]
		begin
			password_digest = login(username).join
			password_digest = BCrypt::Password.new(password_digest)
		rescue
			session[:error_msg] = "Login Error"
			session[:direction] = "/"
			redirect('/error')
		end
		if password_digest == password
			session[:user] = username
			redirect('/main')
		else
			session[:error_msg] = "Incorrect login"
			session[:direction] = "/"
			redirect('/error')
		end
	end

	post '/register' do
		username = params["username"]
		password1 = params["password"]
		password2 = params["confirmed_password"]

		if password1 != password2
			session[:error_msg] = "Passwords doesn't match"
			session[:direction] = "/register"
			redirect('/error')
		end
		password = BCrypt::Password.create(password1)
		begin
			register(username,password)
		rescue
			session[:error_msg] = "The username has already been taken"
			session[:direction] = "/"
			redirect('/error')
		end
		redirect('/')
	end
end           
