class App < Sinatra::Base

	require_relative 'module.rb'
	include Database
	enable :sessions

	get '/' do
		slim(:home)
	end

	get('/error') do
		slim(:error, locals:{error_msg:session[:error_msg], direction:session[:direction]})
	end

	post '/login' do
		
	end

	post 'register' do
		username = params["username"]
		password1 = params["password1"]
		password2 = params["password2"]

		if password1 != password2
			session[:error_msg] = "Passwords doesn't match"
			session[:direction] = "/register"
			redirect('/error')
		end
		password = BCrypt::Password.create(password1)
		connect()
		begin
			#module 
		rescue
			session[:error_msg] = "The username has already been taken"
			session[:direction] = "/"
			redirect('/error')
		end
		redirect('/')
	end
end           
