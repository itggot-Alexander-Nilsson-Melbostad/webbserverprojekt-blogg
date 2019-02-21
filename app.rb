require 'slim'
require 'sinatra'
require 'SQLite3'
require 'BCrypt'
require 'byebug'

enable :sessions

get("/") do
    slim(:index)
end

post("/login") do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true
    result = db.execute("SELECT Username, Password, UserId, Authority, Nickname FROM users WHERE Username = '#{params["Username"]}'")
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
        session[:User] = params["Username"]
    else
        redirect("/loginfailed")
    end
    slim(:index, locals:{
        index: result
    })
    redirect("/posts")
end

post("/logout") do
    session.destroy
    redirect("/")
end

get("/loginfailed") do
    slim(:loginfailed)
end

post("/create") do
    db =SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true
    new_name = params["Username"] 
    new_password = params["Password1"]
    new_nickname = params["Nickname"]

    if params["Password1"] == params["Password2"]
        new_password_hash = BCrypt::Password.create(new_password)
        db.execute("INSERT INTO users (Username, Password, UserId, Authority, Nickname) VALUES (?,?,?,?,?)", new_name, new_password, 1, new_nickname)
        redirect("/posts")
    else
        redirect("/loginfailed")
    end
end

get("/new") do
    slim(:new)
end     