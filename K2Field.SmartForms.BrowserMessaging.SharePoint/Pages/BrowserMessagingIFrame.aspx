<%@ Page language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>

    <head>
    <title>Browser Messaging IFrame</title>

    <script src="../Scripts/jquery-1.8.2.min.js" type="text/javascript"></script>
    <script src="/_layouts/15/MicrosoftAjax.js" type="text/javascript"></script>
    <script src="/_layouts/15/sp.runtime.js" type="text/javascript"></script>
    <link href="https://portal.denallix.com/_layouts/15/defaultcss.ashx" rel="stylesheet"><script src="/_layouts/15/sp.js" type="text/javascript"></script>
    <script src="../Scripts/Helpers.js" type="text/javascript"></script>

    <script type="text/javascript">
        'use strict';

        // Set the style of the client web part page to be consistent with the host web.
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

            // sets page domain to parent domain to enable postMessage across apps - hopefully
            if (parentPageDomain != "") {
                document.domain = parentPageDomain;
            }

            //if (hostUrl == '') {
            //    document.write('<link rel="stylesheet" href="/_layouts/15/1033/styles/themable/corev15.css" />');
            //}

            if (isSmartForm) {

                document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');
                context = new SP.ClientContext.get_current();
                context.executeQueryAsync(Function.createDelegate(this, function () {

                    var web = new SP.AppContextSite(context, hostUrl).get_web();

                    user = web.get_currentUser();
                    listColl = web.get_lists();
                    context.load(user);
//                    context.load(listColl);
                    context.executeQueryAsync(Function.createDelegate(this, function () {

                        try {

                            var sfUrl = stripTrailingSlash(settingItems.itemAt(0).get_item('Value'));
                            sfUrl = stripRuntimeUrl(sfUrl);
                            var parameters = "?SPHostUrl=" + hostUrl + "&WPID=" + getQueryStringParameter("WPID") +
                                "&WPQ=" + getQueryStringParameter("WPQ") + "&WebLocaleId=" + getQueryStringParameter("WebLocaleId") +
                                "&HostLogoUrl=" + getQueryStringParameter("HostLogoUrl") + "&SPAppWebUrl=" + getQueryStringParameter("SPAppWebUrl") +
                                "&SPHostTitle=" + getQueryStringParameter("SPHostTitle") + "&SPLanguage=" + getQueryStringParameter("SPLanguage") +
                                "&SmartFormsUrl=" + sfUrl;
                            var runtimeUrl = sfUrl + "/Form/" + getQueryStringParameter("FormName").replace(" ", "+") + parameters;
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

            //$(window).trigger("browserMessageReceived", data);
            console.log("MESSAGE RECEIVED: " + data);

            // repost message to parent
            window.parent.postMessage(data);

        }


        //<iframe width="750" height="500" id="g_a6316b3d_66eb_4765_bd39_7ff041ea0627" src="https://portal.denallix.com/_layouts/15/appredirect.aspx?redirect_uri=https%3A%2F%2Fapp%2D6aa66829c0130e%2Edenallixapps%2Ecom%2FK2forSharePoint%2FPages%2FFormViewerAppPart%2Easpx%3FSPHostUrl%3Dhttps%253A%252F%252Fportal%252Edenallix%252Ecom%26SPHostTitle%3DPortal%26SPAppWebUrl%3Dhttps%253A%252F%252Fapp%252D6aa66829c0130e%252Edenallixapps%252Ecom%252FK2forSharePoint%26SPLanguage%3Den%252DUS%26SPClientTag%3D0%26SPProductNumber%3D15%252E0%252E4481%252E1005%26FormName%3DBroadcasttest%26WPID%3Dg%255F6c1de00c%255F376f%255F4edd%255F8d91%255Fe42e60a84ad6%26WPQ%3Dctl00%255Fctl33%255Fg%255F6c1de00c%255F376f%255F4edd%255F8d91%255Fe42e60a84ad6%26WebLocaleId%3D1033%26HostLogoUrl%3Dhttps%253A%252F%252Fportal%252Edenallix%252Ecom%252F%255Flayouts%252F15%252Fimages%252Fsiteicon%252Epng%26SenderId%3D0A47E4E74&amp;client_id=i%3A0i%2Et%7Cms%2Esp%2Eext%7C3308eaff%2Dd056%2D4a32%2D9b1d%2D563f81bf06f9%405c89ac77%2De67f%2D4752%2D8edc%2D9714ba9f45d0" frameborder="0"></iframe>
        //    <Content Type="html" Src="~appWebUrl/Pages/FormViewerAppPart.aspx?{StandardTokens}&amp;FormName=_FormName_&amp;WPID=_WPID_&amp;WPQ=_WPQ_&amp;WebLocaleId=_WebLocaleId_&amp;HostLogoUrl={HostLogoUrl}" />

        //function getQueryStringParameter(paramToRetrieve) {
        //    var params;
        //    var strParams;

        //    params = document.URL.toLowerCase().split("?")[1].split("&");
        //    strParams = "";
        //    for (var i = 0; i < params.length; i = i + 1) {
        //        var singleParam = params[i].split("=");
        //        if (singleParam[0] == paramToRetrieve.toLowerCase())
        //            return singleParam[1];
        //    }
        //}


        // SmartForm Viewer Helper.js
        var SourceCode;

        function doesStringEndWith(myString, stringCheck) {

            return (myString.lastIndexOf(stringCheck) === myString.length - stringCheck.length) > 0;
        }

        function stripTrailingSlash(url) {

            if (url.endsWith('/')) {

                url = url.substr(0, url.length - 1);
            }

            return url;
        }

        function getRootUrl(url) {
            return url.toString().replace(/^(.*\/\/[^\/?#]*).*$/, "$1");
        }

        function stripRuntimeUrl(url) {
            var sfRuntimeUrl = url;

            if (url.toLowerCase().endsWith("runtime/runtime")) {
                sfRuntimeUrl = url.substring(0, url.length - 8);
            }

            return sfRuntimeUrl;
        }

        function getQueryStringParameter(paramToRetrieve) {

            var queryString;
            var paramSets;
            var params;
            var param;

            paramSets = decodeURIComponent(document.URL).split("?");

            for (var j = 0; j < paramSets.length; j = j + 1) {
                if (paramSets[j].indexOf("&amp;") != -1) {
                    params = paramSets[j].split("&amp;");
                }
                else {
                    params = paramSets[j].split("&");
                }

                for (var i = 0; i < params.length; i = i + 1) {
                    if (params[i].indexOf("=") != -1) {
                        param = params[i].split("=");

                        if (param[0].toLowerCase() == paramToRetrieve.toLowerCase()) {
                            return param[1];
                        }
                    }
                }
            }
        }

        function getSPHostUrl() {

            var spHostUrl = getQueryStringParameter("SPSiteURL");

            if (spHostUrl == undefined) {
                return getQueryStringParameter("SPHostUrl");
            }

            return spHostUrl;
        }

        function showMessage(message, bSticky, spinnerOn) {

            if (spinnerOn) {

                return SP.UI.Notify.addNotification("<img src='/_layouts/15/images/loadingcirclests16.gif?rev=23' style='vertical-align:bottom; display:inline-block; margin-" + (document.documentElement.dir == "rtl" ? "left" : "right") + ":2px;' />&nbsp;<span style='vertical-align:top;'>" + message + "</span>", bSticky);
            }
            else {

                return SP.UI.Notify.addNotification(message, bSticky);
            }
        }

        function removeMessage(messageid) {

            SP.UI.Notify.removeNotification(messageid);
        }

        if (typeof String.prototype.endsWith !== 'function') {

            String.prototype.endsWith = function (suffix) {

                return this.indexOf(suffix, this.length - suffix.length) !== -1;
            };
        }

        if (typeof String.prototype.startsWith !== 'function') {

            String.prototype.startsWith = function (str) {

                return this.indexOf(str) == 0;
            };
        }

        if (typeof String.prototype.contains !== 'function') {

            String.prototype.contains = function (str) {

                return this.indexOf(str) >= 0;
            };
        }

        function onQueryFailed(sender, args) {

            var nid = SP.UI.Notify.addNotification(args.get_message(), false);
        }


    </script>

<%--        <script type="text/javascript">
            'use strict';

            // Set the style of the client web part page to be consistent with the host web.
            (function () {

                var hostUrl = stripTrailingSlash(getSPHostUrl());

                if (hostUrl == '') {

                    document.write('<link rel="stylesheet" href="/_layouts/15/1033/styles/themable/corev15.css" />');
                }
                else {

                    var context;
                    var user;
                    var listColl;
                    var settingItems;
                    var listFound = false;

                    document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');
                    context = new SP.ClientContext.get_current();
                    context.executeQueryAsync(Function.createDelegate(this, function () {

                        var web = new SP.AppContextSite(context, hostUrl).get_web();

                        user = web.get_currentUser();
                        listColl = web.get_lists();
                        context.load(user);
                        context.load(listColl);
                        context.executeQueryAsync(Function.createDelegate(this, function () {

                            var listEnumerator = listColl.getEnumerator();

                            while (listEnumerator.moveNext()) {

                                var list = listEnumerator.get_current();

                                if (list.get_title() === settingsListTitle) {

                                    var query = new SP.CamlQuery();

                                    query.set_viewXml("<View><Query><Where><Contains><FieldRef Name='Title'/><Value Type='Text'>K2_Designer_URL</Value></Contains></Where></Query></View>");
                                    settingItems = list.getItems(query);
                                    context.load(settingItems);
                                    context.executeQueryAsync(Function.createDelegate(this, function () {

                                        try {

                                            var sfUrl = stripTrailingSlash(settingItems.itemAt(0).get_item('Value'));
                                            sfUrl = stripRuntimeUrl(sfUrl);
                                            var parameters = "?SPHostUrl=" + hostUrl + "&WPID=" + getQueryStringParameter("WPID") +
                                                "&WPQ=" + getQueryStringParameter("WPQ") + "&WebLocaleId=" + getQueryStringParameter("WebLocaleId") +
                                                "&HostLogoUrl=" + getQueryStringParameter("HostLogoUrl") + "&SPAppWebUrl=" + getQueryStringParameter("SPAppWebUrl") +
                                                "&SPHostTitle=" + getQueryStringParameter("SPHostTitle") + "&SPLanguage=" + getQueryStringParameter("SPLanguage") +
                                                "&SmartFormsUrl=" + sfUrl;
                                            var runtimeUrl = sfUrl + "/Form/" + getQueryStringParameter("FormName").replace(" ", "+") + parameters;
                                            var redirectUrl = sfUrl + '/_trust/spauthorize.aspx?trust=' + user.get_userId().get_nameIdIssuer() +
                                                                                              '&upn=' + user.get_email() +
                                                                                              '&returnUrl=' + encodeURIComponent(runtimeUrl);

                                            $("#iframeMain").attr("src", redirectUrl);
                                        }
                                        catch (e) {

                                            $("#divErrorContainer").show();
                                            $("#iframeMain").hide();
                                        }
                                    }));

                                    break;
                                }
                            }

                        }), Function.createDelegate(this, onQueryFailed));

                    }), Function.createDelegate(this, onQueryFailed));
                }
            })();

    </script>--%>
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
        <iframe width="750" height="450" id="iframeMain" src="https://k2.denallix.com:443/Runtime/_trust/spauthorize.aspx?trust=urn:office:idp:activedirectory&amp;upn=Administrator@denallix.com&amp;returnUrl=https%3A%2F%2Fk2.denallix.com%3A443%2FRuntime%2FForm%2FBroadcasttest%3FSPHostUrl%3Dhttps%3A%2F%2Fportal.denallix.com%26WPID%3Dg_6c1de00c_376f_4edd_8d91_e42e60a84ad6%26WPQ%3Dctl00_ctl33_g_6c1de00c_376f_4edd_8d91_e42e60a84ad6%26WebLocaleId%3D1033%26HostLogoUrl%3Dhttps%3A%2F%2Fportal.denallix.com%2F_layouts%2F15%2Fimages%2Fsiteicon.png%26SPAppWebUrl%3Dhttps%3A%2F%2Fapp-6aa66829c0130e.denallixapps.com%2FK2forSharePoint%26SPHostTitle%3DPortal%26SPLanguage%3Den-US%26SmartFormsUrl%3Dhttps%3A%2F%2Fk2.denallix.com%3A443%2FRuntime" scrolling="no"></iframe>
    </div>
</body>
</html>
