/**
 * Created by luowei on 15/6/27.
 */

function startInjection() {
    //alert('这是startInjection方法的调用')
}

window.webkit.messageHandlers.docStartInjection.postMessage(startInjection());