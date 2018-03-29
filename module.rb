module Database
    def connect()
        return SQLite::Database.new('/db/chatt_app.db')
    end

    def register()
        return  
    end

end