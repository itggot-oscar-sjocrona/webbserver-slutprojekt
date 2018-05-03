module Database
    def connect()
        return SQLite3::Database.new('./db/chatt_app.db')
    end

    def register(name, pass)
        db = connect()
        db.execute("INSERT INTO users (username,password) VALUES(?,?)", [name, pass])
    end

    def login(username)
        db = connect()
        return db.execute("SELECT password FROM users WHERE username=?", [username])
    end

    def get_rooms(user)
        db = connect()
        return db.execute("SELECT room_id FROM user_room WHERE user_id = ?",[user])
    end

    def get_userinfo_from_room(room_id)
        db = connect()
        return db.execute("SELECT id,username FROM users WHERE id IN (SELECT user_id FROM user_room WHERE room_id = ?)", [room_id])
    end

    def get_all_users()
        db = connect()
        return db.execute("SELECT id,username FROM users")
    end

    def get_message(id)
        db = connect()
        return db.execute("SELECT * FROM messages WHERE room_id = ?",[id])
    end

    def get_userinfo(name)
        db = connect()
        return db.execute("SELECT * FROM users WHERE username = ?",[name])
    end

    def message(logged_in_user,room_id,message)
        db = connect()
        db.execute("INSERT INTO messages (sender_id, room_id, content) VALUES (?,?,?)",[logged_in_user,room_id,message])
    end

    def invite(user_id,room_id)
        db = connect()
        db.execute("INSERT INTO user_room (user_id,room_id) VALUES (?,?)",[user_id,room_id])
    end

    def create_id_to_name()
        db = connect()
        allrooms = db.execute("SELECT room_id FROM user_room")
        room_id_name = {}
        allrooms.each do |room_id|
            room_id_name[room_id.join] = db.execute("SELECT name FROM rooms WHERE id=?", [room_id.join]).join
        end
        return room_id_name
    end
    
    def user_id_from_username(username)
        db = connect()
        return db.execute("SELECT id FROM users WHERE username = ?", [username]).join
    end

    def create_room(user_id,room_name)
        db = connect()
		db.execute("INSERT INTO rooms (name,owner) VALUES (?,?)",[room_name,user_id])
		ids = db.execute("SELECT id FROM rooms WHERE name = ? AND owner = ?",[room_name,user_id])
		largest = 0
		ids.each do |id|
			if id[0] > largest
				largest = id[0]
			end
		end
		db.execute("INSERT INTO user_room (user_id,room_id) VALUES (?,?)",[user_id,largest])
    end
end

module Censor # Kollaboration med William Eriksson
    def censor(message)
        ugly_words = File.readlines("public/misc/curse_words.txt")
        ugly_words.each_with_index do |word,i|
            ugly_words[i] = word.chomp
        end
        message = message.split(" ")
        edited_message = []
        message.each do |word|
            word1 = word
            p ugly_words
            p word.downcase
            if ugly_words.include?(word.downcase)
                y = word.length
                x = '*'
                o = ''
                y.times do 
                    o+=x
                end
                word1 = o
            end
            edited_message.push(word1)
        end
        return edited_message.join(" ")
    end
end