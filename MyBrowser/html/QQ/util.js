function getImageUrl() {
    var a = window.location.host, b = "", c = getImageElement();
    return c && (b = "m.letv.com" == a ? c.style.backgroundImage.replace("url(", "").replace(")", "") : "m.tv.sohu.com" == a ? c.style.background.replace("url(", "").replace(")", "").replace(/(\s*$)/g, "") : "infoapp.3g.qq.com" == a ? c.poster : c.src), b
}
function getImageElement() {
    var b, a = window.location.host;
    return "m.v.qq.com" == a ? b = document.getElementsByClassName("tvp_poster_img")[0] : "v.youku.com" == a ? b = document.getElementsByClassName("x-video-poster")[0].firstChild : "www.tudou.com" == a ? b = document.getElementsByClassName("poster")[0].firstChild : "m.iqiyi.com" == a ? b = document.getElementById("player-posterimg") : "m.letv.com" == a ? b = document.getElementsByClassName("hv_play_poster")[0] : "m.tv.sohu.com" == a ? b = document.getElementsByClassName("cover svp_poster_right")[0] : "infoapp.3g.qq.com" == a && (b = document.getElementById("single-video").childNodes[0].childNodes[0]), b
}
function getImageTop() {
    var a = getImageElement();
    return a.getBoundingClientRect().top
}
function getImageHeight() {
    var a = getImageElement();
    return a.getBoundingClientRect().height
}

function getVideoUrl() {
    var b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, a = 0;
    if ("undefined" != typeof window.mttPlayingIndex && window.mttPlayingIndex >= 0 && (a = window.mttPlayingIndex), b = null, c = document, d = c.getElementsByTagName("video"), e = d.length, e > 0 && e > a && (f = d[a], b = f.currentSrc, (null == b || b.length <= 0) && (b = f.getAttribute("src")), (null == b || b.length <= 0) && (g = f.getElementsByTagName("source"), g.length > 0 && (b = g[0].getAttribute("src"))), (null == b || b.length <= 0) && (h = f.innerHTML, i = /\bhttps?:\/\/[a-zA-Z0-9\-.]+(?::(\d+))?(?:(?:\/[a-zA-Z0-9\-._?,'+\&%$=~*!():@\\]*)+)?/, b = i.exec(h))), null != b && b.length > 0)
        return b;
    if (j = c.URL, k = /(pptv|mp\.weixin\.qq)\.com/i, k.test(j))
        for (l = c.getElementsByTagName("iframe"), m = l.length, n = /(pptv|v\.qq)\.com/i, o = 0; m > o; o++)
            if (p = l[o], "undefined" != typeof p.src && n.test(p.src) && (q = p.contentDocument, r = q.getElementsByTagName("video"), s = r.length, s > 0 && s > a)) {
                if (t = r[a], b = t.currentSrc, null != b && b.length > 0)break;
                if (b = t.getAttribute("src"), null != b && b.length > 0)break
            }
    return b
}


function SetTextSize(textSize) {
    switch (textSize) {
        case 0:
            document.getElementsByTagName("body")[0].style.webkitTextSizeAdjust = "80%";
            break;
        case 1:
            document.getElementsByTagName("body")[0].style.webkitTextSizeAdjust = "100%";
            break;
        case 2:
            document.getElementsByTagName("body")[0].style.webkitTextSizeAdjust = "120%";
            break;
        case 3:
            document.getElementsByTagName("body")[0].style.webkitTextSizeAdjust = "140%";
            break;
        case 4:
            document.getElementsByTagName("body")[0].style.webkitTextSizeAdjust = "160%";
            break;
        default:
            break
    }
}
function WebkitTouchCalloutEnable(enable) {
    switch (enable) {
        case 0:
            document.body.style.webkitTouchCallout = "none";
            break;
        case 1:
            document.body.style.webkitTouchCallout = "yes";
            break;
        default:
            break
    }
}
function SetHTMLCharset() {
    var element = document.createElement("meta");
    element.httpEquiv = "content-type";
    element.content = "text/html; charset=GBK";
    var head = document.getElementsByTagName("head")[0];
    head.appendChild(element)
}
function SetPageScale(pageScale) {
    var element = document.createElement("meta");
    element.name = "viewport";
    element.content = "minimum-scale=0; maximum-scale=10; initial-scale=";
    element.content = element.content + pageScale;
    var head = document.getElementsByTagName("head")[0];
    head.appendChild(element)
}
function getPosition(element) {
    var xPosition = 0;
    var yPosition = 0;
    while (element) {
        xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
        element = element.offsetParent
    }
    return {x: xPosition, y: yPosition}
}
function getPickedImgForShare() {
    var elements = document.getElementsByTagName("img");
    var url = "";
    for (var i = 0; i < elements.length; i++) {
        var ele = elements[i];
        var width = ele.width;
        var height = ele.height;
        var transform = ele.parentNode.style["webkitTransform"];
        if (transform) {
            var matches = transform.match(/translate3d\((.+)px/);
            if (matches.length > 1) {
                if (parseInt(matches[1]) != 0) {
                    continue
                }
            }
        }
        var parentE = ele.parentNode;
        if (width >= 100 && height >= 90) {
            if (parentE) {
                if (isImageVisible(ele) && isImageVisible(parentE)) {
                    url = ele.src;
                    break
                }
            }
        }
    }
    return url
}
function isImageVisible(element) {
    return (element.style.display != "none" && element.style.visibility != "hidden")
}
function GetHTMLElementsAddPoint(x, y) {
    var e = document.elementFromPoint(x, y);
    while (e) {
        if (e.tagName) {
            if ((e.tagName == "BODY") || (e.tagName == "body") || (e.tagName == "HTML") || (e.tagName == "html")) {
                return " "
            } else {
                if ((e.tagName == "A") || (e.tagName == "a")) {
                    return e.href
                }
            }
            e = e.parentNode
        } else {
            break
        }
    }
    return " "
}
function GetHTMLElementAnchorTextAtPoint(x, y) {
    var e = document.elementFromPoint(x, y);
    while (e) {
        if (e.tagName) {
            if ((e.tagName == "BODY") || (e.tagName == "body") || (e.tagName == "HTML") || (e.tagName == "html")) {
                return " "
            } else {
                if ((e.tagName == "A") || (e.tagName == "a")) {
                    return e.innerHTML
                }
            }
            e = e.parentNode
        } else {
            break
        }
    }
    return " "
}
function getImageTagSrcFromPoint(x, y) {
    var e = document.elementFromPoint(x, y);
    var hasImg = false;
    if (e && (e.tagName == "img" || e.tagName == "IMG")) {
        return e.src
    } else {
        return ""
    }
}
function documentCoordinateToViewportCoordinate(x, y) {
    var coord = new Object();
    coord.x = x - window.pageXOffset;
    coord.y = y - window.pageYOffset;
    return coord
}
function viewportCoordinateToDocumentCoordinate(x, y) {
    var coord = new Object();
    coord.x = x + window.pageXOffset;
    coord.y = y + window.pageYOffset;
    return coord
}
function elementFromPointIsUsingViewPortCoordinates() {
    if (window.pageYOffset > 0) {
        return (window.document.elementFromPoint(0, window.pageYOffset + window.innerHeight - 1) == null)
    } else {
        if (window.pageXOffset > 0) {
            return (window.document.elementFromPoint(window.pageXOffset + window.innerWidth - 1, 0) == null)
        }
    }
    return false
}
function elementFromDocumentPoint(x, y) {
    if (elementFromPointIsUsingViewPortCoordinates()) {
        var coord = documentCoordinateToViewportCoordinate(x, y);
        return window.document.elementFromPoint(coord.x, coord.y)
    } else {
        return window.document.elementFromPoint(x, y)
    }
}
function elementFromViewportPoint(x, y) {
    if (elementFromPointIsUsingViewPortCoordinates()) {
        return window.document.elementFromPoint(x, y)
    } else {
        var coord = viewportCoordinateToDocumentCoordinate(x, y);
        return window.document.elementFromPoint(coord.x, coord.y)
    }
}
function getRectForSelectedText() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rect = range.getBoundingClientRect();
    return "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}"
}
function getTextAndRectForALink() {
    var all_links = document.getElementsByTagName("a");
    for (var i = 0, max = all_links.length; i < max; i++) {
        var link = all_links[i];
        var rect = link.getBoundingClientRect();
        if (link.innerText && link.href && rect.width && rect.height) {
            return link.innerText + "#####mtt$$$$$" + "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}"
        }
    }
};