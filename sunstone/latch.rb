# OpenNebula Latch addon.
# Copyright (C) 2015  Carlos Martin Sanchez
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

ONE_LOCATION = ENV["ONE_LOCATION"]

if !ONE_LOCATION
    RUBY_LIB_LOCATION = "/usr/lib/one/ruby"
    ETC_LOCATION      = "/etc/one/"
else
    RUBY_LIB_LOCATION = ONE_LOCATION+"/lib/ruby"
    ETC_LOCATION      = ONE_LOCATION+"/etc/"
end

$: << RUBY_LIB_LOCATION

require 'nokogiri'
require 'yaml'
require 'one_latch'

post '/latch/user/:id/action' do
    body_hash = JSON.parse(@request_body)

`echo "" >> /tmp/carlos`
`echo "" >> /tmp/carlos`
`echo '#{params}' >> /tmp/carlos`
`echo '#{body_hash}' >> /tmp/carlos`

    user_id = params[:id]

    client  = $cloud_auth.client(session[:user])
    user    = OpenNebula::User.new_with_id(user_id, client)

#user.info

#`echo '#{client}' >> /tmp/carlos`
#`echo '#{user.to_xml(true)}' >> /tmp/carlos`

    action = body_hash['action']

    if (action == "pair")
        rc = OneLatch::pair(user, body_hash['latch_token'])

        if OpenNebula.is_error?(rc)
            logger.error { rc.message }
            return [500, rc.message]
        end

    elsif (action == "unpair")
        rc = OneLatch::unpair(user)

        if OpenNebula.is_error?(rc)
            logger.error { rc.message }
            return [500, rc.message]
        end
    end

    [201, ""]
end
