/*
 * 广告拦截-请求拦截部分
 */

AdBlocker.getFilterFromText = function(text)
{
    text = Filter.normalize(text);
    if (!text)
        throw "Attempted to create a filter from empty text";
    return Filter.fromText(text);
};

/**
 * Notifies Matcher instances or ElemHide object about a new filter
 * if necessary.
 * @param {Filter} filter filter that has been added
 */
AdBlocker.addFilter = function(filter)
{
    if (!(filter instanceof ActiveFilter) || filter.disabled)
        return;
    
    if (filter instanceof RegExpFilter)
        defaultMatcher.add(filter);
    else if (filter instanceof ElemHideBase)
        ElemHide.add(filter);
};

AdBlocker.checkFilterMatch = function(url, contentType, documentHost)
{
    var requestHost = extractHostFromURL(url);
    var thirdParty = isThirdParty(requestHost, documentHost);
    return defaultMatcher.matchesAny(url, contentType, documentHost, thirdParty);
};

/**
 * Maps type strings like "SCRIPT" or "OBJECT" to bit masks
 */
RegExpFilter.typeMap = {
    OTHER: 1,
    SCRIPT: 2,
    IMAGE: 4,
    STYLESHEET: 8,
    OBJECT: 16,
    SUBDOCUMENT: 32,
    DOCUMENT: 64,
    XBL: 1,
    PING: 1,
    XMLHTTPREQUEST: 2048,
    OBJECT_SUBREQUEST: 4096,
    DTD: 1,
    MEDIA: 16384,
    FONT: 32768,
        
    BACKGROUND: 4,    // Backwards compat, same as IMAGE
        
    POPUP: 0x10000000,
    ELEMHIDE: 0x40000000
};

AdBlocker.onBeforeLoad = function(e) {
    if (/^(?!https?:)[\w-]+:/.test(e.url))
        return;
    
    var type = "OTHER";
    var eventName = "error";
    
    switch(e.target.localName)
    {
        case "frame":
        case "iframe":
            type = "SUBDOCUMENT";
            eventName = "load";
            break;
        case "img":
        case "input":
            type = "IMAGE";
            break;
        case "video":
        case "audio":
        case "source":
            type = "MEDIA";
            break;
        case "object":
        case "embed":
            type = "OBJECT";
            break;
        case "script":
            type = "SCRIPT";
            break;
        case "link":
            if (/\bstylesheet\b/i.test(e.target.rel))
                type = "STYLESHEET";
            break;
    }
    var documentHost = (self==top)?extractHostFromURL(document.URL):extractHostFromURL(document.referrer);//处理iframe情况
    if (AdBlocker.whiteList.hasOwnProperty(documentHost)) {
        return;
    };
    var filter = AdBlocker.checkFilterMatch(e.url, type, documentHost);
    if(filter instanceof BlockingFilter) {
        e.preventDefault();
        // Safari doesn't dispatch the expected events for elements that have been
        // prevented from loading by having their "beforeload" event cancelled.
        // That is a "load" event for blocked frames, and an "error" event for
        // other blocked elements. We need to dispatch those events manually here
        // to avoid breaking element collapsing and pages that rely on those events.
        setTimeout(function()
                   {
                   var evt = document.createEvent("Event");
                   evt.initEvent(eventName);
                   e.target.dispatchEvent(evt);
                   }, 0);
        //计数
        setTimeout(function()
                   {
                   window.webkit.messageHandlers.increaseAdBlockCount.postMessage("");
                   }, 0);
        
    }
};

AdBlocker.compileABPRules = function(filterString) {
    //alert("======compileABPRules");
    var lines = filterString.split(/[\r\n]+/);
    for (var i = 0; i < lines.length; i++) {
        var filter = AdBlocker.getFilterFromText(lines[i]);
        AdBlocker.addFilter(filter);
    }
};

window.webkit.messageHandlers.decideAdBlockStatus.postMessage("");
