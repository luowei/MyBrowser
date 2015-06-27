/**
 * Created by luowei on 15/6/27.
 */

function removeImagesBeforeTheyAreRequested(options) {
    var images = document.getElementsByTagName('img');
    for (var i = 0; i < images.length; i++) {
        var orgSrc = images[i].src;
        images[i].removeAttribute('src');
    }
}

var message = removeImagesBeforeTheyAreRequested()
window.webkit.messageHandlers.myName.postMessage(message);