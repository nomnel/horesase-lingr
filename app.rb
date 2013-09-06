require "rubygems"
require "bundler/setup"

require 'json'
require 'sinatra'
require 'sinatra/activerecord'

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://user:pw@host/dbname')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

class Entry < ActiveRecord::Base
end

post '/' do
  ps = JSON.parse request.body.read
  if ps['events'].first['message']['text'] == 'misawa'
    Entry.order('RANDOM()').limit(1).first.url
  else
    ''
  end
end