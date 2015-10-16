# encoding: UTF-8

# Copyright 2014 Optimus Labs Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'omniauth-oauth2'
require 'json'
require 'net/http'

module OmniAuth
  module Strategies
    class SmartThings < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://graph.api.smartthings.com',
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      }
      option :scope, :app

      uid {
        raw_info[0]["url"].gsub(/^\/api\/smartapps\/installations\//, "")
      }

      extra do
        { :endpoints => raw_info }
      end

      def raw_info
        return @raw_info if @raw_info
        @raw_info = {}
        uri = URI("https://graph.api.smartthings.com/api/smartapps/endpoints")
        req = Net::HTTP::Get.new(uri)
        req["Authorization"] = "Bearer #{access_token.token}"
        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          res = http.request(req)
          @raw_info = JSON.parse(res.body)
          puts res.body
        end
        return @raw_info
      end
    end
  end
end
OmniAuth.config.add_camelization 'smartthings', 'SmartThings'
