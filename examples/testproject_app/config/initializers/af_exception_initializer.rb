# frozen_string_literal: true

# If you find you need to change any of the configuration here consider if you
# also need to change the template in the AfException gem.
# https://github.com/appfolio/af_exception/blob/master/lib/generators/templates/af_exception_initializer.rb

require 'af_exception/rollbar_adapter'

AfException.configure do |config|
  config.adapter = AfException::RollbarAdapter
end

Rollbar.configuration.tap do |config|
  config.access_token = AfSettings.settings.dig!('rollbar', 'post_server_item_access_token')
  config.environment = Rails.application.deployment_env
  config.payload_options = { slice: Rails.application.slice }

  config.before_process << lambda do |options|
    options[:scope][:person] = { id: AfHijack.account_name }
    options[:scope][:code_version] = Rails.application.revision

    if Object.const_defined?(:Experiments)
      options[:scope][:enabled_experiments] = Experiments.setup.select { |_, is_enabled| is_enabled }.keys.sort.join("\n")
    end

    if AfRuntime::Controllers::RequestXid.xid.present?
      options[:scope][:xid] = AfRuntime::Controllers::RequestXid.xid
    end
  end
end
