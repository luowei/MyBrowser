/**
 * iOS7的标签拦截部分
 */


AdBlocker.getFilterFromText = function(text)
{
    text = Filter.normalize(text);
    if (!text)
        throw "Attempted to create a filter from empty text";
    return Filter.fromText(text);
};

/**
 * ElemHide object about a new filter
 * if necessary.
 * @param {Filter} filter filter that has been added
 */
AdBlocker.addFilter = function(filter)
{
    if (!(filter instanceof ActiveFilter) || filter.disabled)
        return;

    if (filter instanceof ElemHideBase)
        ElemHide.add(filter);
};

AdBlocker.compileABPRules = function(filterString) {
    var lines = filterString.split(/[\r\n]+/);
    for (var i = 0; i < lines.length; i++) {
        var filter = AdBlocker.getFilterFromText(lines[i]);
        AdBlocker.addFilter(filter);
    }
};