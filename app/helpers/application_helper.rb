# app/helpers/application_helper.rb
require 'tzinfo'

module ApplicationHelper
  def local_time(time)
    tz = ENV['TZ'] || 'UTC'
    timezone = TZInfo::Timezone.get(tz)
    timezone.utc_to_local(time.utc)
  end
end
