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

        //if (K2_SPAppIFramePostMsgHandler) {
        //    K2_SPAppIFramePostMsgHandler(e);
        //}

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

            //if(broadcastStrings.toLowerCase() == "true") {
            //    frames[i].contentWindow.postMessage(e.data, '*');
            //}
            frames[i].contentWindow.postMessage(e.data, '*');
        }
    }
}

var K2_SPAppIFramePostMsgHandler = function (e) {
    if (e.data.length > 100)
        return;

    var regex = RegExp(/(<\s*[Mm]essage\s+[Ss]ender[Ii]d\s*=\s*([\dAaBbCcDdEdFf]{8})(\d{1,3})\s*>[Rr]esize\s*\(\s*(\s*(\d*)\s*([^,\)\s\d]*)\s*,\s*(\d*)\s*([^,\)\s\d]*))?\s*\)\s*<\/\s*[Mm]essage\s*>)/);
    var results = regex.exec(e.data);
    if (results == null)
        return;

    var senderIndex = results[3];
    if (senderIndex >= spAppIFrameSenderInfo.length)
        return;

    var senderId = results[2] + senderIndex;
    var iframeId = unescape(spAppIFrameSenderInfo[senderIndex][1]);
    var senderOrigin = unescape(spAppIFrameSenderInfo[senderIndex][2]);
    if (senderId != spAppIFrameSenderInfo[senderIndex][0] || senderOrigin != e.origin)
        return;

    var width = results[5];
    var height = results[7];
    if (width == "") {
        width = '300px';
    }
    else {
        var widthUnit = results[6];
        if (widthUnit == "")
            widthUnit = 'px';

        width = width + widthUnit;
    }

    if (height == "") {
        height = '150px';
    }
    else {
        var heightUnit = results[8];
        if (heightUnit == "")
            heightUnit = 'px';

        height = height + heightUnit;
    }

    var widthCssText = "";
    var resizeWidth = ('False' == spAppIFrameSenderInfo[senderIndex][3]);
    //if (resizeWidth) {
    //    widthCssText = 'width:' + width + ' !important;';
    //}

    // JJK: ignore SharePoint's settings
    resizeWidth = true;
    widthCssText = 'width:' + width + ' !important;';


    var cssText = widthCssText;
    var resizeHeight = ('False' == spAppIFrameSenderInfo[senderIndex][4]);
    //if (resizeHeight) {
    //    cssText += 'height:' + height + ' !important';
    //}

    // JJK: ignore SharePoint's settings
    resizeHeight = true;
    cssText += 'height:' + height + ' !important';


    if (cssText != "") {
        var webPartInnermostDivId = spAppIFrameSenderInfo[senderIndex][5];
        if (webPartInnermostDivId != "") {
            var webPartDivId = 'WebPart' + webPartInnermostDivId;

            var webPartDiv = document.getElementById(webPartDivId);
            if (null != webPartDiv) {
                webPartDiv.style.cssText = cssText;
            }

            cssText = "";
            if (resizeWidth) {
                var webPartChromeTitle = document.getElementById(webPartDivId + '_ChromeTitle');
                if (null != webPartChromeTitle) {
                    webPartChromeTitle.style.cssText = widthCssText;
                }

                cssText = 'width:100% !important;'
            }

            if (resizeHeight) {
                cssText += 'height:100% !important';
            }

            var webPartInnermostDiv = document.getElementById(webPartInnermostDivId);
            if (null != webPartInnermostDiv) {
                webPartInnermostDiv.style.cssText = cssText;
            }
        }

        var iframe = document.getElementById(iframeId);
        if (null != iframe) {
            iframe.style.cssText = cssText;
        }
    }
}


function checkBroadcastUrl(originUrl, frameUrl) {
    return true;



    var parserOrigin = document.createElement('a');
    parserOrigin.href = originUrl;
 
    var parserFrame = document.createElement('a');
    parserFrame.href = frameUrl;




    //parser.protocol; // => "http:"
    //parser.hostname; // => "example.com"
    //parser.port;     // => "3000"
    //parser.pathname; // => "/pathname/"
    //parser.search;   // => "?search=test"
    //parser.hash;     // => "#hash"
    //parser.host;     // => "example.com:3000"


}

function LogPostMessage(message) {
    //$('#log').prepend("<li>" + message + "</li>");
    console.log(message);
}


</script>