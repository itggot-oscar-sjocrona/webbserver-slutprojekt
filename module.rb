module Database
    def connect()
        return SQLite3::Database.new('./db/chatt_app.db')
    end

    def register(name, pass)
        db = connect()
        return db.execute("INSERT INTO users (username,password) VALUES(?,?)", [name, pass])
    end

    def login(username)
        db = connect()
        return db.execute("SELECT password FROM users WHERE username=?", [username])
    end

    def get_pic(username)
        db = connect()
        return db.execute("SELECT picture_url FROM users WHERE username=?", [username])
    end

    def search_for(user)
        db = connect()
        user = "%"+user+"%"
        return db.execute("SELECT username FROM users WHERE username LIKE ?", [user])
    end
end