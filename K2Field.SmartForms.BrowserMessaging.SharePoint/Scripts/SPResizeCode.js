var spAppIFrameSenderInfo = new Array(1);
var SPAppIFramePostMsgHandler = function (e) {
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
    if (resizeWidth) {
        widthCssText = 'width:' + width + ' !important;';
    }

    var cssText = widthCssText;
    var resizeHeight = ('False' == spAppIFrameSenderInfo[senderIndex][4]);
    if (resizeHeight) {
        cssText += 'height:' + height + ' !important';
    }

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

//if (typeof window.addEventListener != 'undefined') {
//    window.addEventListener('message', SPAppIFramePostMsgHandler, false);
//}
//else if (typeof window.attachEvent != 'undefined') {
//    window.attachEvent('onmessage', SPAppIFramePostMsgHandler);
//}

spAppIFrameSenderInfo[0] = new Array("F9E3ED9D0", "g_bcbfba2a_ea1f_427a_95ea_4406c004489f", "https:\u002f\u002fk2jonno-9a17a017608bf6.sharepoint.com", "True", "True", "ctl00_ctl47_g_d4788dba_b960_4dab_9fce_c05a50a1679d");