var ImageBlocker = {
    _enable: true
}
ImageBlocker.__defineGetter__('enable',function(){return this._enable});
ImageBlocker.__defineSetter__('enable',function(enable){
   this._enable = enable;
   if (enable) {
       document.addEventListener("beforeload", ImageBlocker.blockImages, true);
   } else {
       document.removeEventListener("beforeload", ImageBlocker.blockImages, true);
   };
})
/*blockImages beforeload*/
ImageBlocker.blockImages = function() {
    var isImage = event.url.match(/.jpg/i) || event.url.match(/.png/i) || event.url.match(/.gif/i) || event.url.match(/.jpeg/i) || event.url.match(/.bmp/i);
    if (isImage) {
        event.preventDefault();
    }
    var isImgTag = event.target.tagName == 'IMG';
    if (isImgTag) {
        event.preventDefault();
    }
}
//
/*替换background-image*/
ImageBlocker.removeBackgroundImages = function() {
    //alert('=====removeBackgroundImages')
    if (ImageBlocker.enable) {
        var bgImgs = document.body.querySelectorAll('*[style^=\"background-image:\"]');
        for (var j = 0; j < bgImgs.length; j++) {
            var bgImg = bgImgs[j];
            bgImg.style.backgroundImage = '';
        }
    };
}

window.webkit.messageHandlers.decideImageBlockStatus.postMessage("");