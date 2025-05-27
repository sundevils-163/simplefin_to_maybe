# Manually Syncing your Accounts

```sh
# connect to bash shell of your maybe-app container
docker exec -it $(docker ps --filter "name=maybe-app" --format "{{.ID}}" | head -n1) bash

# start the rails console
bundle exec rails console

# sync_later each Account record
Account.find_each do |account|
  account.sync_later(
    window_start_date: 1.day.ago,
    window_end_date: Time.current
  )
end
```
