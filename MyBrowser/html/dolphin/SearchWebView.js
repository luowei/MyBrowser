// We're using a global variable to store the number of occurrences
var MyApp_SearchResultCount = 0;
var MyApp_SearchResultCurrentPos = 0;
var MyApp_ElementClassName = "MyAppHighlight"
var MyApp_ElementArray = [];
var MyApp_Searched = false;
var MyApp_Max_SearchResultCount = 20;

function MyApp_ScrollToElementAtIndex(elementIndex)
{
	if(elementIndex < 0 || elementIndex >= MyApp_ElementArray.length)
	{
		return;
	}
	
	var element = MyApp_ElementArray[elementIndex];
	
	var currentLeft = 0;
	var currentTop = 0;
	
	
	while(element != null)
	{
		currentLeft += element.offsetLeft;
		currentTop += element.offsetTop;
		element = element.offsetParent;
	}
	window.scrollTo(currentLeft,currentTop);
}

// helper function, recursively searches in elements and their child nodes
function MyApp_HighlightAllOccurencesOfStringForElement(element,keyword) 
{
	MyApp_Searched = true;
	if (element) 
	{
		if (element.nodeType == 3) 
		{        // Text node
			while (true) 
			{
				if(MyApp_SearchResultCount >= MyApp_Max_SearchResultCount)
				{
					return;
				}
				var value = element.nodeValue;  // Search for keyword in text node
				var idx = value.toLowerCase().indexOf(keyword);
				if (idx < 0) break;             // not found, abort
				var span = document.createElement("span");
				var text = document.createTextNode(value.substr(idx,keyword.length));
				span.appendChild(text);
				span.setAttribute("class", MyApp_ElementClassName);
			
				span.style.backgroundColor="yellow";
				span.style.color="black";
				
				text = document.createTextNode(value.substr(idx+keyword.length));
				element.deleteData(idx, value.length - idx);
				var next = element.nextSibling;
				element.parentNode.insertBefore(span, next);
				element.parentNode.insertBefore(text, next);
				element = text;
				MyApp_SearchResultCount++;	// update the counter
			}
		}
		else if (element.nodeType == 1) 
		{ // Element node
			if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') 
			{
				for (var i=element.childNodes.length-1; i>=0; i--) 
				{
					MyApp_HighlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
				}
			}
		}
	}
}

function MyApp_InitElementArray()
{
	var allElements = document.getElementsByTagName("span");
	for(var i = 0; i < allElements.length; i ++)
	{
		var elementItem = allElements.item(i);		
		if(elementItem.getAttribute("class") == MyApp_ElementClassName)
		{
			MyApp_ElementArray.push(elementItem);
		}
	}
	MyApp_HighlightElement(0, 0);
}

// the main entry point to start the search
function MyApp_HighlightAllOccurencesOfString(keyword) 
{
	MyApp_RemoveAllHighlights();
	MyApp_HighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
	MyApp_InitElementArray();
}

// helper function, recursively removes the highlights in elements and their childs
function MyApp_RemoveAllHighlightsForElement() 
{	
	for(var i = 0; i < MyApp_ElementArray.length; i ++)
	{
		var elementItem = MyApp_ElementArray[i];
		var text = elementItem.removeChild(elementItem.firstChild);
		var textParentNode = elementItem.parentNode;
		textParentNode.insertBefore(text, elementItem);
		textParentNode.removeChild(elementItem);
		textParentNode.normalize();
	}
	MyApp_ElementArray = [];
	return false;
}

function MyApp_HighlightElement(lastIndex, currentIndex)
{
	if(lastIndex >= 0 && lastIndex < MyApp_ElementArray.length)
	{
		var lastElement = MyApp_ElementArray[lastIndex];
		lastElement.style.backgroundColor = "yellow";
		lastElement.style.color = "black";
	}
	
	if(currentIndex >= 0 && currentIndex < MyApp_ElementArray.length)
	{
		var currentElement = MyApp_ElementArray[currentIndex]; // document.getElementById(MyApp_ElementClassName + currentIndex);
		currentElement.style.backgroundColor = "blue";
		currentElement.style.color = "white";
		MyApp_ScrollToElementAtIndex(currentIndex);
	}
}

function MyApp_HighlightPreElement()
{
	if(MyApp_ElementArray.length == 0)
		return 0;
	
	var lastIndex = MyApp_SearchResultCurrentPos;
	MyApp_SearchResultCurrentPos --;
	if(MyApp_SearchResultCurrentPos < 0)
	{
		MyApp_SearchResultCurrentPos += MyApp_SearchResultCount;
	}
	MyApp_HighlightElement(lastIndex, MyApp_SearchResultCurrentPos);
	return MyApp_SearchResultCurrentPos;
}

function MyApp_HighlightNextElement()
{	
	if(MyApp_ElementArray.length == 0)
		return 0;
	
	var lastIndex = MyApp_SearchResultCurrentPos;
	MyApp_SearchResultCurrentPos ++;
	if(MyApp_SearchResultCurrentPos >= MyApp_SearchResultCount)
	{
		MyApp_SearchResultCurrentPos -= MyApp_SearchResultCount;
	}
	MyApp_HighlightElement(lastIndex, MyApp_SearchResultCurrentPos);
	return MyApp_SearchResultCurrentPos;
}

// the main entry point to remove the highlights
function MyApp_RemoveAllHighlights() 
{
	MyApp_RemoveAllHighlightsForElement();
	MyApp_SearchResultCount = 0;
	MyApp_SearchResultCurrentPos = 0;
	MyApp_Searched = false;
}