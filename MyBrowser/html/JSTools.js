function SeMobGetPageDescription(){
    var elements = document.getElementsByName('description');
    if (elements){
        for (var i=0; i < elements.length; i++){
            if(elements[i].tagName.toLowerCase() === 'meta'){
                return elements[i].content;
            }
        }
    }
}

function documentCoordinateToViewportCoordinate(x,y) {
    var coord = new Object();
    coord.x = x - window.pageXOffset;
    coord.y = y - window.pageYOffset;
    return coord;
}

function viewportCoordinateToDocumentCoordinate(x,y) {
    var coord = new Object();
    coord.x = x + window.pageXOffset;
    coord.y = y + window.pageYOffset;
    return coord;
}

function elementFromPointIsUsingViewPortCoordinates() {
    if (window.pageYOffset > 0) {     // page scrolled down
        return (window.document.elementFromPoint(0, window.pageYOffset + window.innerHeight -1) == null);
    } else if (window.pageXOffset > 0) {   // page scrolled to the right
        return (window.document.elementFromPoint(window.pageXOffset + window.innerWidth -1, 0) == null);
    }
    return false; // no scrolling, don't care
}

function elementFromDocumentPoint(x,y) {
    if (elementFromPointIsUsingViewPortCoordinates()) {
        var coord = documentCoordinateToViewportCoordinate(x,y);
        return window.document.elementFromPoint(coord.x,coord.y);
    } else {
        return window.document.elementFromPoint(x,y);
    }
}

function elementFromViewportPoint(x,y,doc) {
    if (!doc){
        doc = window.document;
    }
    if (elementFromPointIsUsingViewPortCoordinates()) {
        return doc.elementFromPoint(x,y);
    } else {
        var coord = viewportCoordinateToDocumentCoordinate(x,y);
        return doc.elementFromPoint(coord.x,coord.y);
    }
}



function MyAppGetHTMLElementsAtPoint(x,y) {
    var tags = ",";
    var e = elementFromViewportPoint(x,y);
    var tagName = e.tagName.toLowerCase();
    if (tagName == 'iframe' || tagName == 'frame'){
        var bounds = e.getBoundingClientRect();
        if (bounds){
            e = elementFromViewportPoint(x-bounds.left, y-bounds.top, e.contentDocument);
        }
    }
    while (e) {
        if (e.tagName) {
            tags += e.tagName + ',';
        }
        e = e.parentNode;
    }
    return tags;
}

function MyAppGetLinkSRCAtPoint(x,y) {
    var tags = "";
    var coord = viewportCoordinateToDocumentCoordinate(x,y);
    var e = elementFromViewportPoint(x,y);
    var tagName = e.tagName.toLowerCase();
    if (tagName == 'iframe' || tagName == 'frame'){
        var bounds = e.getBoundingClientRect();
        if (bounds){
            e = elementFromViewportPoint(x-bounds.left, y-bounds.top, e.contentDocument);
        }
    }
    while (e) {
        if (e.src) {
            tags += e.src;
            break;
        }
        e = e.parentNode;
    }
    return tags;
}

function MyAppGetHTMLElementsTextAtPoint(x,y){
    var tags = "";
    var coord = viewportCoordinateToDocumentCoordinate(x,y);
    var e = elementFromViewportPoint(x,y);
    var tagName = e.tagName.toLowerCase();
    if (tagName == 'iframe' || tagName == 'frame'){
        var bounds = e.getBoundingClientRect();
        if (bounds){
            e = elementFromViewportPoint(x-bounds.left, y-bounds.top, e.contentDocument);
        }
    }

    while (e) {
        if (e.text) {
            tags += e.text;
            break;
        }
        e = e.parentNode;
    }
    return tags;
}

function MyAppGetLinkHREFAtPoint(x,y) {
    var tags = "";
    var coord = viewportCoordinateToDocumentCoordinate(x,y);
    var e = elementFromViewportPoint(x,y);
    var tagName = e.tagName.toLowerCase();
    if (tagName == 'iframe' || tagName == 'frame'){
        var bounds = e.getBoundingClientRect();
        if (bounds){
            e = elementFromViewportPoint(x-bounds.left, y-bounds.top, e.contentDocument);
        }
    }

    while (e) {
        if (e.href) {
            tags += e.href;
            break;
        }
        e = e.parentNode;
    }
    return tags;
}

function SelectImage() {
    var a = document.images;
    for (var i = 0; i < a.length; i++) {
        var e = a[i];
        if (e.clientWidth > window.innerWidth / 2) {
            tags = e.src;
            return tags;
        }
    }
    return null;
}

function getHighlightedHtml() {
    var selection = window.getSelection().getRangeAt(0);
    var container = document.createElement('div');
    container.appendChild(selection.cloneContents());
    return container.innerHTML;
}

function getHighlightedString() {
    var selection = window.getSelection().getRangeAt(0);
    var container = document.createElement('div');
    container.appendChild(selection.cloneContents());
    return container.innerText;
}

function disableSystemLongPress(){
    document.body.style.webkitTouchCallout='none';
    document.documentElement.style.webkitTouchCallout='none';
    var iframes = document.getElementsByTagName('iframe');
    for (var index = 0; index < iframes.length; index++){
        var doc = iframes[index].contentDocument;
        if (doc){
            doc.body.style.webkitTouchCallout='none';
            doc.documentElement.style.webkitTouchCallout='none';
        }
    }
    var frames = document.getElementsByTagName('frame');
    for (var index = 0; index < frames.length; index++){
        var doc = frames[index].contentDocument;
        if (doc){
            doc.body.style.webkitTouchCallout='none';
            doc.documentElement.style.webkitTouchCallout='none';
        }
    }
}

function MyAppGetImageIndexAndUrlAtPoint(x,y) {
    var tags = "";
    var coord = viewportCoordinateToDocumentCoordinate(x,y);
    var e = elementFromViewportPoint(x,y);
    var tagName = e.tagName.toLowerCase();
    if (tagName == 'iframe' || tagName == 'frame'){
        var bounds = e.getBoundingClientRect();
        if (bounds){
            e = elementFromViewportPoint(x-bounds.left, y-bounds.top, e.contentDocument);
        }
    }
    tagName = e.tagName.toLowerCase();
    if (tagName == 'img')
    {
        var imgs=document.images;
        for(var i=0; i<imgs.length;i++)
        {
            if(imgs[i]==e)
            {
                tags=i+","+e.src;
                break;
            }
        }
    }
    return tags;
}

function MyAppGetAllImageUrls()
{
    var ret=[];
    var imgs=document.images;
    for(var i=0; i<imgs.length;i++)
    {
        ret.push(imgs[i].src);
    }
    return JSON.stringify(ret);
}