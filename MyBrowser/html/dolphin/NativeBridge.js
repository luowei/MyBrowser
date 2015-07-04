(function() {

 function GUID ()
 {
     var S4 = function ()
     {
        return Math.floor(
                   Math.random() * 0x10000 /* 65536 */
                   ).toString(16);
      };
 
      return (
         S4() + S4() + "-" +
         S4() + "-" +
         S4() + "-" +
         S4() + "-" +
         S4() + S4() + S4()
         );
 }
 
 function NativeBridge()
 {
    function call(functionName, jsCallId)
    {
       callWithParams(functionName, jsCallId, null);
    }
 
    function callWithParams(functionName, jsCallId, params)
    {
       var iframe = document.createElement("IFRAME");
       var src = "js-frame://" + functionName +"?jsCallId=" + jsCallId;
 
       if(params != null)
       {
            for(var key in params)
            {
                src += "&" + key + "=" + encodeURIComponent(params[key]);
            }
       }
 
       iframe.setAttribute("src", src);
       document.documentElement.appendChild(iframe);
       iframe.parentNode.removeChild(iframe);
       iframe = null;
    }
 
    this.call = call;
    this.callWithParams = callWithParams;
 }
 
 function HttpRequest()
 {
     var debugInfo;
     var callbacks = new Object();
     function send(href, callback)
     {
        var callId = GUID();
        var params = new Object();
        params.href = href;
        nativeBridge.callWithParams("httpRequest", callId, params);
        callbacks[callId] = callback;
    }
 
    function onHttpRequestReturn(response, callId, href)
    {
       var decodedResponce = response.replace(/&apos;/g, "'");

        var callback = callbacks[callId];
        callback(href, decodedResponce);
        callbacks[callId] = null;
    }
 
    function getDebug()
    {
      return debugInfo;
    }
 
    this.getDebug = getDebug;
    this.send = send;
    this.onHttpRequestReturn = onHttpRequestReturn;
 }

 window.nativeBridge = new NativeBridge();
 window.httpRequest = new HttpRequest();
 
})();