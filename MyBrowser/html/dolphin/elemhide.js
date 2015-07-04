//if(document.getElementById('dolphin_night_mode_style'))
//    return;

var g_style;
var g_styleId = 'dolphin_adblock_mode_style';

function adBlockModOn(selectorString)
{
    if(document.getElementById(g_styleId))
        return "Already have dolphin_adblock_mode_style element";
    
    g_style = document.createElement("style");
    g_style.id = g_styleId;
    (document.getElementsByTagName("head")[0] || document.body).appendChild(g_style);
    g_style.appendChild(document.createTextNode(selectorString + '{display: none !important; }'));
    
    return "Append dolphin_adblock_mode_style element";
}

function adBlockModOff()
{
    if(!document.getElementById(g_styleId))
        return "Not have dolphin_adblock_mode_style element";
    
    (document.getElementsByTagName("head")[0] || document.body).removeChild(g_style);
    
    return "Remove dolphin_adblock_mode_style element";
}

var SELECTOR_GROUP_SIZE = 1;

var elemhideElt = null;

// Sets the currently used CSS rules for elemhide filters
function setElemhideCSSRules(selectors)
{
    if (elemhideElt && elemhideElt.parentNode)
        elemhideElt.parentNode.removeChild(elemhideElt);
    
    if (!selectors)
        return "bad point 1";
    
    elemhideElt = document.createElement("style");
    elemhideElt.setAttribute("type", "text/css");
    document.documentElement.appendChild(elemhideElt);
    
    var elt = elemhideElt;  // Use a local variable to avoid racing conditions
    function setRules()
    {
        if (!elt.sheet)
        {
            // Stylesheet didn't initialize yet, wait a little longer
            window.setTimeout(setRules, 0);
            return "bad point 2";
        }
        
        // WebKit apparently chokes when the selector list in a CSS rule is huge.
        // So we split the elemhide selectors into groups.
        for (var i = 0, j = 0; i < selectors.length; i += SELECTOR_GROUP_SIZE, j++)
        {
            var selector = selectors.slice(i, i + SELECTOR_GROUP_SIZE).join(", ");
            elt.sheet.insertRule(selector + " {display: none !important; }", j);
        }
    }
    setRules();
    
    return "Append dolphin_adblock_mode_style element";
}