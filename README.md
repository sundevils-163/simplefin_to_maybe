# SimpleFIN to Maybe

A project to synchronize transaction data from [SimpleFIN](https://beta-bridge.simplefin.org/) to a self-hosted [Maybe](https://github.com/maybe-finance/maybe) instance.

## Pre-requisites

1. [Ruby](https://www.ruby-lang.org/en/downloads/)
1. A SimpleFIN [Access Token (Step 2)](https://beta-bridge.simplefin.org/info/developers)
1. An exposed port to your self-hosted Maybe instance's PostgreSQL container/database

## Quick-Start Steps

1. `git clone git@github.com:steveredden/simplefin_to_maybe.git`
1. `cd simplefin_to_maybe`
1. `bundle install`
1. Rename `.env.example` to `.env` and fill out each environment variable
1. `ruby ./bin/simplefin_to_maybe.rb

## Workflow

The utility requires that you create your various accounts in Maybe before running the utility.

The utility will interact with the PostgreSQL database, retrieving your `family` id, and any accounts created in your instance.

