//测试函数，如果这个函数可以正常的弹出敬告框，说明所有的js都被正确的解析了
function MTT_ParseCorrectTest() {
    alert("all func is right!");
}

//设置字体大小
function MTT_SetTextSize(textSize) {

    var metas = document.getElementsByTagName('meta');

    for (var i = 0; i < metas.length; i++) {
        var oneMeta = metas[i];
        if (oneMeta.name == 'x5-text-size-adjust' && oneMeta.content == 'enable') {
            return;
        }
    }

    switch (textSize) {
        case 0:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '80%';
            break;
        case 1:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '90%';
            break;
        case 2:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '100%';
            break;
        case 3:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '110%';
            break;
        case 4:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '120%';
            break;
        case 5:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '130%';
            break;
        case 6:
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '140%';
            break;
        default:
            break;
    }
}


//设置精品阅读 正文字体
function MTT_SetCoolReadTextSize(textSize) {

    var percent = '100%';

    switch (textSize) {
        case 0:
            percent = '80%';
            break;
        case 1:
            percent = '100%';
            break;
        case 2:
            percent = '120%';
            break;
        case 3:
            percent = '140%';
            break;
        case 4:
            percent = '160%';
            break;
        default:
            break;
    }

    var articleDivs = document.getElementsByClassName('article');

    if (articleDivs) {
        articleDivs[0].style.webkitTextSizeAdjust = percent;
    }

}

//关闭弹出框
function MTT_WebkitTouchCalloutEnable(enable) {
    switch (enable) {
        case 0:
            document.body.style.webkitTouchCallout = 'none';
            break;
        case 1:
            document.body.style.webkitTouchCallout = 'yes';
            break;
        default:
            break;
    }
}

//设置编码
function MTT_SetHTMLCharset() {
    var element = document.createElement('meta');
    element.httpEquiv = "content-type";
    element.content = "text/html; charset=GBK";
    var head = document.getElementsByTagName('head')[0];
    head.appendChild(element);
}

//设置页面的缩放
function MTT_SetPageScale(pageScale) {
    var element = document.createElement('meta');
    element.name = "viewport";
    element.content = "minimum-scale=0; maximum-scale=10; initial-scale=";

    element.content = element.content + pageScale;

    var head = document.getElementsByTagName('head')[0];
    head.appendChild(element);
}

function MTT_getPosition(element) {
    var xPosition = 0;
    var yPosition = 0;

    while (element) {
        xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
        element = element.offsetParent;
    }
    return {x: xPosition, y: yPosition};
}

// 取当前页面最合适的图片的src url。
function MTT_getPickedImgForShare() {
    var elements = document.getElementsByTagName('img');
    var url = "";
    for (var i = 0; i < elements.length; i++) {
        var ele = elements[i];

        var width = ele.width;
        var height = ele.height;

        // fix bug
        // 参见m.app111.com/b/
        // 该网站的壁纸有预加载的策略，每次加载三张壁纸，除中间的可见的一张外，其余两张都是用translate3d做了平移，下面的代码是为了取出屏幕上可见的第一张壁纸
        var transform = ele.parentNode.style['webkitTransform'];
//        if(transform)
//        {
//            var matches = transform.match(/translate3d\((.+)px/);
//              if (matches.length > 1)
//              {
//                  if (parseInt(matches[1]) != 0)
//                  {
//                      continue;
//                  }
//              }
//        }

        var parentE = ele.parentNode;
        if (width >= 100 && height >= 90)//尺寸门槛
        {
            if (parentE) {
                if (MTT_isImageVisible(ele) && MTT_isImageVisible(parentE))// 排除隐藏的,暂时只查到它老爸。
                {
                    url = ele.src;
                    break;
                }
            }
        }
    }
    return url;
}

function MTT_isImageVisible(element) {
    return (element.style.display != 'none' && element.style.visibility != "hidden");
}

//获得坐标对应的tag值
function MTT_GetHTMLElementsAddPoint(x, y) {
    var e = document.elementFromPoint(x, y);
    while (e) {
        if (e.tagName) {
            if ((e.tagName == "BODY") || (e.tagName == "body") || (e.tagName == "HTML") || (e.tagName == "html")) {
                return " ";
            }
            else if ((e.tagName == "A") || (e.tagName == "a")) {
                return e.href;
            }
            e = e.parentNode;
        }
        else {
            break;
        }
    }
    return " ";
}

//获得坐标对应的链接text值
function MTT_GetHTMLElementAnchorTextAtPoint(x, y) {
    var e = document.elementFromPoint(x, y);
    while (e) {
        if (e.tagName) {
            if ((e.tagName == "BODY") || (e.tagName == "body") || (e.tagName == "HTML") || (e.tagName == "html")) {
                return " ";
            }
            else if ((e.tagName == "A") || (e.tagName == "a")) {
                return e.innerHTML;
            }
            e = e.parentNode;
        }
        else {
            break;
        }
    }
    return " ";
}

//获得坐标对应的image标签url
function getImageTagSrcFromPoint(x, y) {
    var e = document.elementFromPoint(x, y);
    var hasImg = false;
    if (e && (e.tagName == "img" || e.tagName == "IMG")) {
        return e.src;
    }
    else {
        return "";
    }
}

function documentCoordinateToViewportCoordinate(x, y) {
    var coord = new Object();
    coord.x = x - window.pageXOffset;
    coord.y = y - window.pageYOffset;
    return coord;
}

function viewportCoordinateToDocumentCoordinate(x, y) {
    var coord = new Object();
    coord.x = x + window.pageXOffset;
    coord.y = y + window.pageYOffset;
    return coord;
}

function elementFromPointIsUsingViewPortCoordinates() {
    if (window.pageYOffset > 0) {     // page scrolled down
        return (window.document.elementFromPoint(0, window.pageYOffset + window.innerHeight - 1) == null);
    } else if (window.pageXOffset > 0) {   // page scrolled to the right
        return (window.document.elementFromPoint(window.pageXOffset + window.innerWidth - 1, 0) == null);
    }
    return false; // no scrolling, don't care
}

function elementFromDocumentPoint(x, y) {
    if (elementFromPointIsUsingViewPortCoordinates()) {
        var coord = documentCoordinateToViewportCoordinate(x, y);
        return window.document.elementFromPoint(coord.x, coord.y);
    } else {
        return window.document.elementFromPoint(x, y);
    }
}

function elementFromViewportPoint(x, y) {
//    var coord;
//    coord.x = x;
//    coord.y = y;
    if (elementFromPointIsUsingViewPortCoordinates()) {
        return window.document.elementFromPoint(x, y);
        //return coord.y;
    } else {
        var coord = viewportCoordinateToDocumentCoordinate(x, y);
        return window.document.elementFromPoint(coord.x, coord.y);
        // coord = viewportCoordinateToDocumentCoordinate(x,y);
        //return coord.y;
    }
}

function getRectForSelectedText() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rect = range.getBoundingClientRect();
    return "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
}

function getTextAndRectForALink() {
    var all_links = document.getElementsByTagName('a');
    for (var i = 0, max = all_links.length; i < max; i++) {
        var link = all_links[i];
        var rect = link.getBoundingClientRect();

        if (link.innerText && link.href && rect.width && rect.height) {
            return link.innerText + "#####mtt$$$$$" + "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
        }
    }
}
                                          
