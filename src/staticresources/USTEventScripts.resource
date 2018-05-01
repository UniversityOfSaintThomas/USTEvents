// USTEventScripts
var eventsObj, dMonth, dYear;
var overlay = '<div class="waiting-overlay"></div>';
//parse event cookie
var UGSettings = JSON.parse(readCookie('UGEvent'));

$(document).ready(function () {

    $("#fullCalendarView").fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,basicWeek,basicDay'
        },
        height: 'auto',
        events: eventsObj,
        viewRender: function (event, element) {
            loadJSONEvents();
            fullCalButtonEvts();
        },
        eventRender: function(event, element) {
            var evtTmplt = '<div class="ust-title"><h4>'+ event.title + '</h4></div>';
            evtTmplt += '<div class="ust-desc">';
            if (event.description) {
                evtTmplt += "<p>" + event.description + "</p>";
            }
            if (event.eventUrl) {
                if (!event.eventClosed) {
                    evtTmplt += '<p><a href="' + event.eventUrl + '&audience=' + $("#audienceDD").val() + '" class="button" onclick="return setSessionCookie(\'' + event.ID + '\');">Register</a></p>';
                } else {
                    evtTmplt += '<p><em>This event registration has closed. Thank you for your interest.</em></em></p>';
                }
            }
            evtTmplt += '</div>';
            element.find('.fc-title').closest('.fc-content').html(evtTmplt);
        },
        dayClick: function(date, jsEvent, view) {
            $("#fullCalendarView").fullCalendar('gotoDate',date);
            $("#fullCalendarView").fullCalendar('changeView','basicDay');
        },
        eventClick: function(event, jsEvent, view) {
            $("#fullCalendarView").fullCalendar('gotoDate',event.start);
            $("#fullCalendarView").fullCalendar('changeView', 'basicDay');
            if (event.eventClosed) {
                alert('Event Closed!');
            }
        }
    });

    $("#audienceDDwrap, #audienceDDwrap").append(overlay);

    $("#audienceDD").on("change", function () {
        eraseCookie('UGEvent');
        createCookie('UGEvent','{"audience" : "' + $(this).val() + '"}', '');
        if ($(this).val() !== '') {
            //start loading in the list of events by audience
            loadJSONEvents();
        }
    });



    //initial load of dropdown audience type
    loadAudienceDD();



});

function setSessionCookie(sessionID) {
    eraseCookie('UGEvent');
    createCookie('UGEvent','{"audience" : "' + $("#audienceDD").val() + '", "sessionID" : "' + sessionID + '" }', '');
    return true;
}

function fullCalButtonEvts() {
    $('#fullCalendarView .fc-prev-button').click(function () {
        loadJSONEvents();
        //alert('prev is clicked, do something');
    });

    $('#fullCalendarView .fc-next-button').click(function () {
        loadJSONEvents();
        // alert('nextis clicked, do something');
    });
}

function loadJSONEvents() {
    $("#dayEventList").html("<h3>Events</h3><p>Please select above to see events available to you.</p>");
    viewStart = getCurrentSOQLDateTimeLiteral($("#fullCalendarView").fullCalendar('getView').start).toString();
    viewEnd = getCurrentSOQLDateTimeLiteral($("#fullCalendarView").fullCalendar('getView').end).toString();
    $.ajax({
        url: "/applicantportal/UGEventFeed",
        data: {'viewStart': viewStart, 'viewEnd': viewEnd, 'feedType': 'eventList', 'audience': $("#audienceDD").val()},
        dataType: "json",
        cache: false
    }).done(function (data) {
        eventsObj = data;
        if (!eventsObj.length) {
            $("#dayEventList").html("<h3>Events</h3><p>Sorry, no events for your particular settings at this time.</p>");
        }
        $("#fullCalendarView").fullCalendar('removeEvents');
        $("#fullCalendarView").fullCalendar('addEventSource', eventsObj);

    }).fail(function () {
        alert("error");
    }).always(function () {
        //alert( "complete" );
    });
}

function findEvents(edate, sessionID) {
    var evOut, niceDate, dateSplit, results;
    edate = getCurrentSOQLDateTimeLiteral(edate, true);
    niceDate = new Date(edate);
    if (sessionID) {
        results = $.grep(eventsObj, function (n, i) {
            return n.start.indexOf(edate) > -1;            //edate == n.startDate;
        });
    } else {
        edateSplit = edate.split("T");
        edate = edateSplit[0];
        results = $.grep(eventsObj, function (n, i) {
            return sessionID == n.id;            //edate == n.startDate;
        });
    }

    evOut = "<h3>Events on " + niceDate.toDateString() + "</h3><p>" + results.length + " results meet your criteria.</p>";
    evOut += "<table>";
    $.each(results, function (index, value) {
        evOut += "<tr>";
        evOut += "<td><p><strong>" + value.title + "</strong>";
        if (value.sessionTitle) {
            evOut += "<br>" + value.sessionTitle;
        }
        if (value.sessionDesc) {
            evOut += "<br>" + value.sessionDesc;
        }
        evOut += "</p>";
        if (value.Description) {
            evOut += "<p>" + value.Description + "</p>";
        }
        alert(value.eventClosed);
        if (value.eventClosed != true) {
            evOut += "<a href='/applicantportal/UGEventRegister?sessionID=" + value.ID + "&audience=" + encodeURI($("#audienceDD").val()) + "' class='button'>Register</a></td>"
        }
        evOut += "</tr>"
    });
    evOut += "</table>";
    $("#dayEventList").html(evOut);
}

function loadAudienceDD() {
    $.ajax({
        url: "/applicantportal/UGEventFeed",
        data: {'feedType': 'audienceDD'},
        dataType: "json"
    }).done(function (data) {
        populateschSel(data, $("#audienceDD"))
        $("#audienceDDwrap .waiting-overlay").remove();

        //preselect audience based on cookie
        if (UGSettings != null) {
            if(UGSettings.audience!=null) {
                $("#audienceDD").val(UGSettings.audience);
                loadJSONEvents();
            }
        }
        //reload the calendar with the new audience
        $("#fullCalendarView").fullCalendar('rerenderEvents');
    }).fail(function () {
        alert("error");
    }).always(function () {
        //alert( "complete" );
    });
}

function populateschSel(data, selector, keyAsText) {
    selector.find("option").remove();
    selector.append("<option value='' selected='selected'>Select...</option>");
    $.each(data, function (key, value) {
        selector.append($('<option>').text(value).attr('value', key));
    });
    $(document).foundation('reflow');
}

//Make a SOQL happy datetime with these two functions
function twoDigit(number) {
    var twodigit = number >= 10 ? number : "0" + number.toString();
    return twodigit;
}

function getCurrentSOQLDateTimeLiteral(dt, addTZ) {
    if (!dt) {
        dt = new Date()
    } else {
        dt = new Date(dt);
    }
    var soqlDTLiteral = dt.getUTCFullYear() + '-' + twoDigit(dt.getUTCMonth() + 1) + '-' + twoDigit(dt.getUTCDate());
    if (addTZ) {
        soqlDTLiteral += 'T';
    } else {
        soqlDTLiteral += ' ';
    }
    soqlDTLiteral += twoDigit(dt.getUTCHours()) + ':' + twoDigit(dt.getUTCMinutes()) + ':' + twoDigit(dt.getUTCSeconds());
    if (addTZ) {
        soqlDTLiteral += 'Z';
    }
    return soqlDTLiteral;
}

function createCookie(name, value, days) {
    var expires;

    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }
    document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + expires + "; path=/";
}

function readCookie(name) {
    var nameEQ = encodeURIComponent(name) + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) === ' ')
            c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0)
            return decodeURIComponent(c.substring(nameEQ.length, c.length));
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}