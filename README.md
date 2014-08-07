# AmuBot

[![Build Status](https://travis-ci.org/arturhoo/AmuBot.svg?branch=master)](https://travis-ci.org/arturhoo/AmuBot)
[![Code Climate](https://codeclimate.com/github/arturhoo/AmuBot/badges/gpa.svg)](https://codeclimate.com/github/arturhoo/AmuBot)
[![Coverage Status](https://img.shields.io/coveralls/arturhoo/AmuBot.svg)](https://coveralls.io/r/arturhoo/AmuBot)
[![Dependency Status](https://gemnasium.com/arturhoo/AmuBot.svg)](https://gemnasium.com/arturhoo/AmuBot)

> The bot who already knew the news when you broke it (:

## Configuration

Install Redis and the gems:

```bash
bundle install
```

Get an API V2 Room token from Hipchat.

Set the necessary environment variables in a `.env` file, like the example
bellow:

```bash
HIPCHAT_TOKEN=0f54335e46926c8cd6b4523ff2d80d3dc9d29d8f
ROOM='Room name'
```

## Running on Development Environment

```bash
bundle exec foreman run -f Procfile.dev gif
bundle exec foreman run -f Procfile.dev video
bundle exec foreman run -f Procfile.dev news
```

## Running on Heroku

```bash
heroku git:remote -a amubot
heroku config:set HIPCHAT_TOKEN=0f54335e46926c8cd6b4523ff2d80d3dc9d29d8f
heroku config:set ROOM='Room name'
heroku addons:add scheduler
heroku addons:open scheduler
```

And configure rake tasks to run at your preferred schedule for each task. Note
that you should use Rake tasks, like bellow

```bash
bundle exec rake publish:news
```
