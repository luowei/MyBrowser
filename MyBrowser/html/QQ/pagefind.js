var MyApp_SearchResultCount = 0;
var MyApp_SearchResultArray = new Array();
var MyApp_SearchResultPosLeft = new Array();
var MyApp_SearchResultPosTop = new Array();
var ignoreTags = /^(IFRAME|SCRIPT|STYLE|OBJECT|TEXTAREA|SELECT)$/;
function MyApp_HighlightAllOccurencesOfStringForElement(element, keyword) {
    if (element) {
        if (element.nodeType == 3) {
            var tmpNum = 0;
            var tmpArray = new Array();
            while (true) {
                var value = element.nodeValue;
                var idx = value.toLowerCase().indexOf(keyword);
                if (idx < 0) {
                    break
                }
                var span = document.createElement("b");
                var text = document.createTextNode(value.substr(idx, keyword.length));
                span.appendChild(text);
                span.setAttribute("class", "QQMttHDHighlight");
                span.style.setProperty('background-Color', 'rgba(242,198,62,0.5)', 'important');
                span.style.setProperty('color', 'black', 'important');
                span.style.setProperty('fontWeight', 'normal', 'important');
                text = document.createTextNode(value.substr(idx + keyword.length));
                element.deleteData(idx, value.length - idx);
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
                tmpArray[tmpNum] = span;
                tmpNum++
            }
            while (tmpNum > 0) {
                MyApp_SearchResultArray[MyApp_SearchResultCount] = tmpArray[tmpNum - 1];
                MyApp_SearchResultCount++;
                tmpNum--
            }
        } else {
            if (element.nodeType == 1) {
                var tagName = element.tagName;
                if (tagName.search(ignoreTags) !== -1) {
                    return
                }
                var tcss = window.getComputedStyle(element, null);
                if (tcss.getPropertyValue("display") === "none" || tcss.getPropertyValue("visibility") === "hidden") {
                    return
                }
                var nodes = element.childNodes;
                for (var i = nodes.length - 1; i >= 0; i--) {
                    MyApp_HighlightAllOccurencesOfStringForElement(nodes[i], keyword)
                }
            }
        }
    }
}
function getElementLeft(element) {
    var actualLeft = element.offsetLeft;
    var current = element.offsetParent;
    while (current !== null) {
        actualLeft += current.offsetLeft;
        current = current.offsetParent
    }
    return actualLeft
}
function getElementTop(element) {
    var actualTop = element.offsetTop;
    var current = element.offsetParent;
    while (current !== null) {
        actualTop += current.offsetTop;
        current = current.offsetParent
    }
    return actualTop
}
function MyApp_HighlightAllOccurencesOfString(keyword) {
    MyApp_RemoveAllHighlights();
    MyApp_HighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
    MyApp_SortSearchResultByY();
    if (MyApp_SearchResultCount > 0) {
        for (var i = 0; i < MyApp_SearchResultCount; i++) {
            MyApp_SearchResultPosLeft[i] = getElementLeft(MyApp_SearchResultArray[i]);
            MyApp_SearchResultPosTop[i] = getElementTop(MyApp_SearchResultArray[i])
        }
        MyApp_SpecificHighlight(0, MyApp_SearchResultCount - 1, 0)
    }
}
function MyApp_RemoveAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            var className = element.getAttribute("class");
            if (null != className && className.indexOf("QQMttHDHighlight") >= 0) {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text, element);
                element.parentNode.removeChild(element);
                return true
            } else {
                var normalize = false;
                for (var i = element.childNodes.length - 1; i >= 0; i--) {
                    if (MyApp_RemoveAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true
                    }
                }
                if (normalize) {
                    element.normalize()
                }
            }
        }
    }
    return false
}
function MyApp_RemoveAllHighlights() {
    MyApp_SearchResultCount = 0;
    MyApp_SearchResultArray = [];
    MyApp_SearchResultPosLeft = [];
    MyApp_SearchResultPosTop = [];
    MyApp_RemoveAllHighlightsForElement(document.body)
}
function MyApp_SpecificHighlight(index, lastIndex, bScroll) {
    if (MyApp_SearchResultCount > 0) {
        if ((index >= 0) && (index < MyApp_SearchResultCount)) {
            if (bScroll > 0 || ((document.body.scrollTop + document.documentElement.clientHeight - 80) < MyApp_SearchResultPosTop[MyApp_SearchResultCount - 1 - index]) || (document.body.scrollTop > MyApp_SearchResultPosTop[MyApp_SearchResultCount - 1 - index])) {
                window.scrollTo(MyApp_SearchResultPosLeft[MyApp_SearchResultCount - 1 - index], MyApp_SearchResultPosTop[MyApp_SearchResultCount - 1 - index] - 60)
            }
            MyApp_SearchResultArray[MyApp_SearchResultCount - 1 - index].style.setProperty('background-Color', '#f2c63e', 'important');
            MyApp_SearchResultArray[MyApp_SearchResultCount - 1 - index].style.cssText += "box-shadow:1px 1px 2px rgba(0,0,0,0.5),-1px 0px 2px rgba(0,0,0,0.5)!important;"
        }
    }
}
function MyApp_SpecificRemoveHighlight(index) {
    MyApp_SearchResultArray[MyApp_SearchResultCount - 1 - index].style.setProperty('background-Color', 'rgba(242,198,62,0.5)', 'important');
    MyApp_SearchResultArray[MyApp_SearchResultCount - 1 - index].style.cssText += "box-shadow:0px 0px 0px rgba(0,0,0,0)!important;"
}
function MyApp_SortSearchResultByY() {
    if (MyApp_SearchResultCount > 1) {
        var i, j;
        var key;
        for (i = 1; i < MyApp_SearchResultCount; i++) {
            key = MyApp_SearchResultArray[i];
            for (j = i - 1; j >= 0 && getElementTop(MyApp_SearchResultArray[j]) < getElementTop(key); j--) {
                MyApp_SearchResultArray[j + 1] = MyApp_SearchResultArray[j]
            }
            MyApp_SearchResultArray[j + 1] = key
        }
    }
};