/**
 * Created by luowei on 15/5/2.
 */

//发送消息
//window.webkit.messageHandlers.<name>.postMessage();

function endInjection() {

    //var message = {'message':'Hello,World!','numbers':[1,2,3]};
    //window.webkit.messageHandlers.myName.postMessage(message);

/*
    //替换百度logo
    var logoDiv = document.getElementById('logo');
    var logoImg = logoDiv != null ? logoDiv.firstElementChild : null;
    if (logoImg!=null && logoImg.tagName.toLowerCase() == 'img') {
        logoImg.src = "http://img.wodedata.com/mybrowser.jpg"
        //logoImg.src = "http://tp1.sinaimg.cn/1745746500/180/39999543554/1"
        return "{'msg':'OK!'}"
    }
    return "{'msg':'-------'}"
*/

    return "";
}

window.webkit.messageHandlers.docEndInjection.postMessage(endInjection());
