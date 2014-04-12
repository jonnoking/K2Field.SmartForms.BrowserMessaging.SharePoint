<%@ Page language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>

    <head>
    <title>Browser Messaging IFrame</title>

    <script src="../Scripts/jquery-1.9.1.min.js" type="text/javascript"></script>
    <script src="/_layouts/15/MicrosoftAjax.js" type="text/javascript"></script>
    <script src="/_layouts/15/sp.runtime.js" type="text/javascript"></script>
<%--    <link href="https://portal.denallix.com/_layouts/15/defaultcss.ashx" rel="stylesheet">--%>
     <script src="/_layouts/15/sp.js" type="text/javascript"></script>
    <script src="../Scripts/Helper.js" type="text/javascript"></script>
    <script type="text/javascript">
        'use strict';

        // FEATURE REQUESTS
        // Solve echo issue
        // pre defined messages e.g. resize, replace url
        // make passing standard sharepoint query string values optional
        // can we pass page QS to form?


        // Code adapted from the K2 SmartForm Viewer app part
        (function () {

            //document.write('<link rel="stylesheet" href="/_layouts/15/1033/styles/themable/corev15.css" />');
            var hostUrl = stripTrailingSlash(getSPHostUrl());

            var context;
            var user;
            //var listColl;
            //var settingItems;
            //var listFound = false;

            var iFrameUrl = "";
            var parentPageDomain = "";
            var isSmartForm = "false";
            var smartFormsRuntimeUrl = "";
            var formName = "";
            var isView = "false";
            var queryStringPassThrough = "";
            var attachSharePointParams = "";

            iFrameUrl = getQueryStringParameter("IFrameUrl");
            //parentPageDomain = getQueryStringParameter("ParentPageDomain");
            isSmartForm = getQueryStringParameter("IsSmartForm");
            smartFormsRuntimeUrl = getQueryStringParameter("SmartFormsRuntimeUrl");
            formName = getQueryStringParameter("FormName");
            isView = getQueryStringParameter("IsView");
            attachSharePointParams = getQueryStringParameter("AttachSharePointParams");

            //queryStringPassThrough = getQueryStringParameter("QueryStringPassThrough");            
            //var qsItems = [];

            //if (queryStringPassThrough.length > 0) {
            //    qsItems = queryStringPassThrough.split(",");
            //}

            // debugging
            //console.log(iFrameUrl);            
            //console.log(isSmartForm);
            //console.log(smartFormsRuntimeUrl);
            //console.log(formName);
            //console.log(hostUrl);

            //if (parentPageDomain != "") {
            //    document.domain = parentPageDomain;
            //}

            //if (hostUrl == '') {
            //    document.write('<link rel="stylesheet" href="/_layouts/15/1033/styles/themable/corev15.css" />');
            //}

            if (isSmartForm) {

                document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');
                context = new SP.ClientContext.get_current();
                context.executeQueryAsync(Function.createDelegate(this, function () {

                    var web = new SP.AppContextSite(context, hostUrl).get_web();

                    user = web.get_currentUser();
                    context.load(user);
                    context.executeQueryAsync(Function.createDelegate(this, function () {

                        try {

                            var sfUrl = stripTrailingSlash(smartFormsRuntimeUrl);
                            sfUrl = stripRuntimeUrl(sfUrl);
                            var parameters = "?SPHostUrl=" + hostUrl + "&WPID=" + getQueryStringParameter("WPID") +
                                "&WPQ=" + getQueryStringParameter("WPQ") + "&WebLocaleId=" + getQueryStringParameter("WebLocaleId") +
                                "&HostLogoUrl=" + getQueryStringParameter("HostLogoUrl") + "&SPAppWebUrl=" + getQueryStringParameter("SPAppWebUrl") +
                                "&SPHostTitle=" + getQueryStringParameter("SPHostTitle") + "&SPLanguage=" + getQueryStringParameter("SPLanguage") +
                                "&SmartFormsUrl=" + sfUrl;

                            var isFormOrView = "/Form/";
                            if (isView.toLowerCase() == 'true' || isView == true) {
                                isFormOrView = "/View/"
                            }

                            var runtimeUrl = sfUrl + isFormOrView + formName.replace(" ", "+").replace("%20", "+");
                            if (attachSharePointParams.toLowerCase() == "true") {
                                runtimeUrl += parameters;
                            }

                            var redirectUrl = sfUrl + '/_trust/spauthorize.aspx?trust=' + user.get_userId().get_nameIdIssuer() +
                                                                                '&upn=' + user.get_email() +
                                                                                '&returnUrl=' + encodeURIComponent(runtimeUrl);
                            console.log(runtimeUrl);
                            console.log(redirectUrl);
                            $("#iframeMain").attr("src", redirectUrl);
                        }
                        catch (e) {
                            console.log(e.name + " - " + e.message);
                            $("#divErrorContainer").show();
                            $("#iframeMain").hide();
                        }

                    }), Function.createDelegate(this, onQueryFailed));
                }), Function.createDelegate(this, onQueryFailed));
            } else {
                // not a smartform
                $("#iframeMain").attr("src", iFrameUrl);
                console.log("BROWSER MESSAGING IFRAME URL: " + iFrameUrl);
            }
           
        })();

        $(document).ready(function () {
            if (window.attachEvent) {
                attachEvent("onmessage", receiveMessage);
            } else {

                window.addEventListener("message", receiveMessage, false);
            }


            // resize app part
            var resizeToIFrame = "false";
            var resizeSecondsToWait = 0;

            resizeToIFrame = getQueryStringParameter("ResizeToIFrame");
            resizeSecondsToWait = getQueryStringParameter("ResizeSecondsToWait");


            if (resizeToIFrame.toLowerCase() == "true") {
                //var timeToWait = 0;
                //timeToWait = resizeSecondsToWait * 1000;
                //setTimeout(resizeToPageSize, timeToWait);
                resizeToAppPartConfig();
            } else {
                resizeToAppPartConfig();
            }

            //resizeToPageSize();
            //sendSenderIdToIframe();

            //resizeToAppPartConfig();
            var disableScrollBars = "false";
            disableScrollBars = getQueryStringParameter("DisableScrollBars");

            if (disableScrollBars.toLowerCase() == 'true' || disableScrollBars == true) {
                $("#iframeMain").attr("scrolling", "no");
            }

        });

        function receiveMessage(e) {
            var data = e.data;
            var origin = e.origin;

            console.log("MESSAGE RECEIVED: " + data);
            console.log("MESSAGE RECEIVED ORIGIN: " + origin);

            
            //$("#iframeMain")[0].contentWindow.postMessage(e.data, "*");
            //window.parent.postMessage(data, "*");

            // check if e.origin from hostUrl - then send to iframe
            var hostUrl = stripTrailingSlash(getSPHostUrl());

            var iFrameUrl = "";
            var isSmartForm = "false";
            var smartFormsRuntimeUrl = "";
            var formName = "";
            var isView = "false";

            iFrameUrl = getQueryStringParameter("IFrameUrl");
            isSmartForm = getQueryStringParameter("IsSmartForm");
            smartFormsRuntimeUrl = getQueryStringParameter("SmartFormsRuntimeUrl");
            formName = getQueryStringParameter("FormName");
            isView = getQueryStringParameter("IsView");

            // send to parent
            // if is smartforms and smartformsruntime starts with e.origin then post to parent e.g. SharePoint host page            
            if ((isSmartForm.toLowerCase() == "true" && smartFormsRuntimeUrl.contains(e.origin)) || (isSmartForm.toLowerCase() == "false" && iFrameUrl.contains(e.origin))) {
                window.parent.postMessage(data, "*");
                return;
            }

            // sent to igrameMain
            // if is smartforms and hosturl contains e.origin meaning the message came from the page hosting this SP App then post to iframeMain
            if (isSmartForm.toLowerCase() == "true" && hostUrl.contains(e.origin)) {
                $("#iframeMain")[0].contentWindow.postMessage(e.data, "*");               
                return;
            }

        }


        function sendSenderIdToIframe() {
            var senderid = getQueryStringParameter("senderid");
            var x = {
                'message': senderid,
                'messageId': senderid,
                'messageType': "SharePointSenderId",
                'messageDateTime': Date.now(),
                'fromUrl': window.location,
            };
            $("#iframeMain")[0].contentWindow.postMessage(x, "*");
        }

        // get size of page
        // resize iframe to size of page


        // if resize to page size
        // get wait period
        // postmessage to SP to resize app part

   

        // adapted from - http://ctp-ms.blogspot.com/2013/03/resizing-app-parts-with-postmessage-in.html
        //BrowserMessaging = {
        //    senderId: '',      

        //    // The Sender Id identifies the rendered App Part.
        //    previousHeight: 0, // the height
        //    minHeight: 0,      // the minimal allowed height
        //    firstResize: true, // On the first call of the resize the App Part might be
        //    // already too small for the content, so force to resize.

        //    init: function () {
        //        // parse the URL parameters and get the Sender Id

        //        this.senderId = getQueryStringParameter("senderid");

        //        // find the height of the app part, uses it as the minimal allowed height
        //        this.previousHeight = this.minHeight = $('body').height();

        //        this.adjustSize();
        //    },

        //    adjustSize: function () {
        //        // Post the request to resize the App Part, but just if has to make a resize

        //        var step = 30, // the recommended increment step is of 30px. Source:
        //                       // http://msdn.microsoft.com/en-us/library/jj220046.aspx
        //            width = $('body').width(),        // the App Part width
        //            height = $('body').height(),  // the App Part height
        //                                              // (now it's 7px more than the body)
        //            newHeight,                        // the new App Part height
        //            contentHeight = $('#content').height(),
        //            resizeMessage =
        //                '<message senderId={Sender_ID}>resize({Width}, {Height})</message>';

        //        // if the content height is smaller than the App Part's height,
        //        // shrink the app part, but just until the minimal allowed height
        //        if (contentHeight < height - step && contentHeight >= this.minHeight) {
        //            height = contentHeight;
        //        }

        //        // if the content is bigger or smaller then the App Part
        //        // (or is the first resize)
        //        if (this.previousHeight !== height || this.firstResize === true) {
        //            // perform the resizing

        //            // define the new height within the given increment
        //            newHeight = Math.floor(height / step) * step +
        //                step * Math.ceil((height / step) - Math.floor(height / step));

        //            // set the parameters
        //            resizeMessage = resizeMessage.replace("{Sender_ID}", this.senderId);
        //            resizeMessage = resizeMessage.replace("{Height}", newHeight);
        //            resizeMessage = resizeMessage.replace("{Width}", width);
        //            // we are not changing the width here, but we could

        //            // post the message
        //            window.parent.postMessage(resizeMessage, "*");

        //            // memorize the height
        //            this.previousHeight = newHeight;

        //            // further resizes are not the first ones
        //            this.firstResize = false;
        //        }
        //    },



            

        //}

        // 

        // resizes the iframe to the size of the app part
        function resizeToAppPartConfig() {
            var apWidth = $('body').width();
            var apHeight = $('body').height();

            //resizeToAppPart = "false",
            //resizeToAppPart = getQueryStringParameter("ResizeToAppPart"),               

            $("#iframeMain").attr("height", apHeight);
            $("#iframeMain").attr("width", apWidth);
        }

        function resizeToPageSize() {
            var step = 30; // the recommended increment step is of 30px. Source:
               // http://msdn.microsoft.com/en-us/library/jj220046.aspx
            var apWidth = $('body').width();
            var width = $('body').width();        // the App Part width
            var height = $('#iframeMain').prop("scrollHeight");  // the App Part height

            var senderid = getQueryStringParameter("senderid");
            //var contentHeight = $('#content').height();
            var resizeMessage = '<message senderId={Sender_ID}>resize({Width}, {Height})</message>';

            // if the content height is smaller than the App Part's height,
            // shrink the app part, but just until the minimal allowed height
            //if (contentHeight < height - step && contentHeight >= this.minHeight) {
            //    height = contentHeight;
            //}


            // define the new height within the given increment
            var newHeight = Math.floor(height / step) * step +
                step * Math.ceil((height / step) - Math.floor(height / step));

            // set the parameters
            resizeMessage = resizeMessage.replace("{Sender_ID}", senderid);
            resizeMessage = resizeMessage.replace("{Height}", newHeight);
            resizeMessage = resizeMessage.replace("{Width}", width);
            // we are not changing the width here, but we could

            // post the message
            window.parent.postMessage(resizeMessage, "*");

        }

        



    </script>

</head>
<body style="margin:0;padding:0">
    <div class="fullscreen">
        <div id="divErrorContainer" style="margin: 23px 0px 0px 23px; width: 100%; display: none;">

            <table>
                <tbody>
                    <tr>
                        <td nowrap="" colspan="2">
                            <h1 style="margin-bottom: 0px;">Configuration Information</h1>
                        </td>
                    </tr>
                    <tr style="height: 10px;">
                        <td nowrap=""></td>
                    </tr>
                    <tr>
                        <td style="width: 20px;"></td>
                        <td nowrap="">
                            <h3>The K2 for SharePoint application has not been configured.<br>Navigate to Site Contents &gt; K2 for SharePoint to configure all required settings.</h3>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <iframe id="iframeMain" src="about:blank"></iframe>
    </div>
</body>
</html>
