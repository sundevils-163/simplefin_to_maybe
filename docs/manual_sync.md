# Manually Syncing your Accounts

#### Connect to bash shell of your maybe-app container

```sh
docker exec -it $(docker ps --filter "name=maybe-app" --format "{{.ID}}" | head -n1) bash
```

#### Start the rails console

```sh
bundle exec rails console
```

#### .sync_later each Family record

```sh
Family.find_each do |family|
  family.sync_later(
    window_start_date: 1.day.ago,
    window_end_date: Time.current
  )
end
```

#### Alternatively, .sync_later each Account record

```sh
Account.find_each do |account|
  account.sync_later(
    window_start_date: 1.day.ago,
    window_end_date: Time.current
  )
end
```
