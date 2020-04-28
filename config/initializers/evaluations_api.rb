require 'aicrowd_evaluations'

AIcrowdEvaluations.configure do |config|
  config.api_key['AUTHORIZATION'] = ENV["EVALUATIONS_API_KEY"]
  config.host = ENV["EVALUATIONS_API_HOST"]
end
