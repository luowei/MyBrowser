/*
 * 广告拦截-基础部分
 */

var AdBlocker = {
  _enable: true,
  whiteList: {

  },
  elemHideList: {
    
  }
};

AdBlocker.__defineGetter__('enable',function(){return this._enable});
AdBlocker.__defineSetter__('enable',function(enable){
  this._enable = enable;
  if (enable) {
    if (AdBlocker.onBeforeLoad != "undefined") {
      document.addEventListener("beforeload", AdBlocker.onBeforeLoad, true);
    }
  } else {
    if (AdBlocker.onBeforeLoad != "undefined") {
      document.removeEventListener("beforeload", AdBlocker.onBeforeLoad, true);
    }
  };
});

AdBlocker.compileWhiteList = function(whiteListString) {
    var whiteList = whiteListString.split(/[\r\n]+/);
    for (var whiteDomain of whiteList) {
        AdBlocker.whiteList[whiteDomain] = true;
    };
};