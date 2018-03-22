class App < Sinatra::Base

	require_relative 'module.rb'
	include Database


	get '/' do
		"Hello, Grillkorv!"
	end

end           
