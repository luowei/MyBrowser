/**
 * Created by luowei on 15/6/27.
 */

/*
function removeImagesBeforeTheyAreRequested(options) {
    var images = document.getElementsByTagName('img');
    for (var i = 0; i < images.length; i++) {
        var orgSrc = images[i].src;
        images[i].removeAttribute('src');
    }
    return "success"
}

var message = removeImagesBeforeTheyAreRequested();
window.webkit.messageHandlers.myName.postMessage(message);
*/

//window.onload=function(){
//    var images = document.getElementsByTagName('img');
//    for (var i = 0; i < images.length; i++) {
//        var orgSrc = images[i].src;
//        images[i].removeAttribute('src');
//        img.setAttribute('data-src', src);
//        alert('before:'+orgSrc)
//        alert('after:'+img.src)
//    }
//    alert("function called !")
//};


(function(){
    window.onload=function(){
        var images = document.getElementsByTagName('img');
        for (var i = 0; i < images.length; i++) {
            var orgSrc = images[i].src;
            images[i].removeAttribute('src');
            alert('before:'+orgSrc)
            alert('after:'+images[i].src)
        }
    };
}())


////use jquery
//$(document).ready(function () {
//    var images = $('img');
//    $.each(images, function() {
//        alert(this.src)
//        $(this).removeAttr("src");
//        alert(this.src)
//    });
//});