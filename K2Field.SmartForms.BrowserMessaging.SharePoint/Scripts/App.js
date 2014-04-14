'use strict';

var context = SP.ClientContext.get_current();
var user = context.get_web().get_currentUser();

var enableDebug = false;
var rebroadcastStrings = false;

// This code runs when the DOM is ready and creates a context object which is needed to use the SharePoint object model
$(document).ready(function () {


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

    if (isSmartForm.toLowerCase() == "true") {

        //document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');
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
                    //console.log(runtimeUrl);
                    //console.log(redirectUrl);
                    $("#iframeMain").attr("src", redirectUrl);

                    //if (iFrameUrl.length > 0) {
                    //    var redirectUrl = sfUrl + '/_trust/spauthorize.aspx?trust=' + user.get_userId().get_nameIdIssuer() +
                    //                                                    '&upn=' + user.get_email() +
                    //                                                    '&returnUrl=' + encodeURIComponent(iFrameUrl);
                    //    //console.log(runtimeUrl);
                    //    //console.log(redirectUrl);
                    //    $("#iframeMain").attr("src", redirectUrl);
                    //} else {
                       
                    //}


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

    $("#iframeMain").attr("scrolling", "auto");
    $("#iframeMain").attr("border", "0");

    //var disableScrollBars = "false";
    //disableScrollBars = getQueryStringParameter("DisableScrollBars");

    //if (disableScrollBars.toLowerCase() == 'true' || disableScrollBars == true) {
    //    $("#iframeMain").attr("scrolling", "no");
    //    $("#iframeMain").css("overflow", "hidden");
    //} else {
    //    $("#iframeMain").attr("scrolling", "auto");
    //    $("#iframeMain").css("overflow", "scroll");
    //}


    if (window.attachEvent) {
        attachEvent("onmessage", receiveMessage);
    } else {

        window.addEventListener("message", receiveMessage, false);
    }
    //document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');
});

// used to track messages sent through this app
var k2bmSent = new Array();

//yourVariable !== null && typeof yourVariable === 'object'




// FEATURE REQUESTS
// Solve echo issue
// pre defined messages e.g. resize, replace url
// make passing standard sharepoint query string values optional
// can we pass page QS to form?


// Code adapted from the K2 SmartForm Viewer app part

function receiveMessage(e) {
    var data = e.data;
    var origin = e.origin;

    var d = JSON.parse(data);


    //console.log("MESSAGE RECEIVED: " + data);
    //console.log("MESSAGE RECEIVED ORIGIN: " + origin);

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
     //if is smartforms and smartformsruntime starts with e.origin then post to parent e.g. SharePoint host page            
    if ((isSmartForm.toLowerCase() == "true" && smartFormsRuntimeUrl.contains(e.origin)) || (isSmartForm.toLowerCase() == "false" && iFrameUrl.contains(e.origin))) {

        // check if message is a predefined browser messaging send smartform control method
        if (d.messageType) {
            var senderid = getQueryStringParameter("senderid");
            var resizeMessage = '<message senderId={Sender_ID}>resize({Width}, {Height})</message>';
            switch (d.messageType.toLowerCase()) {
                case "apppartresize":
                    resizeMessage = resizeMessage.replace("{Sender_ID}", senderid);
                    resizeMessage = resizeMessage.replace("{Width}", d.message);
                    resizeMessage = resizeMessage.replace("{Height}", d.messageId);
                    window.parent.postMessage(resizeMessage, "*");

                    $("#iframeMain").attr("height", d.messageId);
                    $("#iframeMain").attr("width", d.message);

                    return;
                    break;
                case "apppartresizetopage":
                    resizeMessage = resizeMessage.replace("{Sender_ID}", senderid);
                    resizeMessage = resizeMessage.replace("{Width}", $(window).width());
                    resizeMessage = resizeMessage.replace("{Height}", d.messageId);
                    window.parent.postMessage(resizeMessage, "*");

                    $("#iframeMain").attr("height", d.messageId);
                    $("#iframeMain").attr("width", $(window).width());

                    return;
                    break;
            }
        }
        // if it reaches here just send as is to parent
        window.parent.postMessage(data, "*");
        k2bmSent.push(d.messageDateTime + "-" + d.fromUrl);
        return;
    }

    // sent to igrameMain
    // if is smartforms and hosturl contains e.origin meaning the message came from the page hosting this SP App then post to iframeMain 
    // - this means a page sending a message will receive an echo of it. Need more validation to stop this
    if (hostUrl.contains(e.origin)) {

        // check if this page has seen this message before - if not send to iframeMain
        var index = -1;
        index = $.inArray(d.messageDateTime + "-" + d.fromUrl, k2bmSent);
        if (index < 0) {
            $("#iframeMain")[0].contentWindow.postMessage(e.data, "*");
        } else {
            // echo message - remove from tracking array
            k2bmSent.splice(index, 1);
        }

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










// This function prepares, loads, and then executes a SharePoint query to get the current users information
function getUserName() {
    context.load(user);
    context.executeQueryAsync(onGetUserNameSuccess, onGetUserNameFail);
}

// This function is executed if the above call is successful
// It replaces the contents of the 'message' element with the user name
function onGetUserNameSuccess() {
    $('#message').text('Hello ' + user.get_title());
}

// This function is executed if the above call fails
function onGetUserNameFail(sender, args) {
    alert('Failed to get user name. Error:' + args.get_message());
}
