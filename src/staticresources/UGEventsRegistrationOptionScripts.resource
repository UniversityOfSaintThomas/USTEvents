// UGEventsRegistrationOptionScripts
$(document).ready(function () {
    $("#chooser .appointmentAdd").on("click", function () {
        var addAppt;
        var Appt = $(this).closest(".appointment");
        var requiredSel = Appt.find('.required');
        var error = false;
        if (requiredSel.length > 0) {
            if (requiredSel.val() == '') {
                error = true;
                requiredSel.addClass('aptError').on('select, click, change', function() {$(this).removeClass("aptError");});
            }
        }
        if (!error) {

            //build a box
            var ApptOffset = Appt.offset();
            var lc;
            var movingBox = $("<div/>", {id: 'movingBox' + Appt.attr("id"), class: 'movingBox'});
            movingBox.css({
                "width": (Appt.width() + 1) + 'px',
                "height": (Appt.height() + 1) + 'px',
                "left": ApptOffset.left + 'px',
                "top": ApptOffset.top + 'px',
            });
            movingBox.html('<p><i class="fa fa-plus" aria-hidden="true"></i> Adding Appointment...</p>')
            $('body').before(movingBox);
            if ($("#choosen .appointmentChoosen:last-child").length > 0) {
                lc = $("#choosen .appointmentChoosen:last-child");
            } else {
                lc = $("#choosen");
            }
            var lcOffset = lc.offset();
            movingBox.delay(300).animate({'top': (lcOffset.top + lc.height() + 10) + 'px', 'left': lcOffset.left + 'px', "height": "0px", "opacity": 0}, 300).fadeOut(100, function () {
                $(this).remove();
            });

            //move and adjust data
            var limit = Appt.data("limit");
            limit--;
            //build appointment list
            var apptcat, apptid, appttype, appttext, appttitle;
            apptid = Appt.attr('id');
            if (Appt.data('apptcat')) {
                apptcat = Appt.data('apptcat');
            } else {
                apptcat =  '';
            }
            if ( Appt.find(".appointmentType").val()) {
                appttype = Appt.find(".appointmentType").val();
            } else {
                appttype = ''
            }
            appttext = '';
            appttitle = Appt.data('appttitle');

            addAppt = $('<div/>', {
                //'id' : 'appt-' + appid,
                'data-apptid' : apptid,
                'data-apptcat' : apptcat,
                'data-appttype' : appttype,
                'data-appttitle' : appttitle,
                'data-appttext' : appttext,
                'class' : 'appointmentChoosen'
            });
            addAppt.append('<p class="appointmentTitle">' + Appt.find(".appointmentTitle a").html() + '</p>');
            addAppt.find('i').remove();
            if (Appt.find(".appointmentType").length > 0) {
                addAppt.append('<p class="appointmentDesc">' + Appt.find(".appointmentType").val() + '</p>');
            }
            addAppt.append(
                $('<a/>', {class: "appointmentRemove"})
                    .html('<i class="fa fa-times-circle" aria-hidden="true"></i><span> Remove</span></span>')
                    .on("click", function() {removeAppt($(this)); })
            );

            Appt.data("limit", limit);
            if (limit <= 0) {
                Appt.delay(300).fadeOut("fast", function() {
                    $("#choosen").append(addAppt);
                });
            } else {
                $("#choosen").append(addAppt);
                requiredSel.val('');
            }

        }
    });


    $(".appointmentTitle a").on("click", function () {
        if ($(this).find("i").hasClass("fa-chevron-down")) {
            $(this).find("i").removeClass("fa-chevron-down").addClass("fa-chevron-up");
        } else {
            $(this).find("i").removeClass("fa-chevron-up").addClass("fa-chevron-down");
        }
        $(this).closest(".appointment").find(".apptmentDetail").slideToggle("fast");
    });

});



function removeAppt(rmvBtn) {
    var aptChoosen = rmvBtn.closest(".appointmentChoosen");
    var appChooser = $('#' + aptChoosen.data('apptid'));
    appChooser.data('limit', appChooser.data('limit') + 1);
    appChooser.fadeIn("fast");
    aptChoosen.remove();
}

function populateApptJSON() {
    jsonOut = [];
    $("#choosen div.appointmentChoosen").each( function() {
        appt = {};
        appt['apptId'] = $(this).data('apptid');
        appt['apptCatagory'] = $(this).data('apptcat');
        appt['apptType'] = $(this).data('appttype');
        appt['apptText'] = $(this).data('appttext');
        appt['apptTitle'] = $(this).data('appttitle');
        jsonOut.push(appt);
    });
    $('[id$=outgoingApptJSon]').val(JSON.stringify(jsonOut));
    console.log(JSON.stringify(jsonOut));
    return true;
}