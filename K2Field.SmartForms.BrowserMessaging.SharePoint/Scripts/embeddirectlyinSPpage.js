<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
<script type="text/javascript">
var enableDebug = "true";
var broadcastStrings = "true";

// This code runs when the DOM is ready and creates a context object which is needed to use the SharePoint object model
ExecuteOrDelayUntilScriptLoaded(regMessageReceive, "sp.js")
//_spBodyOnLoadFunctionNames.push(regMessageReceive);

// $(document).ready(function () {

// //var x = {
// //    'message': $(instance).attr("value"),
// //    'messageId': $(instance).attr("messageid"),
// //    'messageType': $(instance).attr("messagetype"),
// //    'fromUrl': window.location.href,
// //    'broadcast': $(instance).attr("broadcast"),
// //    'callback': $(instance).attr("callback"),
// //    'messageDatetime': 
// //};

// });


function regMessageReceive() {
    // for older Internet Explorer
    if (window.attachEvent) {
        attachEvent("onmessage", receiveMessage);
    } else {

        window.addEventListener("message", receiveMessage, false);
    }
}

function receiveMessage(e) {

    if(e.data.startsWith("<message")) {
        //window.postMessage(e.data, "*");
        console.log("RECEIVED RESIZE: "+ e.data);

        // call the standard resize method on a SP page
        if (SPAppIFramePostMsgHandler) {
            SPAppIFramePostMsgHandler(e) 
        }

        return;
    }

    var data = e.data;
    var origin = e.origin;
    if (isJSON(data)) {

        var d = parseMessage(e.data);

        //$(window).trigger("browserMessageReceived", data);
        if (d.broadcast == true || d.broadcast == "true" || d.broadcast == "True") {
            broadcastmessages(e);
        }


        if (enableDebug.toLowerCase() == "true") {
            LogPostMessage(d['message'] + " - " + d['fromUrl']);
        }

    } else {

        //$(window).trigger("browserMessageReceived", data);

        if (enableDebug.toLowerCase() == "true") {
            LogPostMessage(data);
        }

        if (broadcastStrings.toLowerCase() == "true") {
            broadcastmessages(e);
        }

    }

}

function parseMessage(data) {
    if (isJSON(data)) {
        return JSON.parse(data);
    }
}

// needs to be improved
function isJSON(data) {
    if (data.substring(0, 1) === '{') {
        return true;
    } else {
        return false;
    }
}

function broadcastmessages(e) {
    var frames = $('iframe');
    for (var i = 0; i < frames.length; i++) {

        if (isJSON(e.data)) {
            // a JSON string
            var d = JSON.parse(e.data);

            // change broadcast status so that message does't get echoed unncessarily back to this page
            //d.broadcast = "false";

            //frames[i].contentWindow.postMessage(e.data, '*');
            // don't broadcast back to messages origin url
            if (checkBroadcastUrl(d.fromUrl)) {
                frames[i].contentWindow.postMessage(JSON.stringify(d), '*');
            }
        }
        else {
            // check app part property - broadcast strings

            if(broadcastStrings.toLowerCase() == "true") {
                frames[i].contentWindow.postMessage(e.data, '*');
            }
        }
    }
}

function checkBroadcastUrl(originUrl, frameUrl) {
    return true;
}

function LogPostMessage(message) {
    //$('#log').prepend("<li>" + message + "</li>");
    console.log(message);
}


</script>