var dollar = null;
var workingElement = null;
var SeMobInputDomFocusInAdded = false;
function getInputType()
{
    if (!workingElement && injectInput() != 'true'){
        return null;
    }
    if (typeof workingElement == 'undefined' ||!workingElement){
        // Still not get workingElement, return.
        return null;
    }
    var inputType;
    inputType = workingElement.type.toLowerCase();
    if  (inputType)
        return inputType;
    else
        return null;
}
function shouldProcessNode(node)
{
    if(typeof node == 'undefined' || !node){
        return false;
    }
    if(node.tagName.toLowerCase() == "input"){
        var type = node.type.toLowerCase();
        if(type == "email" || type == "password" || type == "search" ||
           type == "text" || type == "url" || type == "tel"){
            return true;
        } else {
            return false;
        }
    }
    if(node.tagName.toLowerCase() == "textarea"){
        return true;
    }
    else{
        return false;
    }
}

function simulateKeyboardEvent(type, keycode, alt, ctl, shift)
{
    if(keycode == 10){
        keycode = 13;
    }
    if (type == 'keyup' || type == 'keydown'){
        if ( keycode >= 97 && keycode <= 125){ //a-z,{,},|,
            keycode -= 32;
            shift = true;
        } else if (keycode == 49){ // !
            keycode = 33;
            shift = true;
        } else if (keycode == 64){ // @
            keycode = 50;
            shift = true;
        } else if (keycode >= 35 && keycode <= 37){ //#,$,%
            keycode += 16;
            shift = true;
        } else if (keycode == 94){ // ^
            keycode = 54;
            shift = true;
        } else if (keycode == 38){ // &
            keycode = 55;
            shift = true;
        } else if (keycode == 42){ // *
            keycode = 56;
            shift = true;
        } else if (keycode == 40){ // (
            keycode = 57;
            shift = true;
        } else if (keycode == 41){ // )
            keycode = 48;
            shift = true;
        } else if (keycode == 95){ // _
            keycode = 189;
            shift = true;
        } else if (keycode == 45){ // -
            keycode = 189;
        } else if (keycode == 43){ // +
            keycode = 187;
            shift = true;
        } else if (keycode == 61){ // =
            keycode = 187;
        } else if (keycode == 126){ // ~
            keycode = 192;
            shift = true;
        } else if (keycode == 96){ // `
            keycode = 192;
        } else if (keycode == 58){ // :
            keycode = 186;
            shift = true;
        } else if (keycode == 59){ // ;
            keycode = 186;
        } else if (keycode == 34){ // "
            keycode = 222;
            shift = true;
        } else if (keycode == 39){ // '
            keycode = 222;
        } else if (keycode == 60){ // <
            keycode = 188;
            shift = true;
        } else if (keycode == 44){ // ,
            keycode = 188;
        } else if (keycode == 62){  // >
            keycode = 190;
            shift = true;
        } else if (keycode == 46){ // .
            keycode = 190;
        } else if (keycode == 63){ // ?
            keycode = 191;
            shift = true;
        } else if (keycode == 47){ // /
            keycode = 191;
        }
    }
    var newEvent = document.createEvent('HTMLEvents');
    newEvent.initEvent(type, true, true);
    newEvent.keyCode = keycode;
    newEvent.which = keycode;
    newEvent.keyIdentifier = 'U+00' + keycode.toString(16);
    newEvent.altGraphKey = false;
    newEvent.altKey = alt;
    newEvent.charCode = 0;
    newEvent.ctrlKey = ctl;
    newEvent.currentTarget = null;
    newEvent.detail = 0;
    newEvent.eventPhase = 0;
    newEvent.keyLocation = 0;
    newEvent.layerX = 0;
    newEvent.layerY = 0;
    newEvent.metaKey = false;
    newEvent.pageX = 0;
    newEvent.pageY = 0;
    newEvent.returnValue = true;
    newEvent.shiftKey = shift;
    newEvent.view = document.defaultView;
    newEvent.creater = 'semob';
    return newEvent;
}

function typeString (str, keyboardHeight)
{
    if(!workingElement)
        return '';
    if (str == "\n" && workingElement.tagName.toLowerCase() == "input"){
        event = simulateKeyboardEvent('keydown',13,false,false,false);
        workingElement.dispatchEvent(event);
        event = simulateKeyboardEvent('keypress',13,false,false,false);
        workingElement.dispatchEvent(event);
        event = simulateKeyboardEvent('keyup',13,false,false,false);
        workingElement.dispatchEvent(event);
        SubmitForm();
        return '';
    }
    var event = null;
    var scrollWidth = workingElement.scrollWidth;
    var scrollTop = workingElement.scrollTop;
    var scrollLeft = workingElement.scrollLeft;
    var scrollHeight = workingElement.scrollHeight;
    var frontStr = workingElement.value.substring(0, workingElement.selectionStart);
    var backStr = workingElement.value.substr(workingElement.selectionEnd);
    var newValue = '';
    var strForRange = '';
    // set active node's vaule
    if (str.length == 0){
        event = simulateKeyboardEvent('keydown',8,false,false,false);
        workingElement.dispatchEvent(event);
        event = simulateKeyboardEvent('keypress',8,false,false,false);
        workingElement.dispatchEvent(event);
        // backspace
        if (workingElement.selectionEnd == workingElement.selectionStart){
            // no user selection
            var deleteLength = 1;
            if(frontStr.substr(frontStr.length-2, frontStr.length-1) === '\ud83d'){
                deleteLength = 2;
            }
            newValue = ''+frontStr.substring(0,frontStr.length-deleteLength)+backStr;
            workingElement.value = newValue;
            strForRange = ''+frontStr.substring(0,frontStr.length-deleteLength);
            workingElement.setSelectionRange(strForRange.length,strForRange.length);
        } else {
            // user selected
            newValue = ''+frontStr+backStr;
            workingElement.value = newValue;
            strForRange = frontStr;
            workingElement.setSelectionRange(strForRange.length,strForRange.length);
        }
        event = simulateKeyboardEvent('keyup',8,false,false,false);
        workingElement.dispatchEvent(event);
    } else {
        // normal input
        var asciiCode = str.charCodeAt(str.length-1)<255 ? true : false;
        if (asciiCode){
            event = simulateKeyboardEvent('keydown',str.charCodeAt(str.length-1),false,false,false);
            workingElement.dispatchEvent(event);
            event = simulateKeyboardEvent('keypress',str.charCodeAt(str.length-1),false,false,false);
            workingElement.dispatchEvent(event);
        }
        newValue = ''+frontStr+str+backStr;
        if (workingElement.maxLength >0 && newValue.length > workingElement.maxLength){
            // excess maxlength, do noting
            if (asciiCode){
                event = simulateKeyboardEvent('keyup',str.charCodeAt(str.length-1),false,false,false);
                workingElement.dispatchEvent(event);
            }
            return;
        } else {
            workingElement.value = newValue;
            strForRange = ''+frontStr+str;
            workingElement.setSelectionRange(strForRange.length,strForRange.length);
        }
        if (asciiCode){
            event = simulateKeyboardEvent('keyup',str.charCodeAt(str.length-1),false,false,false);
            workingElement.dispatchEvent(event);
        }
    }
    // scroll to cursor
    var diffHeight = workingElement.scrollHeight - scrollHeight;
    workingElement.scrollTop = scrollTop + diffHeight;
    var diffWidth = workingElement.scrollWidth - scrollWidth;
    workingElement.scrollLeft = scrollLeft + diffWidth;
    // scroll cursor into view
    if (workingElement.tagName.toLowerCase() == 'textarea' &&
        workingElement.scrollTop == 0){
        var textHeightDiv = document.getElementById('sgWebInputHeightDiv');
        if(!textHeightDiv){
            textHeightDiv = document.createElement('div');
            textHeightDiv.id = 'sgWebInputHeightDiv';
            var cssStyle = '';
            var workingElementCssStyle = window.getComputedStyle(workingElement);
            for(var i=0; i< workingElementCssStyle.length; i++){
                var name = workingElementCssStyle[i];
                switch(true){
                    case (name.indexOf('font') > -1):
                    case (name.indexOf('line') > -1):
                    case (name.indexOf('text') > -1):
                    case (name.indexOf('letter') > -1):
                    case (name.indexOf('direction') > -1):
                    case (name.indexOf('word') > -1):
                    case (name.indexOf('space') > -1):
                    case (name.indexOf('outline') > -1):
                    case (name.indexOf('padding') > -1):
                    case (name.indexOf('border') > -1):
                    case (name.indexOf('width') > -1):
                        var value = workingElementCssStyle[name];
                        cssStyle += name +':' +value+';';
                        break;
                    default:
                        break;
                }
            }
            textHeightDiv.setAttribute('style', cssStyle);
            textHeightDiv.style.position = 'absolute';
            textHeightDiv.style.top = '-10000px';
            textHeightDiv.style.left = '-10000px';
            textHeightDiv.style.zIndex = -1000;
            textHeightDiv.style.paddingBottom = '0px';
            textHeightDiv.style.borderBottomWidth = '0px';
            textHeightDiv.style.marginBottom = '0px';
            textHeightDiv.style.height = 'auto';
            document.body.appendChild(textHeightDiv);
        }
        textHeightDiv.innerText = workingElement.value;
        var height = textHeightDiv.offsetHeight;
        var top = workingElement.getBoundingClientRect().top;
        var viewheight;
        if(Math.abs(window.orientation) == 90){
            // landscape mode
            // 20 is statusbar's height
            viewheight = window.screen.width - ((window.innerHeight == window.screen.width) ? 0 : 20);
        } else {
            viewheight = window.screen.height - ((window.innerHeight == window.screen.height) ? 0 : 20);
        }
        scrollHeight = top + height - (viewheight - keyboardHeight)/2;
        document.body.scrollTop += scrollHeight;
    }

    // trigger events
    event = document.createEvent("HTMLEvents");
    event.initEvent("change", true, true);
    workingElement.dispatchEvent(event);

    event = document.createEvent("HTMLEvents");
    event.initEvent("input", true, true);
    workingElement.dispatchEvent(event);
    var reslut = workingElement.value;
    if(reslut[reslut.length - 1] == '\n'){
        // for nsstring to caculate string size
        reslut += ' ';
    }
    return reslut;
}

(function getDollar(){
     if(dollar){
        return;
     }
     if (typeof (Zepto) != 'undefined'){
     dollar = Zepto;
     } else if (typeof (jQuery) != 'undefined'){
     dollar = jQuery;
    }
 })();

function injectInput() {
    if(!SeMobInputDomFocusInAdded){
        document.addEventListener('DOMFocusIn', onDomFocusIn,false);
        SeMobInputDomFocusInAdded = true;
    }
    function getWorkingElement(win){
        var workingElem = win.document.activeElement;
        if (typeof workingElem == 'undefined'){
            // Web is not support html5.
            var selection = win.getSelection();
            var offset = selection.focusOffset;
            var focusNode = selection.focusNode;
            if (!focusNode) {
                return null;
            }
            workingElem = focusNode.childNodes[offset];
        }
        if (typeof workingElem == 'undefined' || !workingElem){
            return null;
        }
        if (workingElem.tagName.toLowerCase() == 'iframe'){
            workingElem = getWorkingElement(workingElem.contentWindow);
        }
        return workingElem;
    }
    workingElement = getWorkingElement(window);
    if(shouldProcessNode(workingElement)){
        workingElement.addEventListener('blur', workingElementOnBlur, false);
        workingElement.addEventListener('input', SeMobInputListener, false);
        return 'true';
    } else {
        workingElement = null;
        return 'false';
    }
}

function SeMobInputListener(event)
{
    if(typeof event.creater === 'undefined' || event.creater !== 'semob'){
        window.location = "semob://callinput?workingElementInput";
    }
}

function onDomFocusIn()
{
    workingElement = null;
    var url = "semob://callinput?workingElementFocus";
    window.location = url;
    workingElementCssStyle = null;
}

function workingElementOnBlur(){
    this.removeEventListener('blur', workingElementOnBlur);
    this.removeEventListener('input', SeMobInputListener);
    workingElement = null;
    var url = "semob://callinput?workingElementBlur";
    window.location = url;
    workingElementCssStyle = null;
}

function getWorkingElementSelection(){
    return ''+workingElement.selectionStart+','+workingElement.selectionEnd;
}

function setWorkingElementSelection(start, end){
    var start = workingElement.selectionStart + start;
    var end = workingElement.selectionEnd + end;
    if (start > workingElement.selectionEnd){
        workingElement.selectionEnd = end;
        workingElement.selectionStart = start;
    } else {
        workingElement.selectionStart = start;
        workingElement.selectionEnd = end;
    }
}
function SubmitForm() {
    var obj = workingElement;
    if (obj.tagName.toLowerCase() != 'input')
        return;
    var form = obj.form;
    if (!form){
        return;
    }
    if(form.onsubmit){
        var flag = form.onsubmit();
        if(typeof flag == 'boolean' && !flag){
            // on submit return false, submitting is stopped
            return;
        }
    }
    if (dollar && dollar(form).submit){
        dollar(form).submit();
    } else {
        form.submit();
    }
}
