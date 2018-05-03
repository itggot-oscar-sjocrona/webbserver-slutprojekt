class App < Sinatra::Base

	require_relative 'module.rb'
	include Database
	include Censor
	enable :sessions

	get '/' do
		session[:user] = nil
		slim(:home)
	end

	get('/error') do
		if session[:error_msg] == nil
			redirect('/')
		end
		slim(:error, locals:{error_msg:session[:error_msg], direction:session[:direction]})
	end

	get('/main') do
		if session[:user] != nil
			room_id_name = create_id_to_name()
			user_id = user_id_from_username(session[:user])
			rooms = get_rooms(user_id)
			slim(:main, locals:{user:session[:user],rooms:rooms,room_id_name:room_id_name})
		else
			redirect('/')
		end
	end

	get('/main/rooms/:room_id') do
		if session[:user] == nil
			redirect('/')
		end
		room_id = params["room_id"]
		users = get_userinfo_from_room(room_id)
		messages = get_message(room_id)
		logged_in_user = get_userinfo(session[:user])
		message_limit = 15
        if users.include?([logged_in_user[0][0],logged_in_user[0][1]])
            while messages.length > message_limit
                messages.delete_at(0)
			end
			messages.each_with_index do |word,i|
				messages[i][2] = censor(word[2])
			end
			all_users = get_all_users()
            all_users = all_users.reject {|w| users.include? w}
            slim(:room, locals:{users:users, messages:messages, room_id:room_id, all_users:all_users})
        else
			session[:error_msg] = "You are not allowed to do that"
			session[:user] = nil
			session[:direction] = "/"
			redirect('/error')
        end
	end

	post('/main/post_message/:id') do
        if session[:user] == nil
			redirect('/')
		end
		room_id = params["id"]
		users = get_userinfo_from_room(room_id)
		message = params["message"]
		if message.length < 1 || message.length > 40
			session[:error_msg] = "Bad message length"
			session[:direction] = "/main/rooms/#{room_id}"
			redirect('/error')
		end
		if message.strip == ""
			session[:error_msg] = "Message must contain letters"
			session[:direction] = "/main/rooms/#{room_id}"
			redirect('/error')
		end
		logged_in_user = get_userinfo(session[:user])
		if users.include?([logged_in_user[0][0],logged_in_user[0][1]])
			message(logged_in_user[0][0],room_id,message)
			redirect("/main/rooms/#{room_id}")
		else
			session[:error_msg] = "You are not allowed to do that"
			session[:user] = nil
			session[:direction] = "/logout"
			redirect('/error')
		end
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

	get('/main/invite/:user_id/:room_id') do
        if session[:user] == nil
			redirect('/')
		end
		room_id = params["room_id"]
		users = get_userinfo_from_room(room_id)
		reciever_id = params["user_id"]
		logged_in_user = get_userinfo(session[:user])
		if users.include?([logged_in_user[0][0],logged_in_user[0][1]])
			invite(reciever_id,room_id)
			redirect("/main/rooms/#{room_id}")
		else
			session[:error_msg] = "You are not allowed to do that"
			session[:user] = nil
			session[:direction] = "/logout"
			redirect('/error')
		end
	end

	post '/main/rooms/create' do
		room_name = params["room_name"]
		user_id = user_id_from_username(session[:user])
		if room_name.length < 2
			session[:error_msg] = "room name must be at least 3 characters"
			session[:direction] = "/main"
			redirect('/error')
		end
		if room_name.strip == ""
			session[:error_msg] = "room name must contain letters or numbers"
			session[:direction] = "/main"
			redirect('/error')
		end
		create_room(user_id,room_name)
		redirect('/main')
	end

	post '/register' do
		username = params["username"]
		password1 = params["password"]
		password2 = params["confirmed_password"]

		if username.include? ","
			session[:error_msg] = "Illegal characters"
			session[:direction] = "/"
			redirect('/error')	
		end

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
