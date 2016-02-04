function RCGetHTMLElementsAtPoint(x, y) {
    var tags = "";
    var e;
    var offset = 0;
    while ((tags.search(",(A|IMG),") < 0) && (offset < 20)) {
        tags = ",";
        e = document.elementFromPoint(x, y + offset);
        while (e) {
            if (e.tagName) {
                tags += e.tagName + ',';
            }
            e = e.parentNode;
        }
        if (tags.search(",(A|IMG),") < 0) {
            e = document.elementFromPoint(x, y - offset);
            while (e) {
                if (e.tagName) {
                    tags += e.tagName + ',';
                }
                e = e.parentNode;
            }
        }

        offset++;
    }
    return tags;
}

function RCGetImgSrcAtPoint(x, y) {
    var tags = ",";
    var e = document.elementFromPoint(x, y);
    if (e && (e.tagName == "img" || e.tagName == "IMG")) {
        return e.src;
    }
    else {
        return "";
    }
}

function RCGetLinkSRCAtPoint(x, y) {
    var tags = "";
    var e = "";
    var offset = 0;
    while ((tags.length == 0) && (offset < 20)) {
        e = document.elementFromPoint(x, y + offset);
        while (e) {
            if (e.src) {
                tags += e.src;
                break;
            }
            e = e.parentNode;
        }
        if (tags.length == 0) {
            e = document.elementFromPoint(x, y - offset);
            while (e) {
                if (e.src) {
                    tags += e.src;
                    break;
                }
                e = e.parentNode;
            }
        }
        offset++;
    }
    return tags;
}

function RCGetLinkHREFAtPoint(x, y) {
    var tags = "";
    var e = "";
    var offset = 0;
    while ((tags.length == 0) && (offset < 20)) {
        e = document.elementFromPoint(x, y + offset);
        while (e) {
            if (e.href) {
                tags += e.href;
                break;
            }
            e = e.parentNode;
        }
        if (tags.length == 0) {
            e = document.elementFromPoint(x, y - offset);
            while (e) {
                if (e.href) {
                    tags += e.href;
                    break;
                }
                e = e.parentNode;
            }
        }
        offset++;
    }
    return tags;
}


function stopVideo() {
    var videos = document.querySelectorAll("video");
    var result = 'not found';
    for (var i = videos.length - 1; i >= 0; i--) {
        videos[i].pause();
        result = video.GetURL();
    }
    ;
    return result;
}


/////////////////////////////
function CPos(x, y) {
    this.x = x;
    this.y = y;
}

function GetObjPos(ATarget) {
    var target = ATarget;
    var pos = new CPos(target.offsetLeft, target.offsetTop);

    target = target.offsetParent;
    while (target) {
        pos.x += target.offsetLeft;
        pos.y += target.offsetTop;
        target = target.offsetParent;
    }
    return pos.x + ',' + pos.y;
}
function getAposByUrl(url) {
    var as = document.getElementsByTagName('A');
    for (var i = 0; i < as.length; i++) {
        if (as[i].href == url) {
            return GetObjPos(as[i]);
        }

    }
    return '';

}


//获取网站icon
function getAppIcon() {
    var iconName = "";
    var links = document.getElementsByTagName("link");

    var link = {};
    for (var i = 0; i < links.length; i++) {
        link = links[i];
        if (link.rel == "apple-touch-icon") {
            iconName = link.href;
            break;
        } else if (link.rel == "apple-touch-icon-precomposed") {
            iconName = link.href;
            break;
        }
    }
    return iconName;
}


function removeAd(rc_ele) {
    var reg1 = /\d+px/;
    var reg2 = /\d+%/;
    var childs = rc_ele.childNodes;
    for (var i = 0; i < childs.length; i++) {
        if (childs[i].nodeType == 1 && typeof(childs[i].style["top"]) != "undefined" && (reg1.test(childs[i].style["top"]) || reg2.test(childs[i].style["top"])) && typeof(childs[i].style["position"]) != "undefined" && childs[i].style["position"] != "static") {
            for (var z = 1; z <= 3; z++) {
                if (typeof(childs[i + z]) != "undefined" && childs[i].nodeName == childs[i + z].nodeName) {
                    if (childs[i].style["position"] == childs[i + z].style["position"] && childs[i].style["top"] == childs[i + z].style["top"]) {
                        rc_ele.removeChild(childs[i + z]);
                        rc_ele.removeChild(childs[i]);
                        return;
                    }
                }
            }
        } else if (childs[i].nodeType == 1 && typeof(childs[i].style["bottom"]) != "undefined" && (reg1.test(childs[i].style["bottom"]) || reg2.test(childs[i].style["bottom"])) && typeof(childs[i].style["position"]) != "undefined" && childs[i].style["position"] != "static") {
            for (var j = 1; j <= 3; j++) {
                if (typeof(childs[i + j]) != "undefined" && childs[i].nodeName == childs[i + j].nodeName) {
                    if (childs[i].style["position"] == childs[i + j].style["position"] && childs[i].style["bottom"] == childs[i + j].style["bottom"]) {
                        rc_ele.removeChild(childs[i + j]);
                        rc_ele.removeChild(childs[i]);
                        return;
                    }
                }
            }
        } else if (childs[i].nodeType == 1 && childs[i].childNodes.length > 0 && childs[i].nodeName.toLowerCase() != "iframe") {
            removeAd(childs[i]);
        }
    }
}

