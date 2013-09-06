require './app'
require 'nokogiri'
require 'open-uri'
require 'sinatra/activerecord/rake'

namespace :data do
  desc 'crawl entries'
  task :crawl, :page
  task :crawl do |_, args|
    p = args.page || 0
    n = "http://jigokuno.com/?page=#{p}"
    ua = 'Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko' # IE 11
    catch :fin do
      loop do
        puts n
        p = Nokogiri::HTML open(n, 'User-Agent' => ua)
        us = p.css('.entry img[src^="http://jigokuno.img.jugem.jp"], .entry img[src^="http://img.jigokuno.com"]').map{|e| e.attribute('src').to_s}
        throw :fin if us.blank?
        us.each do |u|
          puts u
          throw :fin if Entry.where(url: u).present?
          Entry.create(url: u)
        end
        n = p.css('#pager .pager_next a').map{|e| e.attribute('href').to_s}.first
        throw :fin if n.nil?
        sleep 1
      end
    end
  end

  desc 'dump data'
  task :dump do
    us = Entry.order(:url).pluck(:url)
    File.open('urls.txt', 'w') do |f|
      us.each do |u|
        f.puts u
      end
    end
  end

  desc 'create entries from urls.txt'
  task :seeds do
    File.open('urls.txt', 'r') do |f|
      f.each do |l|
        Entry.create(url: l) if Entry.where(url: l).blank?
      end
    end
  end
end