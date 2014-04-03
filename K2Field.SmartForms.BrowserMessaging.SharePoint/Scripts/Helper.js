// Copied from the K2 SmartForm Viewer app part - Helper.js
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