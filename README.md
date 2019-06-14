# README

This is website that allow user who can upload raw data and proxy, and get all results from the fastpeople, include id, emails, phones,...

This website was build by using these technologies as:

* Ruby version: 2.6.3

* Rails version: 5.2.3

* Mechanize

* Services (Delayed job)

* sqllite

# How to run
Pull source code from git, and run 
`rails crawl_fast_people:start`

* When you run this command, it will start scrape data from `fastpeoplesearch.com` website.

* You can check the log in `log/***_fast_people.log` to view log file.

* When the crawl finished, it will export a xlsx file. You can find it in folder:
`public/fast_people.xlsx`

* The raw data you can find in `public/Book1.csv`

* The proxy file you can find in `public/proxy.txt`

# Gui
