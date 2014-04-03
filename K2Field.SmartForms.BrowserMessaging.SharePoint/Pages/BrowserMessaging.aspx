<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming runat="server" />

<!DOCTYPE html>
<html>
<head>
    <title></title>
    <script type="text/javascript" src="../Scripts/jquery-1.9.1.min.js"></script>
</head>
<body>
    <ul id="log"></ul>

<script type="text/javascript">
    "use strict";

    var enableDebug = false;
    var rebroadcastStrings = false;

    // This code runs when the DOM is ready and creates a context object which is needed to use the SharePoint object model
    $(document).ready(function () {


        /// get App Part properties
        enableDebug = decodeURIComponent(getQueryStringParameter("EnableDebug"));
        rebroadcastStrings = decodeURIComponent(getQueryStringParameter("RebroadcastStrings"));


        //var x = {
        //    'message': $(instance).attr("value"),
        //    'messageId': $(instance).attr("messageid"),
        //    'messageType': $(instance).attr("messagetype"),
        //    'fromUrl': window.location.href,
        //    'broadcast': $(instance).attr("rebroadcast"),
        //    'callback': $(instance).attr("callback")
        //};

        // for older Internet Explorer
        if (window.attachEvent) {
            attachEvent("onmessage", receiveMessage);
        } else {

            window.addEventListener("message", receiveMessage, false);
        }


        //window.addEventListener('message', function (e) {

        //}, false);


    });


    function receiveMessage(e) {
        var data = e.data;
        var origin = e.origin;
        if (isJSON(data)) {

            var d = parseMessage(e.data);

            $(window).trigger("browserMessageReceived", data);

            if (enableDebug == "true") {
                LogPostMessage(d['message'] + " - " + d['fromUrl']);
            }

            if (d.broadcast === true) {
                broadcastmessages(e);
            }


        } else {

            $(window).trigger("browserMessageReceived", data);

            if (enableDebug == "true") {
                LogPostMessage(data);
            }

            if (rebroadcastStrings == true) {
                broadcastmessages(e);
            }

        }

    }

    //yourVariable !== null && typeof yourVariable === 'object'

    function parseMessage(data) {
        if (isJSON(data)) {
            var d = JSON.parse(data);
        }
    }

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

            // don't rebroadcast back to messages origin url
            if (isJSON(e.data)) {
                // a JSON string

                var d = JSON.parse(e.data);

                if (!checkBroadcastUrl(d.originUrl)) {

                    //frames[i].contentWindow.location
                    frames[i].contentWindow.postMessage(JSON.stringify(d), '*');
                }

            }
            else {

                // check app part property - rebroadcast strings
                frames[i].contentWindow.postMessage(e.data, '*');
            }
        }
    }

    function checkBroadcastUrl(originUrl, frameUrl) {
        return true;
    }

    function LogPostMessage(message) {
        $('#log').prepend("<li>" + message + "</li>");
        console.log(message);
    }

    function getQueryStringParameter(paramToRetrieve) {
        var params;
        var strParams;

        params = document.URL.toLowerCase().split("?")[1].split("&");
        strParams = "";
        for (var i = 0; i < params.length; i = i + 1) {
            var singleParam = params[i].split("=");
            if (singleParam[0] == paramToRetrieve.toLowerCase())
                return singleParam[1];
        }
    }


 </script>




    </body>
</html>

