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

require 'yaml'

#############################
# TODO
require_relative '/home/cmartin/latch/latch-sdk-ruby/Latch'
#module Latch
#    module_eval File.read('/home/cmartin/latch/latch-sdk-ruby/Latch.rb')
#end
#############################

module OneLatch

    def self.pair(user, token)
        conf = YAML.load(File.read(ETC_LOCATION+'/auth/latch_auth.conf'))

        latch_api = Latch.new(conf[:app_id], conf[:app_secret])

        rc = user.info
        return rc if OpenNebula.is_error?(rc)

        # Check USER:MANAGE rights before calling Latch servers
        rc = user.update("", true)
        return rc if OpenNebula.is_error?(rc)

        if user['ID'].to_i == 0
            return OpenNebula::Error.new(
                "Latch is not supported for the oneadmin (0) user")
        end

        if user['AUTH_DRIVER'] != 'latch'
            return OpenNebula::Error.new(
                "Latch pairing is only supported for users with the authorization driver 'latch' set")
        end

        # If driver != latch, return error

        rc = latch_api.pair(token)

        if !rc.error.nil?
            return OpenNebula::Error.new(rc.error.message)
        end

        latch_id = rc.data["accountId"]
        rc = user.update("LATCH_ID = #{latch_id}", true)

        if OpenNebula.is_error?(rc)
            latch_api.unpair(latch_id)
            return rc
        end
    end

    def self.unpair(user)
        conf = YAML.load(File.read(ETC_LOCATION+'/auth/latch_auth.conf'))

        latch_api = Latch.new(conf[:app_id], conf[:app_secret])

        rc = user.info
        return rc if OpenNebula.is_error?(rc)

        # Check USER:MANAGE rights before calling Latch servers
        rc = user.update("", true)
        return rc if OpenNebula.is_error?(rc)

        # The driver is not checked. If the admin changes the user's driver
        # from latch to other, the unpair can still be done

        latch_id = user['TEMPLATE/LATCH_ID']

        if (latch_id.nil?)
            return OpenNebula::Error.new("This user is not paired with a Latch account")
        end

        user.delete_element('TEMPLATE/LATCH_ID')
        user.update(user.template_str, false)

        rc = latch_api.unpair(latch_id)

        if !rc.error.nil?
            user.update("LATCH_ID = #{latch_id}", true)

            return OpenNebula::Error.new(rc.error.message)
        end
    end
end