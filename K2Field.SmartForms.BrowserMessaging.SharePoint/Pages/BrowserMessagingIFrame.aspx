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
        <script src="../Scripts/App.js"></script>
    <script type="text/javascript">
        //'use strict';

        var hostUrl = stripTrailingSlash(getSPHostUrl());
        document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');

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
