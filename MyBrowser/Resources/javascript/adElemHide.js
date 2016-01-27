/*
 * 广告拦截-标签拦截部分
 */
var SELECTOR_GROUP_SIZE = 20;

function ElemFilter(domainKey, type, action, tagKey) {
    this.domainKey = domainKey;
    this.type = type;
    this.action = action;
    this.tagKey = tagKey;
};

ElemFilter.prototype =
{
    domainKey: "",
    type: 0,
    action: 0,
    tagKey: "",
    length: 1,
    apply: function() {
        if (this.action == "1") {
            //remove
            if (this.type == "0") {
                var nodeList = document.getElementsByClassName(this.tagKey);
                if (nodeList.length > 0) {
                    for (var i = nodeList.length - 1; i >= 0; i--) {
                        var node = nodeList[i];
                        node.style.display = 'none';
                        node.parentNode.removeChild(node);
                    };
                }
                
            }
            if (this.type == "1") {
                var node = document.getElementById(self.tagKey);
                if (node != null) {
                    node.parentNode.removeChild(node);
                }
            }
            if (this.type == "2") {
                var node = document.getElementById(self.tagKey);
                if (node != null && node.parentNode != null && node.parentNode.parentNode != null) {
                    node.parentNode.parentNode.removeChild(node.parentNode);
                }
            }
        } else if (this.action == "2") {
            //click event
            if (this.type == "0") {
                var nodeList = document.getElementsByClassName(this.tagKey);
                if (nodeList.length > 0) {
                    for (var i = nodeList.length - 1; i >= 0; i--) {
                        var node = nodeList[i];
                        var evt = document.createEvent("MouseEvents");
                        evt.initEvent("click", true, true);
                        node.dispatchEvent(evt);
                    }
                }
                
            }
            if (this.type == "1") {
                var node = document.getElementById(self.tagKey);
                var evt = document.createEvent("MouseEvents");
                evt.initEvent("click", true, true);
                node.dispatchEvent(evt);
                
            }
        }
        
        // Previous sibling.
        else if (this.action == "3") {
            if (this.type == "1") {
                var node = document.getElementById(self.tagKey);
                if (node.previousSibling != null) {
                    node.previousSibling.parentNode.removeChild(node.previousSibling);
                }
            }
        }
        
        // Next sibling.
        else if (this.action == "4") {
            if (this.type == "1") {
                var node = document.getElementById(self.tagKey);
                if (node.nextSibling != null) {
                    node.nextSibling.parentNode.removeChild(node.nextSibling);
                }
            }
        }
        // JS Code
        else if (this.action == "5") {
            eval(this.tagKey);
        }
    }
};

AdBlocker.compileElemHideList = function(elemHideListString) {
    var elemHideList = elemHideListString.split(/[\r\n]+/);
    for (var i = elemHideList.length - 1; i >= 0; i--) {
        var line = elemHideList[i];
        var elemInfo = line.split(",");
        if (elemInfo.length == 4) {
            var filter = new ElemFilter(elemInfo[0], elemInfo[1], elemInfo[2], elemInfo[3])
        	AdBlocker.elemHideList[elemInfo[0]] = filter;

			// Look for a suitable keyword
			var keyword = elemInfo[0];
			var oldEntry = AdBlocker.elemHideList[keyword];
			if (typeof oldEntry == "undefined")
				AdBlocker.elemHideList[keyword] = filter;
			else if (oldEntry.length == 1)
				AdBlocker.elemHideList[keyword] = [oldEntry, filter];
			else
				oldEntry.push(filter);
        };
    };
};

AdBlocker.elemHide = function() {
	if (AdBlocker.enable) {
		for (var domainKey in AdBlocker.elemHideList) {
			if (document.URL.indexOf(domainKey) > -1) {
                var filters = AdBlocker.elemHideList[domainKey];
                if (filters.length == 1) {
                    filters = [filters];
                }
                
                for (var i = filters.length - 1; i >= 0; i--) {
                    var filter = filters[i];
                    filter.apply();
                    
                    //计数
                    setTimeout(function()
                               {
                               window.webkit.messageHandlers.increaseAdBlockCount.postMessage("");
                               }, 0);
                }
			};
		};
	};
}

window.webkit.messageHandlers.decideAdBlockStatus.postMessage("");

window.onload=function()//用window的onload事件，窗体加载完毕的时候
{
    AdBlocker.elemHide();
}

// 以下为adBlockPlus方法
function getSelectors(sendResponse) {
    var selectors = [];
    var documentHost = (self==top)?extractHostFromURL(document.URL):extractHostFromURL(document.referrer);//处理iframe情况
    if (!AdBlocker.whiteList.hasOwnProperty(documentHost)) {
        selectors = ElemHide.getSelectorsForDomain(documentHost, false);
    };
    
    sendResponse(selectors);
}

function reinjectRulesWhenRemoved(document, style)
{
  var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
  if (!MutationObserver)
    return;

  var observer = new MutationObserver(function(mutations)
  {
    var isStyleRemoved = false;
    for (var i = 0; i < mutations.length; i++)
    {
      if ([].indexOf.call(mutations[i].removedNodes, style) != -1)
      {
        isStyleRemoved = true;
        break;
      }
    }
    if (!isStyleRemoved)
      return;

    observer.disconnect();

    var n = document.styleSheets.length;
    if (n == 0)
      return;

    var stylesheet = document.styleSheets[n - 1];
    getSelectors(

      function(selectors)
      {
        while (selectors.length > 0)
        {
          var selector = selectors.splice(0, SELECTOR_GROUP_SIZE).join(", ");

          // Using non-standard addRule() here. This is the only way
          // to add rules at the end of a cross-origin stylesheet
          // because we don't know how many rules are already in there
          stylesheet.addRule(selector, "display: none !important;");
        }
      }
    );
  });

  observer.observe(style.parentNode, {childList: true});
  return observer;
}

function convertSelectorsForShadowDOM(selectors)
{
  var result = [];
  var prefix = "::content ";

  for (var i = 0; i < selectors.length; i++)
  {
    var selector = selectors[i];
    if (selector.indexOf(",") == -1)
    {
      result.push(prefix + selector);
      continue;
    }

    var start = 0;
    var sep = "";
    for (var j = 0; j < selector.length; j++)
    {
      var chr = selector[j];
      if (chr == "\\")
        j++;
      else if (chr == sep)
        sep = "";
      else if (sep == "")
      {
        if (chr == '"' || chr == "'")
          sep = chr;
        else if (chr == ",")
        {
          result.push(prefix + selector.substring(start, j));
          start = j + 1;
        }
      }
    }

    result.push(prefix + selector.substring(start));
  }

  return result;
}

function init(document)
{
  var shadow = null;
  var style = null;
  var observer = null;

  // Use Shadow DOM if available to don't mess with web pages that rely on
  // the order of their own <style> tags (#309).
  //
  // However, creating a shadow root breaks running CSS transitions. So we
  // have to create the shadow root before transistions might start (#452).
  //
  // Also, using shadow DOM causes issues on some Google websites,
  // including Google Docs and Gmail (#1770, #2602).
  if ("createShadowRoot" in document.documentElement && !/\.google\.com$/.test(document.domain))
  {
    shadow = document.documentElement.createShadowRoot();
    shadow.appendChild(document.createElement("shadow"));
  }

  var updateStylesheet = function(reinject)
  {
    getSelectors(function(selectors)
    {
      if (observer)
      {
        observer.disconnect();
        observer = null;
      }

      if (style && style.parentElement)
      {
        style.parentElement.removeChild(style);
        style = null;
      }

      if (selectors.length > 0)
      {
        // Create <style> element lazily, only if we add styles. Add it to
        // the shadow DOM if possible. Otherwise fallback to the <head> or
        // <html> element. If we have injected a style element before that
        // has been removed (the sheet property is null), create a new one.
        style = document.createElement("style");
        (shadow || document.head || document.documentElement).appendChild(style);

        // It can happen that the frame already navigated to a different
        // document while we were waiting for the background page to respond.
        // In that case the sheet property will stay null, after adding the
        // <style> element to the shadow DOM.
        if (style.sheet)
        {
          // If using shadow DOM, we have to add the ::content pseudo-element
          // before each selector, in order to match elements within the
          // insertion point.
          if (shadow)
            selectors = convertSelectorsForShadowDOM(selectors);

          // WebKit (and Blink?) apparently chokes when the selector list in a
          // CSS rule is huge. So we split the elemhide selectors into groups.
          for (var i = 0; selectors.length > 0; i++)
          {
            try {
              var selector = selectors.splice(0, SELECTOR_GROUP_SIZE).join(", ");
              style.sheet.insertRule(selector + " { display: none !important; }", 0);
            } catch (e) {
                 
            }
          }
        }

        observer = reinjectRulesWhenRemoved(document, style);
      }
    });
  };

  updateStylesheet();

  return updateStylesheet;
}

setTimeout(function()
{
    if (document instanceof HTMLDocument)
    {
      window.updateStylesheet = init(document);
    }
}, 100);


