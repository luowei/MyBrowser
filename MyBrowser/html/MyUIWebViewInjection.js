(function () {
    'use strict';
    /*global document, window, frames, setInterval, clearInterval */
    var windowOpenFunction = function (url, name, specs, replace) {
        var iframe = document.createElement('IFRAME');
        iframe.setAttribute('src', 'hdwebview://jswindowopenoverride||' + url);
        iframe.setAttribute('frameborder', '0');
        iframe.style.width = '1px';
        iframe.style.height = '1px';
        document.body.appendChild(iframe);
        document.body.removeChild(iframe);
        iframe = null;
        return;
    };
    var windowCloseFunction = function () {
        var iframe = document.createElement('IFRAME');
        iframe.setAttribute('src', 'hdwebview://jswindowcloseoverride');
        iframe.setAttribute('frameborder', '0');
        iframe.style.width = '1px';
        iframe.style.height = '1px';
        document.body.appendChild(iframe);
        document.body.removeChild(iframe);
        iframe = null;
    };
    var windowMakeHandler = function (anchor) {
        return function () {
            window.open(anchor.getAttribute('href'));
        };
    };
    window.open = windowOpenFunction;
    window.close = windowCloseFunction;
    window.hdMakeHandler = windowMakeHandler;
    window.hdWebViewReadyInterval = setInterval(function () {
        if (document.readyState === 'complete') {
            var i, ab = document.getElementsByTagName('a'), abLength = ab.length;
            for (i = 0; i < abLength; i += 1) {
                if (ab[i].getAttribute('target') === '_blank') {
                    ab[i].removeAttribute('target');
                    ab[i].onclick = window.hdMakeHandler(ab[i]);
                }
            }
            clearInterval(window.hdWebViewReadyInterval);
        }
    }, 10);
    for (var f = 0; f < frames.length; f++) {
        try {
            frames[f].window.open = windowOpenFunction;
            frames[f].window.close = windowCloseFunction;
            var i, fb = frames[f].document.getElementsByTagName('a'), fbLength = fb.length;
            for (i = 0; i < fbLength; i += 1) {
                if (fb[i].getAttribute('target') === '_blank') {
                    fb[i].removeAttribute('target');
                    fb[i].onclick = windowMakeHandler(fb[i]);
                }
            }
        } catch (e) { /* Security error. Can't access frame of different origin. Fail silently. */
        }
    }
}());


//获得所有图片的Urls
function getAllImageUrls() {
    var ret = [];
    var imgs = document.images;
    for (var i = 0; i < imgs.length; i++) {
        ret.push(imgs[i].src);
    }
    return JSON.stringify(ret);
}

function connectWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        callback(WebViewJavascriptBridge)
    } else {
        document.addEventListener('WebViewJavascriptBridgeReady', function() {
            callback(WebViewJavascriptBridge)
        }, false)
    }
}

connectWebViewJavascriptBridge(function(bridge) {
    bridge.init(function(message, responseCallback) {
        var data = { 'Javascript Responds':'Wee!' }
        responseCallback(data)
    })

    bridge.registerHandler('testJavascriptHandler', function(data, responseCallback) {
        var responseData = getAllImageUrls()
        responseCallback(responseData)
    })
})
