/*function MyAppGetHTMLElementsAtPoint(x, y)
{
	var tags = "";
	var e = document.elementFromPoint(x, y);
	tags = 'tagname:' + e.tagName + ';';
	tags += 'href:' + e.href + ';';
	tags += 'text:' + e.text + ';';
	return tags;
}*/

function MyAppHandleIFrameElement(x, y, e, needAddScroll) {
    if (e.tagName == 'IFRAME' || e.tagName == 'iframe') {
        var left = e.getBoundingClientRect().left;
        var top = e.getBoundingClientRect().top;
        if (needAddScroll) {
            left += window.pageXOffset;
            top += window.pageYOffset;
        }
             
        e = e.contentDocument.elementFromPoint(x-left,y-top);
    }
    
    return e;
}

function MyAppGetHTMLElementsAtPoint(x,y,needAddScroll) {
    var tags = ",";
    var e = document.elementFromPoint(x,y);
    while (e) {
        if (e.tagName) {
            
            e = MyAppHandleIFrameElement(x, y, e, needAddScroll);
            
            if(e.tagName == 'A' || e.tagName =='a')
            {
                tags += 'tag:' + e.tagName + '[dolphin]';
                tags += 'href:' + e.href + '[dolphin]';
                tags += 'text:' + e.text + '[dolphin]';
            }
            else if(e.tagName == 'IMG' || e.tagName == 'img')
            {
                tags += 'tag:' + e.tagName + '[dolphin]';
                tags += 'imgUrl:' + e.src + '[dolphin]';   
            }
            else if((e.tagName == 'AREA' || e.tagName == 'area') && e.href != null)
            {
                tags += 'tag:' + e.tagName + '[dolphin]';
                tags += 'href:' + e.href + '[dolphin]';
            }
        }
        e = e.parentNode;
    }
    return tags;
}

var MyApp_s_baseTarget;

function MyAppGetBaseTarget()
{
    if(!MyApp_s_baseTarget)
    {
        var bases = document.getElementsByTagName('base');
        if(bases.length > 0)
        {
            MyApp_s_baseTarget = bases[0].target;
        }
    }
    
    return MyApp_s_baseTarget;
}

function MyAppGetLinkAtPoint(x,y,needAddScroll) {
    var tags = ",";
    var baseTarget = MyAppGetBaseTarget();
    
    var e = document.elementFromPoint(x,y);
    while (e) {
        if (e.tagName) {
            
            e = MyAppHandleIFrameElement(x, y, e, needAddScroll);
            
            if(e.tagName == 'A' || e.tagName =='a')
            {
                tags += 'tag:' + e.tagName + '[dolphin]';
                tags += 'href:' + e.href + '[dolphin]';
                tags += 'text:' + e.text + '[dolphin]';
                
                var target = e.target ? e.target : baseTarget;
                tags += 'target:' + target + '[dolphin]';
            }
        }
        
        e = e.parentNode;
    }
    return tags;
}