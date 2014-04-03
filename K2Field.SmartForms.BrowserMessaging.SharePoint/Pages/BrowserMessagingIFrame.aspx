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

    <script type="text/javascript">
        'use strict';


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
            var isSmartForm = false;
            var smartFormsRuntimeUrl = "";
            var formName = "";

            iFrameUrl = getQueryStringParameter("IFrameUrl");
            parentPageDomain = getQueryStringParameter("ParentPageDomain");
            isSmartForm = getQueryStringParameter("IsSmartForm");
            smartFormsRuntimeUrl = getQueryStringParameter("SmartFormsRuntimeUrl");
            formName = getQueryStringParameter("FormName");

            console.log(iFrameUrl);
            console.log(parentPageDomain);
            console.log(isSmartForm);
            console.log(smartFormsRuntimeUrl);
            console.log(formName);
            console.log(hostUrl);

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
                            var runtimeUrl = sfUrl + "/Form/" + formName.replace(" ", "+") + parameters;
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
                console.log(iFrameUrl);
            }

            if (window.attachEvent) {
                attachEvent("onmessage", receiveMessage);
            } else {

                window.addEventListener("message", receiveMessage, false);
            }

        })();

        function receiveMessage(e) {
            var data = e.data;
            var origin = e.origin;

            console.log("MESSAGE RECEIVED: " + data);
            console.log("MESSAGE RECEIVED ORIGIN: " + origin);

            
            // check if e.origin from hostUrl - then send to iframe
            var hostUrl = stripTrailingSlash(getSPHostUrl());

            // if the app part receives a message from a SharePoint page then rebroadcast message to iframe on this page
            if (origin.startsWith(hostUrl)) {
                $("#iframeMain")[0].contentWindow.postMessage(e.data, "*");
            } else {
                // if the iframe in this app part posts a message to this page then rebroadcast to parent page i.e. the SharePoint page that contains this app part
                window.parent.postMessage(data, "*");
            }
        }


        // get size of page
        // resize iframe to size of page


        // if resize to page size
        // get wait period
        // postmessage to SP to resize app part

        function reSizeIframe() {


        }


    </script>

</head>
<body>
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
        <iframe width="750" height="450" id="iframeMain" src="about:blank" scrolling="no"></iframe>
    </div>
</body>
</html>
