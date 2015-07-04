var SAFARI = true;
var DEBUG = false;

(function() {

// Console.js

function Console()
{
    var output;
 
     function appendLog(type, string)
     {
       if(!DEBUG)
       {
        return;
       }

       nativeBridge.callWithParams("DebugInfo", string, null);
    }
 
    function log(logString)
    {
        appendLog("log", logString);
    }
 
    function warn(warnString)
    {
        appendLog("warn", warnString);
    }
 
     function error(errorString)
     {
         appendLog("error", errorString);
     }
 
    // public API
    this.log = log;
    this.warn = warn;
    this.error = error;
}


// ContentVeil.js

function ContentVeil() {
    "use strict";
    
    // @TODO: save() and restore() aren't properly used here, so if we do things like add transforms in founctions,
    // we probably break other functions' notion of how to render things.
    
    var veil = document.createElement("div");
    var inner = document.createElement("div");
    veil.appendChild(inner);
 
    // jhuang: border-box is css3 property, doesn't works very well on iOS4/iOS5.
    //veil.style.boxSizing = "border-box";
    veil.style.borderStyle = "solid";
    veil.style.borderColor = "rgba(0, 0, 0, 0.7)";
    
    inner.style.border = "4px solid rgba(255, 255, 0, 0.7)";
    inner.style.height = "100%";
    //inner.style.boxSizing = "border-box";
    
    // We keep a record of what we're currently showing (at least in some cases) so that we can update it in case the
    // state of the page changes (like if the user scrolls).
    var currentlyShownRect = null;
    var currentRectOffsetTop = 0;
    var currentRectOffsetLeft = 0;
    var currentlyStatic = false;
    
    function reset() {
        currentlyShownRect = null;
        currentRectOffsetTop = 0;
        currentRectOffsetLeft = 0;
        
        showElements("embed");
        showElements("iframe");
 
        veil.style.position = "absolute";
        veil.style.top = "0px";
        veil.style.left = "0px";
        veil.style.zIndex = "9999999999999990";
 
 
        blank();
    }
 
    function getPageRect()
    {
      var SW=0, SH=0, H=0;
      var w=window, d=document, dd=d.documentElement;
      H=w.innerHeight||dd.clientHeight||d.body.clientHeight;
      SW=Math.max(d.body.scrollWidth, dd.scrollWidth ||0);
      SH=Math.max(d.body.scrollHeight,dd.scrollHeight||0, H);
 
       return { top: 0,  left: 0,  bottom:SH, right:SW, width: SW, height: SH };
    }
 
    function blank()
    {
        var rect = getPageRect();
 
         veil.style.width =  rect.width + "px";
         veil.style.height = rect.height + "px";
 
 veil.style.borderLeftWidth = "0px";
 veil.style.borderTopWidth = "0px";
 veil.style.borderRightWidth = "0px";
 veil.style.borderBottomWidth = "0px";
 
         console.log("veil size: " + veil.style.width + ": " + veil.style.height);
    }
 
    function gray() {
        show();
        inner.style.display = "none";
        veil.style.backgroundColor = veil.style.borderColor;
    }
    
    function show() {
        inner.style.display = "";
        veil.style.backgroundColor = "";
        if (!veil.parentNode) {
            document.documentElement.appendChild(veil);
        }
    }
    
    function hide() {
        if (veil.parentNode) {
            veil.parentNode.removeChild(veil);
        }
    }
    
    // Makes a rectangle bigger in all directions by the number of pixels specified (or smaller, if 'amount' is
    // negative). Returns the new rectangle.
    function expandRect(rect, amount) {
        return {
        top: (rect.top - amount),
        left: (rect.left - amount),
        bottom: (rect.bottom + amount),
        right: (rect.right + amount),
        width: (rect.width + (2 * amount)),
        height: (rect.height + (2 * amount))
        };
    }
 
    function revealRect(rect) {
        
        // Save this info.
        currentlyShownRect = rect;
        currentRectOffsetTop = document.body.scrollTop;
        currentRectOffsetLeft = document.body.scrollLeft;
        
        // We expand the rectangle for two reasons.
        // 1) we want to expand it by the width of the stroke, so that when we draw out outline, it doesn't overlap our
        // content.
        // 2) We want to leave a little extra room around the content for aesthetic reasons.
        rect = expandRect(rect, 8);
 
        var sLeft = document.body.scrollLeft;
        var sTop = document.body.scrollTop;
 
        rect.left += sLeft;
        rect.top += sTop;
        rect.right += sLeft;
        rect.bottom += sLeft;
 
        //console.log('revealRect: ' + rect.left +' ' + rect.top + ' ' + rect.width + ' ' + rect.height);
 
        var x = rect.left;
        var y = rect.top;
        var width = rect.width;
        var height = rect.height;
        
        var pageRect = getPageRect();
        
        var pageWidth = pageRect.width;
        var pageHeight = pageRect.height;
        
        inner.style.display = "block";
        veil.style.borderLeftWidth = Math.max(x, 0) + "px";
        veil.style.borderTopWidth = Math.max(y, 0) + "px";
        veil.style.borderRightWidth = Math.max((pageWidth - x - width), 0) + "px";
        veil.style.borderBottomWidth = Math.max((pageHeight - y - height), 0) + "px";

        veil.style.width = width + "px";
        veil.style.height = height + "px";
        
        console.log("bottom width" + veil.style.borderBottomWidth);
 }
 
    function outlineElement(element, scrollTo) {
        // See notes in Preview.js for why we use this method instead of just calling element.getBoundingClientRect().
        //var rect = contentPreview.computeDescendantBoundingBox(element);
 
        var rect = element.getBoundingClientRect();
        console.log("outlineElement: width: " + rect.width + "height:" + rect.height);
        if (rect) {
            
            var mutableRect = {
            top: rect.top,
            bottom: rect.bottom,
            left: rect.left,
            right: rect.right,
            width: rect.width,
            height: rect.height,
            }
            
            // We don't want to adjust ourselves into odd positions if the page is scrolled.
            mutableRect = expandRect(mutableRect, -9);
 
            /*
            var BORDER_MIN = 9;
            if (mutableRect.left < (BORDER_MIN - sLeft)) {
                mutableRect.width -= (BORDER_MIN - sLeft) - mutableRect.left;
                mutableRect.left = (BORDER_MIN - sLeft);
            }
            if (mutableRect.top < (BORDER_MIN - sTop)) {
                mutableRect.height -= (BORDER_MIN - sTop) - mutableRect.top;
                mutableRect.top = (BORDER_MIN - sTop);
            }
 

            // Get the wider of our two possible widths.
            var width = Math.max(document.body.scrollWidth, window.innerWidth);
            
            if (mutableRect.right > (width - BORDER_MIN - sLeft)) {
                mutableRect.right = (width - BORDER_MIN - sLeft);
                mutableRect.width = mutableRect.right - mutableRect.left;
            }*/
 
            reset();
            revealRect(mutableRect);
 
            if (scrollTo) {
                element.scrollIntoViewIfNeeded(true);
                // Use the following if this makes it into Firefox or other Gecko-based browsers:
                // element.scrollIntoView(false);
            }
 
            hideElements("embed", element);
            hideElements("iframe", element);
            show();
        }
        else {
            console.warn("Couldn't create rectangle from element: " + element.toString());
        }
    }
    
    function hideElements (tagName, exceptInElement) {
        var els = document.getElementsByTagName(tagName);
        for (var i = 0; i < els.length; i++) {
            els[i].enSavedVisibility = els[i].style.visibility;
            els[i].style.visibility = "hidden";
        }
        showElements(tagName, exceptInElement);
    }
    
    function showElements (tagName, inElement) {
        if (!inElement) {
            inElement = document;
        }
        var els = inElement.getElementsByTagName(tagName);
        for (var i = 0; i < els.length; i++) {
            if (typeof els[i].enSavedVisibility !== "undefined") {
                els[i].style.visibility = els[i].enSavedVisibility;
                delete els[i].enSavedVisibility;
            }
        }
    }
    
    // Public API:
    this.reset = reset;
    this.show = show;
    this.gray = gray;
    this.hide = hide;
    this.revealRect = revealRect;
    this.outlineElement = outlineElement;
    this.expandRect = expandRect;
}



// PageInfo.js

function PageInfo() {
    "use strict";
    
    // This is a map of hostnames (for hostnames that begin with 'www.', the 'www.' will be stripped off first, so don't
    // include it in your lookup string) to CSS selectors. When we try and locate an article in a page, we'll see if we
    // can find the doamin for the page in this list, and if so, we'll try and find an element that matches the given
    // selector. If no element is returned, we'll fall back to the heuristic approach.
    var specialCases = {
        "penny-arcade.com": ["div.contentArea > div.comic > img"],
        "aspicyperspective.com": ["div.entry-content"],
        "thewirecutter.com": ["div#content"],
        "katespade.com": ["div#pdpMain"],
        "threadless.com": ["section.product_section"],
        "yelp.com": ["div#bizBox"],
        "flickr.com": ["div#photo"],
        "instagr.am": ["div.stage > div.stage-inner"],
        "stackoverflow.com": ["div#mainbar"],
        "makeprojects.com": ["div#guideMain"],
        "cookpad.com": ["div#main"],
        "imgur.com": ["div.image"],
        "smittenkitchen.com": ["div.entry"],
        "allrecipes.com": ["div#content-wrapper"],
        "qwantz.com": ["img.comic"],
        "questionablecontent.net": ["img#strip"],
        "cad-comic.com": ["div#content"],
        "twitter.com": [".permalink", "div.content-main"],
        "wikipedia.com" : ["div#content"]    // jhuang
    }
    
    var useFoundImage = [
                         "xkcd.com"
                         ]
    
    // These are the items we're trying to collect. This first block is trivial.
    var containsImages = Boolean(document.getElementsByTagName("img").length > 0);
    var documentWidth = document.width;
    var documentHeight = document.height;
    var url = document.location.href;
    var documentLength = document.body.textContent.length;
    
    // These take slightly more work and are initialized only when requested.
    var article = null;
    var articleBoundingClientRect = null;
    var selection = false; // This is easy to get, but is always "false" at load time until the user selects something.
    var selectionIsInFrame = false;
    var documentIsFrameset = false;
    var selectionFrameElement = null;
    var recommendationText = null;
    
    var clearlyInjected = false;
    
    // Internal state variables to keep us duplicating work.
    var hasCheckedArticle = false;
    
    // Experimental recognition of 'image' pages (like photo sites and comics).
    function findImage() {
        var imgs = document.getElementsByTagName("img");
        var biggest = null;
        var biggestArea = 0;
        for (var i = 0; i < imgs.length; i++) {
            var style = window.getComputedStyle(imgs[i]);
            var width = style.width.replace(/[^0-9.-]/g, "");
            var height = style.height.replace(/[^0-9.-]/g, "");
            var area = width * height;
            if (!biggest || area > biggestArea) {
                biggest = imgs[i];
                biggestArea = area;
            }
        }
        return biggest;
    }
    
    function getAncestors(node) {
        var an = [];
        while (node) {
            an.unshift(node);
            node = node.parentNode;
        }
        return an;
    }
    
    function getDeepestCommonNode(nodeList1, nodeList2) {
        var current = null;
        for (var i = 0; i < nodeList1.length; i++) {
            if (nodeList1[i] === nodeList2[i]) {
                current = nodeList1[i];
            }
            else {
                break;
            }
        }
        return current;
    }
    
    function getCommonAncestor(nodeList) {
        if (!nodeList.length) return null;
        
        if (nodeList.length == 1) return nodeList[0];
        var lastList = getAncestors(nodeList[0]);
        
        var node = null;
        for (var i = 1; i < nodeList.length; i++) {
            var list = getAncestors(nodeList[i]);
            node = getDeepestCommonNode(lastList, list);
            lastList = getAncestors(node);
        }
        return node;
    }
    
    function clearlyCallback(candidateId, callback) {
        
        findImage();
        
        // See if we should special-case this.
        var host = getHostname();
        if (specialCases[host])
        {
            for (var i = 0; i < specialCases[host].length; i++) {
                var candidate = document.querySelector(specialCases[host][i]);
                if (candidate) {
                    article = candidate;
                    articleBoundingClientRect = article.getBoundingClientRect();
                    break;
                }
            }
        }
        
        // Or see if it's a special case image page.
        else if (useFoundImage.indexOf(host) != -1) {
            article = findImage();
            if (article)
                articleBoundingClientRect = article.getBoundingClientRect();
        }
        
        // If it's not a special case, see if it's a single image.
        if (!article) {
            var imageTypes = ['jpeg', 'jpg', 'gif', 'png'];
            var urlExtension = document.location.href.replace(/^.*\.(\w+)$/, "$1");
            if (urlExtension && (imageTypes.indexOf(urlExtension) != -1)) {
                var candidate = document.querySelector("body > img");
                if (candidate) {
                    article = candidate;
                    articleBoundingClientRect = article.getBoundingClientRect();
                }
            }
        }
 
        console.log("1:" + article);
 
        // If we still didn't find an article, let's see if maybe it's in a frame. Cleary fails on frames so we try this
        // check before we use our clearly info.
        if (!article) {
            if (document.body.nodeName.toLowerCase() == "frameset") {
                documentIsFrameset = true;
                var frame = findBiggestFrame();
                if (frame && frame.contentDocument && frame.contentDocument.documentElement) {
                    selectionFrameElement = frame;
                    article = frame.contentDocument.documentElement;
                    articleBoundingClientRect = article.getBoundingClientRect();
                }
            }
        }
 
        console.log("2:" + article);
 
        // If we didn't use any of our special case handling, we'll use whatever clearly found.
        if (!article) {
 
            console.log("Traversal Dom Tree result:" + candidateId);
 
            if(candidateId)
            {
                 article = document.getElementById(candidateId);
            }
        }
 
        console.log("3:" + article);
 
        // If clearly found nothing (because it failed), then use the body of the document.
        if (!article) {
            article = document.body;
        }
        
        hasCheckedArticle = true;
        callback();
    }
    
    // This will try and determine the 'default' page article. It will only run once per page, but it's specifically
    // called only on demand as it can be expensive.
    function findArticle(candidateId, callback) {

            // If we'd previously computed an article element, but it's lost its parent or become invisible, then we'll try
            // and re-compute the article. This can happen if, for example the page dynamically udaptes itself (like showing
            // the latest news article in a box that updates periodically). This doesn't guarantee that we clip something
            // sane if this happens, (if the page re-writes itself while a clip is taking place, the results are
            // indeterminate), but it will make such things less likely.
            if (article &&
                (!article.parentNode || !article.getBoundingClientRect || article.getBoundingClientRect().width == 0)) {
                article = null;
                hasCheckedArticle = false;
            }
            
            if (!hasCheckedArticle)
            {
                clearlyCallback(candidateId, callback);
            }
            else {
                callback();
            }
    }
    
    function findBiggestFrame() {
        var frames = document.getElementsByTagName("frame");
        var candidate = null;
        var candidateSize = 0;
        for (var i = 0; i < frames.length; i++) {
            if (frames[i].width && frames[i].height) {
                var area = frames[i].width * frames[i].height;
                if (area > candidateSize) {
                    candidate = frames[i];
                    candidateSize = area;
                }
            }
        }
        return candidate;
    }
    
    function getHostname() {
        var match = document.location.href.match(/^.*?:\/\/(www\.)?(.*?)(\/|$)/);
        if (match) {
            return match[2];
        }
        return null;
    }
    
    function getDefaultArticle(candidateId, callback)
   {
        findArticle(candidateId, function(){callback(article)});
        // Article already exists, so we'll return it.
        if (article) return article;
    }
    
    // Looks for selections in the current document and descendent (i)frames.
    // Returns the *first* non-empty selection.
    function getSelection() {
 console.log("getSelection<---");
        // First we check our main window and return a selection if that has one.
        var selection = window.getSelection();
        if (selection && selection.rangeCount && !selection.isCollapsed) {
 console.log("getSelection: user has selection some text manually");
            return selection;
        }
        
        // Then we'll try our frames and iframes.
        var docs = [];
        var iframes = document.getElementsByTagName("iframe");
        for (var i = 0; i < iframes.length; i++) {
            docs.push(iframes[i]);
        }
        var frames = document.getElementsByTagName("frame");
        for (var i = 0; i < frames.length; i++) {
            docs.push(frames[i]);
        }
        
        var urlBase = document.location.href.replace(/^(https?:\/\/.*?)\/.*/i, "$1").toLowerCase();
        for (var i = 0; i < docs.length; i++) {
            
            // If frames/iframes fail a same origin policy check, then they'll through annoying errors, and we wont be able
            // to access them anyway, so we attempt to skip anything that wont match.
            if (docs[i].src && docs[i].src.toLowerCase().substr(0, urlBase.length) !== urlBase) {
                continue;
            }
            
            var doc = docs[i].contentDocument;
            
            if (doc) {
                var frameSelection = doc.getSelection();
                if (frameSelection && frameSelection.rangeCount && !frameSelection.isCollapsed) {
                    selectionIsInFrame = true;
                    selectionFrameElement = docs[i];
                    return frameSelection;
                }
            }
            else {
                console.warn("iframe contained no Document object.");
            }
        }
        
        // Didn't find anything.
 console.log("getSelection: Didn't find anything");
        return null;
    }
    
    function getText(node, soFar, maxLen) {
        if (node.nodeType == Node.TEXT_NODE) {
            var trimmed = node.textContent.trim().replace(/\s+/g, " ");
            if (trimmed === " " || trimmed === "") return soFar;
            return soFar + " " + trimmed;
        }
        
        var banned = [
                      "script",
                      "noscript"
                      ];
        
        if (node.nodeType == Node.ELEMENT_NODE) {
            if (banned.indexOf(node.nodeName.toLowerCase()) == -1) {
                for (var i = 0; i < node.childNodes.length; i++) {
                    soFar = getText(node.childNodes[i], soFar, maxLen);
                    if (soFar.length > maxLen) {
                        return soFar;
                    }
                }
            }
        }
        return soFar;
    }
    
    // Note: you must call getSelection() first to populate this field!
    function getSelectionFrame() {
        return selectionFrameElement;
    }
    
    // Public API:
    this.getDefaultArticle = getDefaultArticle;
    this.getSelection = getSelection;
    this.getSelectionFrame = getSelectionFrame;
}



// Preview.js

function ContentPreview() {
    "use strict";
 
    var previewedRange = null;
 
    var contentVeil = new ContentVeil();
    
    // Stores a reference to the last element that we used as a preview.
    var previewElement = null;
    
    // This doesn't remove internal state of previewElement, because another script may not have finished clipping until
    // after the page looks 'clear'.
    function clear()
    {
        console.log("Clear previewSelection");
//        previewedSelection = null;
        contentVeil.reset();
        contentVeil.hide();
    }
 
    function getPreviewedRange()
    {
        return previewedRange;
    }
 
    function setPreviewedRange(theRange)
    {
        previewedRange = theRange;
    }
 
    function _previewArticle () {
        if (previewElement)
        {
            var selectionFrame;
            if (typeof pageInfo !== undefined) {

                selectionFrame = pageInfo.getSelectionFrame();
            }
            
            if (selectionFrame) {
                
                var rect = {
                width: selectionFrame.width,
                height: selectionFrame.height,
                top: selectionFrame.offsetTop,
                bottom: (selectionFrame.height + selectionFrame.offsetTop),
                left: selectionFrame.offsetLeft,
                right: (selectionFrame.width + selectionFrame.offsetLeft)
                };
                contentVeil.revealRect(contentVeil.expandRect(rect, -9));
                contentVeil.show();
            }
            else
            {
                // (jHuang): we didn't scroll to top on iPad.
                // contentVeil.outlineElement(previewElement, true);
                contentVeil.outlineElement(previewElement, false);
            }
        }
        else {
            console.warn("Couldn't find a preview element. We should switch to 'full page' mode.");
        }
    }
    
    function previewArticle (candidateId)
    {
        clear();
        previewElement = null;
        
        if (typeof pageInfo !== undefined)
        {
            previewElement = pageInfo.getDefaultArticle(candidateId,
                                                        
                                                        function(el){
                                                        previewElement = el;
                                                        _previewArticle();
                                                        });
        }
        else {
            console.warn("Couldn't find a 'pageInfo' object.");
        }
    }
    
    // Returns the current article element, which may not be the same as the auto-detected one if the user has 'nudged'
    // the selection around the page.
    function getArticleElement() {
        return previewElement;
    }
 
    function hasPreviewedArticle()
    {
        return (previewElement && typeof previewElement !== "undefined");
    }
 
    function previewFullPage() {
 
        var borderWidth = 10;
        var w = document.body.scrollWidth;
        var h = document.body.scrollHeight;
 
        var rect = {
            bottom: (h - borderWidth),
            top: (borderWidth
                  - document.body.scrollTop),
            left: (borderWidth),
            right: (w - borderWidth),
            width: (w - (2 * borderWidth)),
            height: (h - (2 * borderWidth))
            }
 
        clear();
        contentVeil.reset();
        contentVeil.revealRect(rect);
        contentVeil.show();
    }
    
    // Creates the union of two rectangles, which is defined to be the smallest rectangle that contains both given
    // rectangles.
    function unionRectangles(rect1, rect2) {
        var rect = {
        top: (Math.min(rect1.top, rect2.top)),
        bottom: (Math.max(rect1.bottom, rect2.bottom)),
        left: (Math.min(rect1.left, rect2.left)),
        right: (Math.max(rect1.right, rect2.right))
        }
        rect.width = rect.right - rect.left;
        rect.height = rect.bottom - rect.top;
        
        return rect;
    }
    
    // Returns true if the rectangles match, false otherwise.
    function rectanglesEqual(rect1, rect2) {
        if (!rect1 && !rect2) return true;
        if (!rect1) return false;
        if (!rect2) return false;
        if (rect1.top != rect2.top) return false;
        if (rect1.bottom != rect2.bottom) return false;
        if (rect1.left != rect2.left) return false;
        if (rect1.right != rect2.right) return false;
        if (rect1.width != rect2.width) return false;
        if (rect1.height != rect2.height) return false;
        return true;
    }
    
    // If the user triple-clicks a paragraph, we will often get a selection that includes the next paragraph after the
    // selected one, but only up to offset 0 in that paragraph. This causes the built in getBoundingClientRect to give a
    // box that includes the whole trailing paragraph, even though none of it is actually selected. Instead, we'll build
    // our own bounding rectangle that omits the trailing box.
    // @TODO: Currently this computes a box that is *too big* if you pass it a range that doesn't have start and/or end
    // offsets that are 0, because it will select the entire beginning and ending node, instead of jsut the selected
    // portion.
    function computeAlternateBoundingBox(range) {
        
        // If the end of selection isn't at offset 0 into an element node (rather than a text node), then we just return the
        // original matching rectangle.
        if ((range.endOffset !== 0) || (range.endContainer.nodeType !== Node.ELEMENT_NODE)) {
            var rect = range.getBoundingClientRect();
            var mutableRect = {
            top: rect.top,
            bottom: rect.bottom,
            left: rect.left,
            right: rect.right,
            width: rect.width,
            height: rect.height
            };
            return mutableRect;
        }
        
        // This is the one we don't want.
        var endElementRect = null;
        try {
            endElementRect = range.endContainer.getBoundingClientRect();
        }
        catch(ex) {
            console.warn("Couldn't get a bounding client rect for our end element, maybe it's a text node.");
        }
        
        // We look for a rectangle matching our end element, and if we find it, we don't copy it to our list to keep.
        // You'd think we could just grab the last element in range.getClientRects() here and trim that one, which might be
        // true, but the spec makes no claim that these are returned in order, so I don't want to rely on that.
        // We keep track if we remove a rectangle, as we're only trying to remove one for the trailing element. If there are
        // more than one matching rectangle, we want to keep all but one of them.
        var foundEnd = false;
        var keptRects = [];
        var initialRects = range.getClientRects();
        for (var i = 0; i < initialRects.length; i++) {
            if (rectanglesEqual(endElementRect, initialRects[i]) && !foundEnd) {
                foundEnd = true;
            }
            else {
                keptRects.push(initialRects[i]);
            }
        }
        
        // Now compute our new bounding box and return that.
        if (keptRects.length == 0) return range.getBoundingClientRect();
        if (keptRects.length == 1) return keptRects[0];
        
        var rect = keptRects[0];
        for (var i = 1; i < keptRects.length; i++) {
            rect = unionRectangles(rect, keptRects[i]);
        }
        
        return rect;
    }
    
    // If every edge of the rectangle is in negative space,
    function rectIsOnScreen(rect) {
        // rtl pages have actual content in "negative" space. This case could be handled better.
        if (document.dir == "rtl") {
            return false;
        }
        // If both top and bottom are in negative space, we can't see this.
        if (rect.bottom < 0 && rect.top < 0) {
            return false;
        }
        // Or, if both left and right are in negative space, we can't see this.
        if (rect.left < 0 && rect.right < 0) {
            return false;
        }
        // Probably visible.
        return true;
    }
    
    function applyElementRect(element, rect) {
        var newRect = rect;
        var tempRect = element.getBoundingClientRect();
        
        // Skip elements that are positioned off screen.
        if (!rectIsOnScreen(tempRect)) {
            return newRect;
        }
        // We skip anything with an area of one px or less. This is anything that has "display: none", or single pixel
        // images for loading ads and analytics and stuff. Most hidden items end up at 0:0 and will stretch our rectangle
        // to the top left corner of the screen if we include them. Sometimes single pixels are deliberately placed off
        // screen.
        if ((tempRect.width * tempRect.height) > 1) {
            newRect = unionRectangles(element.getBoundingClientRect(), rect);
        }
        
        // We won't descend into hidden elements.
        if (getComputedStyle(element).display == "none") {
            return newRect;
        }
        
        if (element.children) {
            for (var i = 0; i < element.children.length; i++) {
                newRect = applyElementRect(element.children[i], newRect);
            }
        }
        return newRect;
    }
    
    // In the case of positioned elements, a bounding box around an element doesn't necessarily contain its child
    // elements, so we have this method to combine all of these into one bigger box. ContentVeil calls this function.
    function computeDescendantBoundingBox(element) {
        if (!element) return {top: 0, bottom: 0, left: 0, right: 0, width: 0, height: 0};
        return applyElementRect(element, element.getBoundingClientRect());
    }

    // On iPhone we need to update the selection but not show the contentVeil to user.
    function previewSelectionNotMark()
    {
        if (typeof pageInfo !== undefined) 
        {
            var pageInfoSelection = pageInfo.getSelection();
            if(pageInfoSelection && pageInfoSelection.rangeCount > 0)
            {
                  //The window's selection will auto dismiss when other controller over the current page,
                  //So here we need save the range
                  setPreviewedRange(pageInfoSelection.getRangeAt(0));
            }
        }

        //console.log("previewSelectionNotMark : " + previewedSelection.rangeCount + " " +  previewedSelection);
    }

    function previewSelection() {
        console.log("previewSelection <------");
        var selection;
        var selectionFrame;
        if (typeof pageInfo !== undefined) {
            selection = pageInfo.getSelection();
            // If our selection is in a frame or iframe, we'll compute an offset relative to that, so we need to adjust it by
            // the offset of the frame.
            selectionFrame = pageInfo.getSelectionFrame();
        }
        //contentVeil.reset();
        
        var frameRect = null;
        if (selectionFrame) {
            frameRect = selectionFrame.getBoundingClientRect();
        }
        
        var range, rect, i;
 
        // If !selection, then something has gone awry.
        if (selection && selection.rangeCount > 0) {
            //clear();
 console.log("previewSelection deepCopySelectionRange <---");
            //The window's selection will auto dismiss when other controller over the current page,
            //So here we need save the range
            setPreviewedRange(selection.getRangeAt(0));
 console.log("previewSelection deepCopySelectionRange --->");
            contentVeil.reset();
            // We attempt to highlight each selection, but this hasn't been tested for more than a single selection.
            for (i = 0; i < selection.rangeCount; i++) {
                range = selection.getRangeAt(i);
                
                rect = computeAlternateBoundingBox(range);
 
                console.log('rect compute range: ' + rect.left +' ' + rect.top + ' ' + rect.width + ' ' + rect.height);
 
                // Actual adjustment mentioned earlier regarding frames.
                if (frameRect) {
                    rect.left += frameRect.left;
                    rect.right += frameRect.left;
                    rect.top += frameRect.top;
                    rect.bottom += frameRect.top;
                }

                contentVeil.revealRect(rect);
            }
        }
        contentVeil.show();
    }
    
    // Public API:
    this.previewArticle = previewArticle;
    this.previewSelection = previewSelection;
    this.previewSelectionNotMark = previewSelectionNotMark;
    this.getArticleElement = getArticleElement;
    this.hasPreviewedArticle = hasPreviewedArticle;
    this.clear = clear;
    this.getPreviewedRange = getPreviewedRange;
    this.computeDescendantBoundingBox = computeDescendantBoundingBox;
    this.previewFullPage = previewFullPage;
}

// Clipper

function Clipper() {
    var serializer = new HtmlSerializer();
    var _jsCallId = null;   // This ID is used to comunicate with Native code.
 
    function Note()
    {
    }
    
    var note = new Note();
    
    function clipFullPage(keepStyle,jsCallId)
    {
        _jsCallId = jsCallId;
        serializer.serialize(document.body, null, keepStyle, complete);
    }
    
    function clipArticle(keepStyle,jsCallId)
    {
        _jsCallId = jsCallId;
        var el;
        try
        {
            // ContentPreview should have already done this work, and potentially nudged it around somewhere.
            el = contentPreview.getArticleElement();
            if (el)
            {
                console.log("start convert html to enml ..." + _jsCallId);
                serializer.serialize(el, null, keepStyle, complete);
                console.log("serializer return ..." + _jsCallId);
                return;
            }
        }
        catch (e) {
            console.warn("[clipArticle] Couldn't get preview from contentPreview. Trying pageInfo. error: " + e);
        }
 
        /*
        try {
            function proxy(article) {
                serializer.serialize(article, null, keepStyle, complete);
            }
            pageInfo.getDefaultArticle(null, proxy);
            return;
        }
        catch (e) {
            console.warn("Couldn't get article from pageInfo. Trying default.");
        }*/
 
        serializer.serialize(document.body, null, keepStyle, complete);
    }
    
    function clipSelection(keepStyle,jsCallId)
    {
        _jsCallId = jsCallId;
        buildSelection(keepStyle);
    }
    
    // @TODO: Duplicated in HtmlSerializer. Consolidate.
    function escapeHTML(str){
        str = str.replace(/&/g, "&amp;");
        str = str.replace(/</g, "&lt;");
        str = str.replace(/>/g, "&gt;");
        return str;
    }
    
    function buildSelection(keepStyle) {
        var str = "";
        try {
            var selection = window.getSelection();
            var range = null;
            if(selection == null || selection.rangeCount == 0)
           {
               // If we have previewed selection but user cancel the selection by mistake before posting, we still use previewed selection.
               range = contentPreview.getPreviewedRange();
              //console.log("selection range: " + range);
            }
            else
            {
                range = selection.getRangeAt(0);
            }
            
            if (range) 
            {
                 //console.log("range commonAncestorContainer" + range.commonAncestorContainer);
                 // http://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#ranges
                if (range.commonAncestorContainer.nodeType == Node.TEXT_NODE || typeof range['intersectsNode'] == "undefined") {
                        str = range.commonAncestorContainer.textContent.substring(range.startOffset, range.endOffset);
                        complete(escapeHTML(str));
                    }
                else 
                {
                        serializer.serialize(range.commonAncestorContainer, range, keepStyle, complete);
                }
                 return;
            }
            else
            {
                 complete("");    
            }
        }
        catch(e) {
            console.log("buildSelection" + e);
            complete("");
        }
    }
    
    function complete(str)
    {
        console.log("Convert to enml completed..");
        note.content = str;
        nativeBridge.call("clipComplete", _jsCallId);
    }
 
    function noteContent()
    {
        return note.content;
    }
 
    function installed()
    {
        return true;
    }
 
    function resetSerializer()
     {
        console.log("resetSerializer");
         serializer.cancelPollForStyleSheets();
         // Cancel recursing if error happens at last clipper
         serializer.doneRecursing("");
     }
 
    this.clipFullPage = clipFullPage;
    this.clipArticle = clipArticle;
    this.clipSelection = clipSelection;
    this.installed = installed;
    this.noteContent = noteContent;
    this.resetSerializer = resetSerializer;
}

 var console;
 
 if (SAFARI)
 {
     console = new Console();
 }
 else
 {
     console = window.console;
 }
 
 window.pageInfo = new PageInfo();

 window.contentPreview = new ContentPreview();

 window.clipper = new Clipper();
 
 
 /* 
 * How this HTML serializer works:
 *
 * The serialization of the document structure itself in here is fairly straightforward: it's a recursive descent
 * parser that will serialize HTML into ENML-ready markup. It converts unknown elements into generic equivalents, drops
 * prohibited elements, copies attributes across (unless they're restricted) and basically does what you'd expect, with
 * the following exceptions:
 * 
 * It breaks every N nodes serialized and fires off a callback (via setTimeout) to resume in a few milliseconds.
 * This has a couple important properties. It keeps the UI from blocking completely while the serializer runs (but
 * still makes it sluggish), and more importantly, it keeps browsers from deciding that the script on the page is
 * spinning and prompting the user to kill it.
 * 
 *
 * CSS: The interesting portion of how this whole things works is how it goes about inlining stylesheets. The core of
 * this is built on an API called getMatchedCSSRules (webkit-only, for other browsers, there is another implementation
 * in here built around matchesSelector, which is both much slower and probably not kept in sync with the primary
 * version). 
 * 
 * Calling getMatchedCSSRules will give you a list of all the CSS rules that apply to your element, but with some
 * caveats: noticeably, you wont get back rules from stylesheets that you wouldn't normally be able to load yourself
 * due to the same-origin policy. These are just silently omitted. To get around this, we start our serialization
 * process by iterating across all the stylesheets attached to the document, and if they are link elements with 'href'
 * properties, we'll pass a message to the extension page asking it to request that URL on our behalf (because the
 * background page in an extension is not subject to the same origin policy). We don't need to bother for styles in
 * "style" tags because they can't have same-origin policy issues. We also run through each rule in each stylesheet and
 * if it's an @import rule, we'll send off a request for that stylesheet as well. We keep a list of stylesheets
 * requested and wont request duplicates, and will give up at a max of 100 total stylesheets (fun fact: @import rules
 * can be circular).
 * 
 * The background page will return us a message with the result from each requested stylesheet. We create a "style"
 * tag, and then insert the text from the request in there, and append the new style element to the page. We then fire
 * off a polling function that waits for a new item to show up in document.styleSheets that references the style tag we
 * just added. When that shows up, we'll run the newly attached styleSheet object through our @import check again to
 * see if we need to grab any more stylesheets from there.
 *
 * If the polling function gets to the point that there are no more outstanding requests, it stops its own polling and
 * fires off the recursive serializer.
 *
 * At each node in the tree, we grab the list of matching CSS rules, which will now include all the ones from the style
 * tags that we added from originally third-party stylesheets, and grab the CSS *text* from each one, rather than the
 * parsed CSS representation. This will let us keep properties like "border" without expanding it out into
 * "border-(top|bottom|left|right)", and it will also keep "invalid" styles that the webkit parser would otherwise drop
 * (like properties beginning with "-moz-"). We parse this CSS text into name/value pairs, and expand out any URLs
 * referenced into absolute paths (important note, relative paths need to be made absolute relative to the path of the
 * stylesheet, not the document).
 * 
 * As we iterate through each matching rule, we let matching properties from later rules overwrite matched properties
 * from earlier rules. This may not strictly be correct, the order in which matching rules are returned is unspecified,
 * ideally we could sort them, but the logic for doing this is actually non-trivial, and it rarely makes a difference
 * anyway.
 *
 * Once we finish checking each matched CSS rule, we have a final name/value map containing all the CSS properties that
 * we want to keep. We serialize this into a "style" attribute and add it to our element, and then move on to serialize
 * its children.
 */

function HtmlSerializer() {
  "use strict";

  var pendingStyleCount = 0;
  var styleSheetList = [];
  var element;
  var range;
  var keepStyle;
  var callbacks = [];
  var stylesToRemove = [];
  var iterationCount = 0;
  var stack = [];
  var blocked = false;
  var pseudoElementRules = [];

  // getMatchedCSSRules seems to fail on pages with a base specified, so if we find a base tag, then we temporarily
  // remove it from the document and store it here. This only works in Chrome, in Safari getMatchedCSSRules still
  // doesn't work, even if we remove this, so there is a separate check for Safari, so that we won't use
  // getMatchedCSSRules on pages with BASE tags.
  var base = null;

  var maxStylesToAdd = 100;
  var stylesAdded = [];

  // Teseting only.
  var timerStart, timerEnd;

  var allowedElements = [
    "A",
    "ABBR",
    "ACRONYM",
    "ADDRESS",
    "AREA",
    "B",
    "BDO",
    "BIG",
    "BLOCKQUOTE",
    "BR",
    "CAPTION",
    "CENTER",
    "CITE",
    "CODE",
    "COL",
    "COLGROUP",
    "DD",
    "DEL",
    "DFN",
    "DIV",
    "DL",
    "DT",
    "EM",
    "FONT",
    "H1",
    "H2",
    "H3",
    "H4",
    "H5",
    "H6",
    "HR",
    "I",
    "IMG",
    "INS",
    "KBD",
    "LI",
    "MAP",
    "OL",
    "P",
    "PRE",
    "Q",
    "S",
    "SAMP",
    "SMALL",
    "SPAN",
    "STRIKE",
    "STRONG",
    "SUB",
    "SUP",
    "TABLE",
    "TBODY",
    "TD",
    "TFOOT",
    "TH",
    "THEAD",
    "TITLE",
    "TR",
    "TT",
    "U",
    "UL",
    "VAR",
    "XMP"
  ];

  var disallowedElements = [
    "APPLET",
    "BASE",
    "BASEFONT",
    "BGSOUND",
    "BLINK",
    "BODY",
    "BUTTON",
    "DIR",
    "EMBED",
    "FIELDSET",
    "FORM",
    "FRAME",
    "FRAMESET",
    "HEAD",
    "HTML",
    "IFRAME",
    "ILAYER",
    "INPUT",
    "ISINDEX",
    "LABEL",
    "LAYER,",
    "LEGEND",
    "LINK",
    "MARQUEE",
    "MENU",
    "META",
    "NOEMBED", /* ENML doesn't support this, so we drop it to keep it from rendering, since it's unlikely to apply. */
    "NOFRAMES",
    "NOSCRIPT",
    "OBJECT",
    "OPTGROUP",
    "OPTION",
    "PARAM",
    "PLAINTEXT",
    "SCRIPT",
    "SELECT",
    "STYLE",
    "TEXTAREA",
    "XML"
  ];

  // In addition to the following, any attribute beginning with "on" is disallowed.
  var disallowedAttributes = [
    "id",
    "class",
    "accesskey",
    "data",
    "dynsrc",
    "tabindex",
    "style" // We strip style attributes because we build our own.
  ];

  // Properties we'll strip from ancestor elements to the main element being serialized. We want to keep inheritable
  // properties on these, like fonts and colors, but lose positioning.
  var strippableProperties = [
    "border",
    "border-bottom",
    "border-bottom-color",
    "border-bottom-style",
    "border-bottom-width",
    "border-collapse",
    "border-color",
    "border-left",
    "border-left-color",
    "border-left-style",
    "border-left-width",
    "border-right",
    "border-right-color",
    "border-right-style",
    "border-right-width",
    "border-spacing",
    "border-style",
    "border-top",
    "border-top-color",
    "border-top-style",
    "border-top-width",
    "border-width",
    "bottom",
    "clear",
    "display",
    "float",
    "height",
    "layout-flow",
    "layout-grid",
    "layout-grid-char",
    "layout-grid-char-spacing",
    "layout-grid-line",
    "layout-grid-mode",
    "layout-grid-type",
    "left",
    "margin",
    "margin-bottom",
    "margin-left",
    "margin-right",
    "margin-top",
    "max-height",
    "max-width",
    "min-height",
    "min-width",
    "padding",
    "padding-bottom",
    "padding-left",
    "padding-right",
    "padding-top",
    "position",
    "right",
    "size",
    "table-layout",
    "top",
    "visibility",
    "width",
    "z-index"
  ];

  function attributeAllowed(attrName) {
    attrName = attrName.toLowerCase();
    if (attrName.match(/^on/)) return false;
    return (disallowedAttributes.indexOf(attrName) == -1);
  }

  function nodeAllowed(nodeName) {
    nodeName = nodeName.toUpperCase();
    return (disallowedElements.indexOf(nodeName) == -1);
  }
 
 function transformNode(node) {
 var nodeName = node.nodeName;
 nodeName = nodeName.toUpperCase();
 if (nodeName == "INPUT" && node.type && node.type.toLowerCase() == "image") {
 return "img";
 }
 // If there's special handling for this type, put it here.
 if (nodeName == "BODY") return "div";
 if (nodeName == "HTML") return "div";
 if (nodeName == "FORM") return "div";
 if (nodeName == "LABEL") return "span";
 if (nodeName == "FIELDSET") return "div";
 if (nodeName == "LEGEND") return "span";
 if (nodeName == "SECTION") return "div";
 // if (nodeName == "IFRAME") return "div";
 // If the node's not allowed, we want to make sure we reutn it as is, so nothing thinks it's supposed to be the
 // transformed type.
 if (!nodeAllowed(nodeName)) {
 return nodeName.toLowerCase();
 }
 // If it's not specifically allowed, either, then we'll turn it into a span, this preserves the content of special
 // node types from HTML5 and the future.
 if (allowedElements.indexOf(nodeName) == -1) {
 return "span";
 }
 // Anything else gets returned as is.
 return nodeName.toLowerCase();
 }
 
  /*
  Browser.addMessageHandlers({
    content_textResource: msgHandlerTextResource
  });*/

  function serialize(_element, _range, _keepStyle, callback) {
    if (callback) {
      callbacks.push(callback);
    }
    if (!blocked) {
      blocked = true;
      element = _element;
      range = _range;
      keepStyle = _keepStyle;
      checkStyleSheets();
    }
    else {
      console.warn("Called serialize while blocked. Added callback but won't change base element.");
    }
  }

  function checkStyleSheet(sheet) {
    if (!usableMedia(sheet)) {
      return;
    }
    if (stylesAdded.length >= maxStylesToAdd) {
      console.warn("Hit style cap of " + maxStylesToAdd + " styles. Stopping.");
      return;
    }

    // This is probably third party, which is why we can't read the rules (because of the same origin policy).
    if (!sheet.cssRules && sheet.href) {
      styleSheetList.push({href: sheet.href, owner: sheet.ownerNode});
 console.log("checkStyleSheet pendingStyleCount++ 111111111");
      pendingStyleCount++;
      stylesAdded.push(sheet.href);
        
      httpRequest.send(sheet.href, handleRemoteCssReturn);  
      //Browser.sendToExtension({name: "main_getTextResource", href: sheet.href});
      return;
    }

    // Prepend any @imports.
    var rules = sheet.cssRules;
    for (var j = 0; j < rules.length; j++) {
      if (rules[j].type == CSSRule.IMPORT_RULE) {

        if (stylesAdded.indexOf(rules[j].styleSheet.href) != -1) {
          continue; // Duplicate (a fun case was when these were circular).
        }

        styleSheetList.push({href: rules[j].styleSheet.href, owner: sheet.ownerNode});
 console.log("checkStyleSheet pendingStyleCount++ 22222222222");
        pendingStyleCount++;
        stylesAdded.push(rules[j].styleSheet.href);
        httpRequest.send(rules[j].styleSheet.href, handleRemoteCssReturn);
        //Browser.sendToExtension({name: "main_getTextResource", href: rules[j].styleSheet.href});
      }

      else if (rules[j].type == CSSRule.MEDIA_RULE) {
        if (usableMedia(rules[j])) {
          styleSheetList.push(rules[j]);
        }
      }
    }

    // If we get this far, we want to keep this stylesheet, too.
    styleSheetList.push(sheet);
  }

  function checkStyleSheets() {
 pendingStyleCount = 0;
 var styleSheetCount = document.styleSheets.length;
 for (var i = 0; i < styleSheetCount; i++) {
 checkStyleSheet(document.styleSheets[i]);
 }
 
    console.log("pendingStyleCount:" + pendingStyleCount);
    if (pendingStyleCount == 0) {
      startRecurse(element);
    }
  }

  function reconstituteUrl(base, match, url) {
    var reconstituted;
    url = url.trim(); // for cases like: url( http://www.com/ )
    if (url.match(/^http/i)) {
      reconstituted = url;
    }
    else if (url.match(/^\//)) {
      reconstituted = base.replace(/^(.*?:\/\/[^\/]+).*$/, "$1") + url;
    }
    else {
      reconstituted = base.replace(/^(.*\/)/, "$1") + url;
    }
    reconstituted = "url('" + reconstituted + "')";
    return reconstituted;
  }

  // We need to make our style tag match our original stylesheet.
  function preProcessStyle(styleText, originatingSheetHref) {

    var pageBase = document.location.href.replace(/[^\/]+$/, "");
    var styleBase = originatingSheetHref.replace(/[^\/]+$/, "");

    if (pageBase == styleBase) {
      return styleText;
    }

    // This first block repairs URL paths.  
    // call reconstituteUrl, but prepend the original base URL to its arguments list.
    function reconstitute() {
      var args = [styleBase];
      for (var i = 0; i < arguments.length; i++) args.push(arguments[i]);
      return reconstituteUrl.apply(this, args);
    }
    if (styleText) {
      styleText = styleText.replace(/url\(["']?(.*?)["']?\)/g, reconstitute);
    }

    return styleText;
  }

  var outstandingStyleSheets = [];
  var styleInterval = 0;
  function pollForStyleSheets(){
//   console.log('pollForStyleSheets styleInterval: ' + styleInterval);
    if (styleInterval) return;
    styleInterval = setInterval(function() {

                                console.log('Interval start stylesAdded.length: ' + stylesAdded.length + '/100');
                                
      if (stylesAdded.length >= maxStylesToAdd) {
                                console.log('Interval start stylesAdded.length >= maxStylesToAdd');
        cancelPollForStyleSheets();
        startRecurse(element);
                                
        console.log("stylesAdded.length >= maxStylesToAdd, start directly ");
        return;
      }

                                var len = outstandingStyleSheets.length
      OUTER: for (var i = 0; i < len; i++) {
                                console.log('Interval start i-loop:' + i);
        var style = outstandingStyleSheets[i][0];

        var idx = outstandingStyleSheets[i][1];
                                var stylesheetsCount = document.styleSheets.length;
        for (var j = 0; j < stylesheetsCount; j++) {
                                console.log('Interval start j-loop:' + j);
          var sheet = document.styleSheets[j];
                                
//console.log('Interval start j-loop style:' + style + 'innerHTML: ' + style.innerHTML);
//
//console.log('Interval start j-loop sheet.ownerNode:' + sheet.ownerNode + 'innerHTML: ' + sheet.ownerNode.innerHTML);
                                
//          if (sheet != null && sheet.ownerNode != null && sheet.ownerNode.innerHTML === style.innerHTML) {
            if (sheet.ownerNode === style) {
                                console.log("Interval style match!!!");
            styleSheetList[idx] = sheet;
            checkStyleSheet(document.styleSheets[j]);
            outstandingStyleSheets.splice(i, 1);
                                console.log("Interval pendingStyleCount--: " + pendingStyleCount);
            pendingStyleCount--;
            break OUTER;
            }else{
            console.log("Interval style NOT match!!!");
            }
        }
      }
      
      console.log("pollForStyleSheets pendingStyleCount: " + pendingStyleCount)
      if (pendingStyleCount == 0) {
        cancelPollForStyleSheets();
        startRecurse(element);
      }
    }, 50);
  }

  function cancelPollForStyleSheets() {
    if (styleInterval) {
      clearInterval(styleInterval);
      styleInterval = 0;
    }
  }
                                           
                                           
 function handleRemoteCssReturn(href, responseText)
{
    console.log('handleRemoteCssReturn:' + href + ' styleSheetList.length: ' + styleSheetList.length);
                                           
    for (var i = 0; i < styleSheetList.length; i++) 
    {
                                           console.log('handleRemoteCssReturn loop: ' + i);
        var sheet = styleSheetList[i];
         console.log('candidate[' + i + ']:' + sheet.href);
                                           
        if (sheet.href != null && sheet.href.toString == href.toString)
        /*
         * Exception url: http://www.lemonde.fr/europe/article/2012/12/12/italie-berlusconi-se-dit-pret-a-se-retirer-en-cas-de-candidature-de-monti_1805292_3214.html
         */
//       if (sheet.href === href)
        {
           console.log("href matched!!!");
           var style = document.createElement("style");
           style.type = "text/css";

           var styleText = null;
           if(responseText != null)
               styleText = preProcessStyle(responseText, sheet.href);
                                           
           style.textContent = styleText;
            
            // jhuang: some sie doesn't work with this, e.g.ipad.sina.com.cn . just remove it for now.
            //style.dataset["evernoteOriginatingUrl"] = sheet.href;
                                           
            // Save the current list, as the new style will get inserted at some unknown point in the list, and we'll have
            // to pick it out.
            var savedStyles = [];
            for (var j = 0; j < document.styleSheets.length; j++)
            {
              savedStyles.push(document.styleSheets[j]);
            }
                              
            
                                           
             if (sheet.owner) 
             {
                 sheet.owner.parentNode.insertBefore(style, sheet.owner);
             }
             else 
             {
                  document.head.appendChild(style);
             }
             
             stylesToRemove.push(style);
                                           
             outstandingStyleSheets.push([style, i]);
             console.log("start pollForStyleSheets");
             pollForStyleSheets();
             console.log("end pollForStyleSheets");                              
             return;
          }
           else{
            console.log('href NOT matched!!!');
           }
      }
                                           
      // @TODO: Would be nice to know why this happens.
                                           console.warn("Unsolicited text resource. Ignoring.");
 }

  // "screen" and "all" are usable, and no media at all is a default of "screen".
  function usableMedia(stylesheet) {
    if (stylesheet.media && stylesheet.media.length) {
      for (var j = 0; j < stylesheet.media.length; j++) {
        var m = stylesheet.media[j].toLowerCase();
        if (m.match(/\bscreen\b/i) || m.match(/\ball\b/i)) {
          return true;
        }
      }
      return false;
    }
    return true;
  }

  function postProcessStyles() {
    pseudoElementRules = [];
    for (var i = 0; i < styleSheetList.length; i++) {
      var sheet = styleSheetList[i];
      if (!sheet.cssRules) {
        continue;
      }
      for (var j = 0; j < sheet.cssRules.length; j++) {
        var rule = sheet.cssRules[j];
        if (rule.selectorText && rule.selectorText.match(/(:?:before)|(:?:after)/)) {
          pseudoElementRules.push(rule);
        }
      }
    }
  }

  function startRecurse(el) {
    // Styles don't seem to get resolved instantly all the time, so we introduce a small delay and hope that helps.
    setTimeout(function() {
      postProcessStyles();
      timerStart = new Date();
      stack = [];
      stack.push({element: el, string: "", i: 0, after: null});
      recurse();
    }, 300);
  }

  function escapeHTML(str){ 
    str = str.replace(/&/g, "&amp;");
    str = str.replace(/</g, "&lt;");
    str = str.replace(/>/g, "&gt;");
    return str;
  }

  function serializeYoutubeVideo(el) {
    if (el.className.match(/flash-player/) && el.id.match(/watch-player/)) {
      if (document.location.href.match(/v=(.*?)(&|$)/)) {
        var vidId = document.location.href.match(/v=(.*?)(&|$)/)[1];
        return "<a href='" + document.location.href + "'><img src='http://img.youtube.com/vi/" + vidId +
          "/0.jpg'/></a>";
      }
    }
    return "";
  }

  // If we try to serialize a DL that contains elements other than DD or DT, the server will try to coerce this into
  // valid HTML by auto-closing our list. Instead, we simply discard invalid elements here.
  // This function returns true if this is a valid DD or DT or isn't a child of a DL. It returns false if this is an
  // invalid DL child.
  function checkValidDlChild(el) {
    if (el.parentNode) {
      var parentName = el.parentNode.nodeName;
      parentName = parentName.toLowerCase();
      if (parentName == "dl") {
        var normalized = transformNode(el);
//       var normalized = transformNode(el.nodeName);
        if (normalized != "dd" && normalized != "dt") {
          return false;
        }
      }
    }
    return true;
  }

  function recurse() {
   console.warn("recurse <----: " + iterationCount);
    iterationCount++;                                           
//                                           console.warn("recurse 11111111111111");
    if (iterationCount % 500 == 0) {
//           console.warn("recurse Call recurse 1");
      setTimeout(recurse, 25);
//                                           console.warn("recurse setTimeout");
      return;
    }

//                                           console.warn("recurse 222222222222");
    // We're not allowed to create variables in here (they need to be on our stack), but this is just a convenience
    // mapping. (f == frame);
    var f = stack[stack.length - 1];
//                                           console.warn("recurse 33333333333333");
    if (!f) {
      // This can occur in strange cases, like we have a page that uses frames, but the frame we would choose as the
      // main content area fails the same-origin-policy check. We'll get a blank note, but at least not hang.
      doneRecursing("");
    }
//console.warn("recurse 444444444444");
    // We haven't gotten into any of our children yet.
    if (f.i == 0) {

      // This particular 'if' block isn't interruptable. Any vars declared in here must only live in here.
      if (!nodeAllowed(transformNode(f.element))) {
//       if (!nodeAllowed(transformNode(f.element.nodeName))) {
        stack.pop();
//                                           console.warn("recurse Call recurse 2");
        recurse();
//                                           console.warn("recurse return 1");
        return;
      }
//console.warn("recurse 5555555555");
      if (!checkValidDlChild(f.element)) {
//        console.warn("discarding invalid DL child \"" + f.element.nodeName + "\"");
        stack.pop();
        recurse();
        return;
      }
//console.warn("recurse 666666666");
                                           try{
                                           if (range && f.element != range.commonAncestorContainer && !range.intersectsNode(f.element)) {
//                                            if (range && f.element != range.commonAncestorContainer) {
//                                           console.warn("recurse 666666666 aaaaaaaaaaaa");
                                           stack.pop();
//                                           console.warn("recurse Call recurse 3");
                                           recurse();
//                                           console.warn("recurse return 2");
                                           return;
                                           }
                                           }
                                           catch(e){
//                                           console.warn('' + e);
                                           }
      
//      console.warn("recurse 7777777777");
      // Drop trailing paragraphs that you get when you triple-click to select.
      if (range && f.element === range.endContainer && range.endOffset === 0) {
        stack.pop();
//                                           console.warn("recurse Call recurse 4");
        recurse();
//                                           console.warn("recurse return 3");
        return;
      }
//console.warn("recurse 8888888888");
      var ytvid = serializeYoutubeVideo(f.element);
//                                           console.warn("recurse 9999999999");
      if (ytvid) {
        f.string += ytvid;
        stack.pop();
        if (stack.length) {
          stack[stack.length - 1].string = f.string;
//                                           console.warn("recurse Call recurse 5");
          recurse();
        }
        else {
//                                           console.warn("recurse out 111111");
          doneRecursing(f.string);
        }
//                                           console.warn("recurse return 4");
        return;
      }
//console.warn("recurse aaaaaaaaaaaaa");
      var style = {};
      if (keepStyle) {

        style = resolveStyle(f.element);
        if (style.after) f.after = style.after;
      }
//console.warn("recurse bbbbbbbbbbbb");
      if (style.map && style.map.display && style.map.display.value == "none") {
        // Skipping hidden element.
        stack.pop();
//                                           console.warn("recurse Call recurse 6");
        recurse();
//                                           console.warn("recurse return 5");
        return;
      }
//console.warn("recurse cccccccccccccc");
       f.string += "<" + transformNode(f.element);
//      f.string += "<" + transformNode(f.element.nodeName);

      specifyImgDims(f.element);
      if (f.element.attributes && f.element.attributes.length) {
        for (f.i = 0; f.i < f.element.attributes.length; f.i++) {
          if (attributeAllowed(f.element.attributes[f.i].name)) {
            f.string += " " + transformAttribute(f.element, f.element.attributes[f.i]);
          }
        }
      }
//console.warn("recurse ddddddddddddd");
      if (keepStyle) {
        f.string += style.style;
      }
      f.string += ">";

      if (keepStyle) {
        if (style.before) {
          f.string += style.before;
        }
      }

      f.i = 0;
    }
//console.warn("recurse eeeeeeeeeeeeeeeee f.element.childNodes.length: " + f.element.childNodes.length);
    while (f.i < f.element.childNodes.length) {
//                                           console.warn("recurse fffffffffffff node: " + f.i + " type: " + f.element.childNodes[f.i].nodeType);
      if (f.element.childNodes[f.i].nodeType == Node.TEXT_NODE) {
        var text;

        if (range && f.element.childNodes[f.i] === range.startContainer) {
          text = escapeHTML(f.element.childNodes[f.i].textContent.substr(range.startOffset));
        }
        else if (range && f.element.childNodes[f.i] === range.endContainer) {
          text = escapeHTML(f.element.childNodes[f.i].textContent.substr(0, range.endOffset));
        }
        else if (range && !range.intersectsNode(f.element.childNodes[f.i])) {
          text = "";
        }
        else {
          text = escapeHTML(f.element.childNodes[f.i].textContent);
        }
        // text = text.replace(/\s+/g, " "); // @TODO: Enable in production.
        f.string += text;
        f.i++;
      }
      else if(f.element.childNodes[f.i].nodeType == Node.ELEMENT_NODE) {
        stack.push({element: f.element.childNodes[f.i], string: f.string, i: 0, after: null});
        f.i++;
//                                           console.warn("recurse Call recurse 7");
        recurse();
//                                           console.warn("recurse return 6");
        return;
      }
      else {
        f.i++;
      }
//                                           console.warn("recurse gggggggggggg");
    }
//console.warn("recurse hhhhhhhhhhhh");
    if (keepStyle) {
      if (f.after) {
        f.string += f.after;
      }
    }
//console.warn("recurse iiiiiiiiiiiiiiiiiiii");
    f.string += "</" + transformNode(f.element) + ">";
//    f.string += "</" + transformNode(f.element.nodeName) + ">";

    stack.pop();
    if (stack.length) {
      stack[stack.length - 1].string = f.string;
//                                           console.warn("recurse Call recurse 8");
      recurse();
    }
    else {
//                                           console.warn("recurse out 22222");
      doneRecursing(f.string);
    }
//                                           console.warn("recurse ------>");
  }

  // If someone specifies "background: 0" in CSS, chrome expands that out to:
  // background-position: 0px 50%; background-repeat: initial initial;
  // We restore the original here.
  function rebackgroudifyCss(map) {
    if (map["background-position"] && map["background-repeat"]) {
      if (map["background-position"].trim() == "0px 50%" && map["background-repeat"].trim() == "initial initial") {
        for (var prop in map) {
          if (prop.match(/background/)) {
            delete map[prop];
          }
        }
        map["background"] = "0";
      }
    }
  }
  // @TODO: this is almost certainly horribly incomplete. NOTE: Actually it works remarkably well.
  function parseCssText(str) {
    var val = {};
    var props = str.split(/;\s*/);
    for (var i = 0; i < props.length; i++) {
      props[i] = props[i].trim();
      if (props[i]) {
        var splitIdx = props[i].indexOf(":");
        var name = props[i].substr(0, splitIdx).trim();
        var value = props[i].substr(splitIdx + 1).trim();
        if (name && value) val[name.toLowerCase()] = value;
      }
    }
    rebackgroudifyCss(val);
    return val;
  }

  function objectifyCssRule(rule) {
    var styleMap = {};
    if (rule.style.cssText) {
      var styles;
      if (!rule.style.savedCssObj) {
        rule.style.savedCssObj = parseCssText(rule.style.cssText);
      }
      styles = rule.style.savedCssObj;

      for (var k in styles) {
        styleMap[k] = styles[k];
      }
    }
    return styleMap;
  }

  function specifyImgDims(el) {
    if (el.nodeName.toLowerCase() == "img") {
      if (!el.attributes.width) {
        el.setAttribute("width", el.width);
      }
      if (!el.attributes.height) {
        el.setAttribute("height", el.height);
      }
    }
  }

  // ================================================================================================================
  // The following block does "slow" CSS resolution, where getMatchedCSSRules doesn't exist.
  // This is *incredibly slow* compared to the normal version, by orders of magnitude.
  function resolveRule(rule, el, ruleList) {
    try {

      // @TODO: Move this somewhere else, we don't really want to be re-doing thing resolution on every single match
      // attempt. Handily, it doesn't matter in webkit, since we have getMatchedCSSRules and will be using "fast"
      // resolution.
      var matches = false;
//      if (el.matchesSelector) matches = el.matchesSelector(rule.selectorText);
//      else if (el.mozMatchesSelector) matches = el.mozMatchesSelector(rule.selectorText);
//      else if (el.webkitMatchesSelector) matches = el.webkitMatchesSelector(rule.selectorText);

       if (el.webkitMatchesSelector) matches = el.webkitMatchesSelector(rule.selectorText);
                                           
      if (matches) {
        ruleList.push(rule);
      }
    }
    catch (e) { }
  }

  function resolveSheet(sheet, el, ruleList) {
    for (var j = 0; j < sheet.cssRules.length; j++) {
      resolveRule(sheet.cssRules[j], el, ruleList);
    }
  }

  function getMatchedCSSRulesSlow(el) {
    var rules = [];
    for (var i = 0; i < styleSheetList.length; i++) {
      var sheet = styleSheetList[i];

      // Skip any sheet with no rules.
      if (!sheet.cssRules) continue;
      resolveSheet(sheet, el, rules);
    }
    return rules;
  }

   function getAppliedSelectors(node) {
   var selectors = [];
   var rules = node.ownerDocument.defaultView.getMatchedCSSRules(node, '');
   
   var i = rules.length;
   while (i--) {
   selectors.push(rules[i].selectorText);
   }
   return selectors;
   }
                                           
  // @TODO: This is wrong for comma-separated selectors. We should split them and check each one individually.
  function getSelectorSpecificity(sel) {
    var matchers = {
      "ids": {
        "regex": /#[A-Z]+/ig,
        "count": 0
      },
      "classes": {
        "regex": /\.[A-Z]+/ig,
        "count": 0
      },
      "attrs": {
        "regex": /\[.*?\]/g,
        "count": 0
      },
      "pseudos": {
        "regex": /:+[A-Z]+/ig,
        "count": 0
      },
      "pseudoEls": {
        "regex": /:+(first-line|first-letter|before|after)/ig,
        "count": 0
      },
      "types": {
        "regex": /(^|\s)[A-Z]+/ig,
        "count": 0
      }
    }

    for (var i in matchers) {
      var re = matchers[i].regex;
      while (re.exec(sel)) {
        matchers[i].count++;
      }
    }

    matchers.pseudoClasses = {};
    matchers.pseudoClasses.count = matchers.pseudos.count - matchers.pseudoEls.count;

    var first = matchers.ids.count;
    var second = matchers.classes.count + matchers.attrs.count + matchers.pseudoClasses.count;
    var third = matchers.types.count + matchers.pseudoEls.count;

    var score = (first * 256 * 256) + (second * 256) + third;

    return score;
  }

  function splitSelectorList(sel) {
    var sels = [];
    var lastStart = 0;
    var i = 0;
    var quoted = "";
    for (i = 0; i < sel.length; i++) {
      if (!quoted) {
        if (sel[i] == "'" || sel[i] == "\"") {
          quoted = sel[i];
        }
        else if (sel[i] == ",") {
          sels.push(sel.substring(lastStart, i).trim());
          lastStart = i + 1;
        }
      }
      else {
        if (sel[i] == quoted) {
          quoted = "";
        }
      }
    }
    sels.push(sel.substr(lastStart).trim());
    return sels;
  }

  // Properties listed here http://www.w3.org/TR/CSS21/propidx.html that are both 'visual' and inherited. This is used
  // to handle inheritance into generated content blocks properly. Note that this is a list from CSS 2.1 and may miss
  // items that were added in CSS3.
  var inheritableCSSProperties = {
    'border-collapse': true,
    'border-spacing': true,
    'caption-side': true,
    'color': true,
    'cursor': true,
    'direction': true,
    'empty-cells': true,
    'font-family': true,
    'font-size': true,
    'font-style': true,
    'font-variant': true,
    'font-weight': true,
    'font': true,
    'letter-spacing': true,
    'line-height': true,
    'list-style-image': true,
    'list-style-position': true,
    'list-style-type': true,
    'list-style': true,
    'orphans': true,
    'quotes': true,
    'text-align': true,
    'text-indent': true,
    'text-transform': true,
    'visibility': true,
    'white-space': true,
    'widows': true,
    'word-spacing': true
  };
  function cssPropertyIsInheritable(property) {
    if (inheritableCSSProperties[property.toLowerCase()]) {
      return true;
    }
    return false;
  }

  function fixQuirksModeTableInheritance(el, map) {
    var nodeName = el.nodeName.toLowerCase();
    if (nodeName == "table" || nodeName == "caption") {
      if (document.compatMode == "CSS1Compat") {
        // console.log("standards mode document, forcing table inheritance.");
        map["font-size"] = {value: "inherit", score: 0};
        map["font-weight"] = {value: "inherit", score: 0};
        map["font-style"] = {value: "inherit", score: 0};
        map["font-variant"] = {value: "inherit", score: 0};
      }
    }
  }

  // @TODO: there are almost certainly more to add here.
  function clearOverridden(name, map) {
    if (name == "padding") {
      delete map["padding-top"];
      delete map["padding-bottom"];
      delete map["padding-left"];
      delete map["padding-right"];
    }

    else if (name == "margin") {
      delete map["margintop"];
      delete map["margin-bottom"];
      delete map["margin-left"];
      delete map["margin-right"];
    }
  }

  // ================================================================================================================
  // And the following block does "fast" CSS resolution, where we can call getMatchedCSSRules, which is currently (and
  // maybe always will be) Webkit-only.
  function resolveStyle(el, stripStyleList) {

    // getMatchedCSSRules doesn't work if the page has a BASE tag. In chrome, this can be resolved by temporarily
    // detaching the BASE tag. In Safari, that won't fix it at all.
    base = document.querySelector("base");
    if (!SAFARI && base) {
      base.parentNode.removeChild(base);
    }

    var style = "";
    var originalStyle = null;
    var before = {};
    var after = {};
    if (el.attributes && el.attributes.style) {
      originalStyle = parseCssText(el.attributes.style.value);
    }

    var styleMap = {};

    fixQuirksModeTableInheritance(el, styleMap);

    var rules;
    if (window.getMatchedCSSRules && !(SAFARI && base)) {
      rules = getMatchedCSSRules(el);
    }
    else {
      rules = getMatchedCSSRulesSlow(el);
    }
        // !!!:Not work on iOS
//       if (cssRulesMode === CSS_RULES_FAST) {
//       rules = getMatchedCSSRules(el);
//       //      console.log("rules="+rules);
//       //      if (rules) {
//       //        console.log("getMatchedCSSRules length="+rules.length);
//       //      } else {
//       //        console.log("getMatchedCSSRules length=null");
//       //      }
//       } else if(cssRulesMode === CSS_RULES_SLOWER) {
//       rules = el.ownerDocument.defaultView.getMatchedCSSRules(el, '');
//       //      console.log("rules="+rules);
//       //
//       //      if (rules) {
//       //        console.log("getMatchedCSSRulesSlower length="+rules.length);
//       //      } else {
//       //        console.log("getMatchedCSSRulesSlower length=null");
//       //      }
//       }
//       else {
//       rules = getMatchedCSSRulesSlow(el);
//       //      console.log("rules="+rules);
//       //
//       //      if (rules) {
//       //        console.log("getMatchedCSSRulesSlow length="+rules.length);
//       //      } else {
//       //        console.log("getMatchedCSSRulesSlow length=null");
//       //      }
//       }
                                           
    if (rules && rules.length) {
      for (var i = 0; i < rules.length; i++) {

        var specScore = 0;
        var ignoreVisited = false;
        if (rules[i].selectorText.match(/:visited/i)) {
          ignoreVisited = true;
        }

        var selectors = splitSelectorList(rules[i].selectorText);
        for (var j = 0; j < selectors.length; j++) {
          var matches;
          try {
            matches = el.webkitMatchesSelector(selectors[j]);
          }
          catch (e){
            console.warn("Couldn't match against selector " + selectors[j] + " in: " + rules[i].selectorText);
            console.error(e);
          }
          if (matches) {
            ignoreVisited = false; // If we match anything, then we'll ignore whether we matched a visited rule, as
                                   // matchesSelector will always return 'false' for these rules.
            var possibleSpec = getSelectorSpecificity(selectors[j]);
            if (possibleSpec >= specScore) {
              specScore = possibleSpec;
            }
          }
        }

        if (ignoreVisited) {
          // console.log("should ignore visited selector: " + rules[i].selectorText);
          continue;
        }

        var ruleObj = objectifyCssRule(rules[i]);
        for (var k in ruleObj) {

          // Skip invalid properties.
          var jsPropName = k.replace(/^-/, "").replace(/-[a-z]/g, function(str){ return str[1].toUpperCase(); });

          if (!rules[i].style[jsPropName]) {
            if (k == "background") {
              console.log("Would skip background.");
            }
            continue;
          }

          // See if there was a pre=existing score for this property.
          var oldScore = 0;
          if (styleMap[k]) {
            oldScore = styleMap[k].score;
          }

          // Adjusts scores for !important rules.
          var ruleScore = specScore;
          if (ruleObj[k].match(/!important\s*$/i)) {
            ruleScore += (256 * 256 * 256);
            ruleObj[k] = ruleObj[k].replace(/\s*!important\s*$/i, "");
          }
          // Replace if greater or equal.
          if (ruleScore >= oldScore) {
            clearOverridden(k, styleMap);
            styleMap[k] = {value: ruleObj[k], score: ruleScore};
          }
        }
      }
    }

    // For handling "before" and "after" pseudo-elements.
    for (var i = 0; i < pseudoElementRules.length; i++) {
      var rule = pseudoElementRules[i];
      var match;
      if (el.webkitMatchesSelector) {
        match = el.webkitMatchesSelector(rule.selectorText.replace(/(:?:before)|(:?:after)/g, ""));
      }
      if (match) {

        var matchBefore = false;
        var matchAfter = false;
        if (rule.selectorText.match(/:?:before/)) {
          matchBefore = true;
        }
        if (rule.selectorText.match(/:?:after/)) {
          matchAfter = true;
        }

        // Inherit as per: http://www.w3.org/TR/CSS21/generate.html;
        // @TODO: Implement specificity here.
        for (var k in styleMap) {
          if (matchBefore && cssPropertyIsInheritable(k)) {
            before[k] = styleMap[k].value;
          }
          if (matchAfter && cssPropertyIsInheritable(k)) {
            after[k] = styleMap[k].value;
          }
        }
        var generated = objectifyCssRule(rule);
        for (var k in generated) {
          if (matchBefore) {
            before[k] = generated[k];
          }
          if (matchAfter) {
            after[k] = generated[k];
          }
        }
      }
    }

    var sections = [before, after];
    for (var entry = 0; entry < sections.length; entry++) {
      var map = sections[entry];
      var pseudoStyle = "";
      var content = "";
      var count = 0;
      for (var j in map) {
        if (j != "content") {
          pseudoStyle += j + ":" + map[j] + ";";
        }
        else {
          // Ghetto-parses quoted strings, mostly.
          var content = map[j];
          content = content.trim();
          content = content.replace(/\s+!important$/, "");
          if (content == "none") content = "\"\"";
          if (content.match(/^'/)) {
            content = content.replace(/^'(.*?)'.*/, "$1");
          }
          else if (content.match(/^"/)) {
            content = content.replace(/^"(.*?)".*/, "$1");
          }

          if (content.match(/^url\((.*)\)/)) {
            var contentUrl = content.match(/^url\((.*)\)/)[1];
            content = "<img src='" + contentUrl + "'/>";
          }
        }
        count++;
      }
      if (count) {
        pseudoStyle = "<span style=\"" + pseudoStyle + "\">" + content + "</span>";
        if (entry == 0) {
          before = pseudoStyle;
        }
        else {
          after = pseudoStyle;
        }
      }
    }

    // Clear out anything tyhat didn't get set.
    if (typeof before != "string") before = null;
    if (typeof after != "string") after = null;

    // el == element is a special hack to remove padding and such from the main element, so that it doesn't get
    // positioned strangely in our note view.
    if (el == element) {
      stripStyleList = strippableProperties;
    }
    if (stripStyleList) {
      for (var i = 0; i < stripStyleList.length; i++) {
        if (styleMap[stripStyleList[i]]) {
          delete styleMap[stripStyleList[i]];
        }
      }
    }

    // Hacks and adjustments.
    // ================================================================================
    fixHeight(el, styleMap);
    fixUserSelect(styleMap);
    // ================================================================================

    if (originalStyle) {
      var matcher = /url\((.*)\)/i;
      for (var k in originalStyle) {

        // If our style tag contains attrbiutes with URLs, we may need to canonicalize them,
        if (matcher.test(originalStyle[k])) {
          var url = matcher.exec(originalStyle[k])[1];
          var linkBase = document.location.href;
          if (base && base.href) {
            linkBase = base.href;
          }
          var fixed = reconstituteUrl(linkBase, match, url);
          originalStyle[k] = fixed;
        }

        styleMap[k] = {value: originalStyle[k]};
      }
    }

    for (var i in styleMap) {
      style += i + ":" + styleMap[i].value + ";";
    }

    if (style) {
      style = " style=\"" + escapeAttr(style) + "\"";
    }
    else {
      style = "";
    }

    if (!SAFARI && base) {
      document.head.insertBefore(base, document.head.firstChild);
    }
    base = null;

    return {style: style, before: before, after: after, map: styleMap};
  }

  // ================================================================================================================


  // Height percentage adjustment to auto, as per here: 
  // https://developer.mozilla.org/en/CSS/height
  function fixHeight(el, styleMap) {
    if (styleMap["height"] && styleMap["height"].value.match(/%$/)) {
      var fixed = styleMap["height"].value;
      try {
        var containingHeight = el.parentNode.style.height;
        if (!containingHeight) {
          fixed = "auto";
        }
      }
      catch(e) { /*in case we can't resolve the parent's style chain. */ }
      styleMap["height"].value = fixed;
    }
  }

  // This keeps notes modifiable.
  function fixUserSelect(styleMap) {
    var selectProps = [
      "-webkit-user-select",
      "-moz-user-select",
      "-ms-user-select",
      "user-select",
      "-webkit-user-modify",
      "-moz-user-modify",
      "-ms-user-modify",
      "user-modify"
    ];
    for (var i = 0; i < selectProps; i++) {
      if (styleMap[selectProps[i]]) {
        delete styleMap[selectProps[i]];
      }
    }
  }

  function transformAttribute(element, attrObj) {
    var val = null;
    if (attrObj.name.toLowerCase() == "href") {
      // The following magic returns a fully-qualified path for 'href' instead of whatever the DOM says in the 'href'
      // attribute.
      var href = element.href;
      if (href && href.match(/^javascript/i)) href = "#";
      val = escapeAttr(href);
    }
    else if (attrObj.name.toLowerCase() == "src") {
      var src = element.src;
      if (src && src.match(/^javascript/i)) src = "#";
      val = escapeAttr(src);
    }
    
    if (!val) {
      val = escapeAttr(attrObj.value);
    }

    return attrObj.name + "=\"" + val + "\"";
  }

  function restoreAncestors() {
    var front = "";
    var back = "";
    var current = element.parentNode;
    while (current && current.parentNode) {
      var style = resolveStyle(current, strippableProperties).style;
      var type = transformNode(current);
//     var type = transformNode(current.nodeName);

      if (nodeAllowed(type)) {
        front = "<" + type + style + ">" + front;
        back = back + "</" + type + ">";
      }
      current = current.parentNode;
    }

    // Last one, set the base font size
    front = "<div style=\"font-size: 16px\">" + front;
    back = back + "</div>";

    return {front: front, back: back};
  }

  function doneRecursing(str) {
    blocked = false;
    timerEnd = new Date();

    var ancestors = {front: "", back: ""};
    if (keepStyle) {
      ancestors = restoreAncestors();
    }
    str = ancestors.front + str + ancestors.back;

    for (var i = 0; i < stylesToRemove.length; i++) {
      stylesToRemove[i].parentNode.removeChild(stylesToRemove[i]);
    }
    stylesToRemove = [];

    // Testing only.
     // this case means not start yet
     if(typeof timerStart !== "undefined"){
         var clipTime = (Math.round(((timerEnd.valueOf() - timerStart.valueOf()) / 100)) / 10) + "s";
         for (var i = 0; i < callbacks.length; i++) {
         try {
         callbacks[i](str, clipTime);
         }
         catch (e) {
         console.warn("Couldn't run 'serialize' callback: " + JSON.stringify(e));
         }
     }
        
    }
    callbacks = [];
  }

  function escapeAttr(str) {
    if (!str) return "";
    return str.replace(/"/g, "\\\"");
  }

    // Public API
    this.serialize = serialize;
    this.cancelPollForStyleSheets = cancelPollForStyleSheets;
    this.doneRecursing = doneRecursing;
  //Object.preventExtensions(this);
}

//Object.preventExtensions(HtmlSerializer);


 

})();