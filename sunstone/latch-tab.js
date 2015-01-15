
// OpenNebula Latch addon.
// Copyright (C) 2015  Carlos Martin Sanchez
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

var latch_actions = {}

var latch_tab = {
    title:
    '<span><i class="fa fa-lg fa-fw fa-key"></i> Latch Integration</span>',
    table: '<table >\
      </table>',
    list_header: '<i class="fa fa-fw fa-key"></i> Latch Integration',
    info_header: '<i class="fa fa-fw fa-key"></i> Latch Integration',
    subheader: '<div class="row text-left support_connect">'+
        '<div class="large-6 columns" style="font-">'+
          '<p><a href="https://latch.elevenpaths.com" target="_blank">Latch</a> is an app for a mobile device designed to protect your online accounts and services when you are not connected.</p>'+
          '<ul class="fa-ul" style="font-size: 14px;">'+
            '<li><i class="fa-li fa fa-key"></i>Latch lets you implement a safety latch on your OpenNebula account</li>'+
            '<li><i class="fa-li fa fa-lock"></i>The second Latch authentication layer protects you if your OpenNebula credentials are stolen</li>'+
            '<li><i class="fa-li fa fa-bell"></i>The alert system lets you and the administrators identify suspicious activity in your account in real time</li>'+
          '</ul>'+
          '<p>To learn more and start using it, <a href="https://latch.elevenpaths.com/www/service.html" target="_blank">click here</a></p>' +
        '</div>'+
        '<div class="large-6 columns" style="padding: 0px 50px;">'+
          '<fieldset>'+
            '<legend>'+tr("Latch account config")+'</legend>'+
            '<form id="latch_pair_form">'+
              '<div class="large-12 columns">'+
                '<label for="latch_token">Pairing token</label>' +
                '<input id="latch_token" type="password"></input>' +
              '</div>'+
              '<div class="large-12 columns">'+
                '<button class="button right radius success submit_latch_pair_button" type="submit">Pair account</button>' +
              '</div>'+
            '</form>'+
            '<div class="large-12 columns latch_unpair_div">'+
              '<p>'+tr("Your OpenNebula account is ready to be secured with the Latch application in your phone.")+'</p>'+
              '<p>'+tr("You can disable the Latch integration with the following Unpair button.")+'</p>'+
              '<button class="button right radius success latch_unpair_button" type="submit">Unpair account</button>' +
            '</div>'+
            '<div class="large-12 columns latch_unavailable">'+
              '<p>'+tr("In order to use Latch, your OpenNebula account needs to be configured with the 'latch' authentication driver. Please contact your administrator")+'</p>'+
            '</div>'+
          '</fieldset>'+
        '</div>'+
      '</div>'
}

Sunstone.addMainTab('latch-tab',latch_tab);

function refresh_latch_user_info(){
    OpenNebula.User.show({
        data : {
            id: '-1'
        },
        success: function(request,user_json) {
            var info = user_json.USER;

            var st = "";

            $("#latch_pair_form", $("#latch-tab")).hide();
            $("div.latch_unpair_div", $("#latch-tab")).hide();
            $("div.latch_unavailable", $("#latch-tab")).hide();

            if ( info.AUTH_DRIVER == "latch" ){
                if (info.TEMPLATE.LATCH_ID != undefined){
                    st = "latch ready!"

                    $("div.latch_unpair_div", $("#latch-tab")).show();
                } else {
                    st = "You can pair latch"

                    $("#latch_pair_form", $("#latch-tab")).show();
                }
            } else {
                st = "driver is not latch, contact admin"

                $("div.latch_unavailable", $("#latch-tab")).show();
            }
        }
    });
}

$(document).ready(function(){
    var tab_name = 'latch-tab';

    if (Config.isTabEnabled(tab_name)) {
        refresh_latch_user_info();

        $("#latch_pair_form", $("#latch-tab")).on("submit", function(){
            var data = {
                action: "pair",
                latch_token : $("#latch_token", this).val()
            }

            // Perform action on 'self'
            var user_id = -1

            $.ajax({
                url: 'latch/user/'+user_id+'/action',
                type: "POST",
                dataType: "json",
                data: JSON.stringify(data),
                success: function(){
                    notifyMessage(tr("Latch account pair success"));
                    refresh_latch_user_info();
                },
                error: function(response){
                    notifyError(response.responseText)
                    refresh_latch_user_info();
                }
            });

            return false;
        })

        $("button.latch_unpair_button", $("#latch-tab")).on("click", function(){
            var data = {
                action: "unpair"
            }

            // Perform action on 'self'
            var user_id = -1

            $.ajax({
                url: 'latch/user/'+user_id+'/action',
                type: "POST",
                dataType: "json",
                data: JSON.stringify(data),
                success: function(){
                    notifyMessage(tr("Latch account unpair success"));
                    refresh_latch_user_info();
                },
                error: function(response){
                    notifyError(response.responseText)
                    refresh_latch_user_info();
                }
            });

            return false;
        })
    }
});

