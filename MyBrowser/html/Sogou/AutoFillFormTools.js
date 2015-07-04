(function ()
{
    if (!window.SeMobFillFormTool){
        window.SeMobFillFormTool = {};
        initFormTool(window.SeMobFillFormTool);
    }
    function initFormTool(tool){
    	tool.nameInput = null;
    	tool.passwordInput = null;
    	tool.formInfoArray = [];
    	tool.filledFormArray = [];
        tool.lastUsedIndex = -1;
    	tool.addOneFormInfo = function(name, password, formName, nameInputName, nameInputId, pwdInputName, pwdInputId)
        {
	        var formInfo = {
		        'name':name,
		        'password':password,
		        'formName':formName,
		        'nameInputName':nameInputName,
		        'nameInputId':nameInputId,
		        'pwdInputName':pwdInputName,
		        'pwdInputId':pwdInputId
	        }
	        tool.formInfoArray.push(formInfo);
        }
        tool.getFormName = function(form)
        {
            form = form || tool.passwordInput.form || tool.nameInput.form;
            if(!form || !form.tagName || !(form.tagName.toLowerCase() === 'form'))
                return null;
            var formName = form.name;
            if(formName)
                return formName;
            formName = form.getAttribute('action');
            return formName;
        }
 
    	tool.parseForm = function(form, getValue)
    	{
             function isElementVisible(elem){
             var rectInput = elem.getBoundingClientRect();
                 if (rectInput.width == 0 || rectInput.height == 0){
                     return false;
                 } else {
                     return true;
                 }
             }
            var passwordInputNum = 0;
	    	var result = {};
	    	if (form.tagName.toLowerCase() != 'form'){
		    	return result;
	    	}
             // if form method is post
	    	var method = form.getAttribute('method') || form.getAttribute('type') || form.method;
            if (method && method.toLowerCase() != 'post'){
                return result;
            }
            var formElems = form.elements;
            for (var j = 0; j < formElems.length; j++){
                if(formElems[j].tagName && formElems[j].tagName.toLowerCase() != 'input')
                    continue;
                var theInput = formElems[j];
                // is visible?
                if (!isElementVisible(theInput)){
                    continue;
                }
                if (theInput.type.toLowerCase() == 'password'){
                	// find a password input
                	 passwordInputNum++;
                	 if(passwordInputNum > 1){
	                	 // more than one password input is visible, we assume the form is registration form
	                	 result = {};
	                	 return result;
                	 }
                     if (getValue){
                         if (theInput.value.length > 0){
                             result.passwordInput = theInput;
                         }
                     } else {
                     	result.passwordInput = theInput;
                     }
                    for(var i = j-1; i >= 0; i--){
                        //get name input
                        var lastInput = formElems[i];
                        if(lastInput.tagName.toLowerCase() != 'input' || !isElementVisible(lastInput))
                            continue;
                        var type = lastInput.type.toLowerCase();
                        if(type == "email" || type == "text" || type == "url" || type == "tel"){ // may be more
                           	if(getValue){
                               if(theInput.value.length > 0){
	                               // found! break
                                   result.nameInput = lastInput;
                                   break;
                               } else {
                                   continue;
                               }
                            } else {
                            	// found! break
                               result.nameInput = lastInput;
                               break;
                            }
                       }
                    } 
                    // end of 'get name input'
                }
            }
            return result;
    	}
        tool.getNamePasswordInputs = function (getValue)
        {
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
		   // begin to retrieval forms
        	var workingElement = null;
        	var targetInputs = {};
        	workingElement = getWorkingElement(window);
        	if (workingElement && workingElement.tagName.toLowerCase() == 'input' && workingElement.form){
            	targetInputs = tool.parseForm(workingElement.form, getValue);
            } else {
            // else
                var forms = document.forms;
                for (var i = 0; i<forms.length; i++){
	                targetInputs = tool.parseForm(forms[i], getValue);
	                if(targetInputs.nameInput && targetInputs.passwordInput){
		                // got one
		                break;
	                }
                }
                // find in iframe
                if(!(targetInputs.nameInput && targetInputs.passwordInput)){
	                var iframes = document.getElementsByTagName('iframe');
	                // iframe layer loop
	                for (var i = 0; i < iframes.length; i++){
		               var doc = iframes[i].contentDocument;
		               if(!doc){
			               continue;
		               }
		               var iforms = doc.forms;
		               // form layer loop
		               for (var j = 0; j<iforms.length; j++){
			               targetInputs = tool.parseForm(iforms[j], getValue);
			               if(targetInputs.nameInput && targetInputs.passwordInput){
				               // got one
				               break; // jump from form layer loop
				               break; // jump from iframe layer loop
				           }
				       }
				       // end of form layer loop
				    }
				    // end of iframe layer loop
                }
                // end of find in iframe
            }
            // end of else
           tool.nameInput = targetInputs.nameInput;
           tool.passwordInput = targetInputs.passwordInput;
           if(tool.nameInput && tool.passwordInput){
              return 'true';
           }
        }

        tool.getElementByNameRecursive = function (doc,name)
        {
	        var elem = doc.getElementsByName(name);
	        if(elem[0]){
		        return elem[0];
	        } else {
		        var iframes = doc.getElementsByTagName('iframe');
		        for( var i = 0; i < iframes.length; i++){
			        var oneIframe = iframes[i];
			        var idoc = oneIframe.contentDocument;
			        if(!idoc)
			        	continue;
			        var ielem = tool.getElementByNameRecursive(oneIframe.contentDocument,name);
			        if (ielem){
				        return ielem;
			        }
		        }
	        }
	        return null;
        }

        tool.getElementByIdRecursive = function (doc,id)
        {
	        var elem = doc.getElementById(id);
	        if(elem){
		        return elem;
	        } else {
		        var iframes = doc.getElementsByTagName('iframe');
		        for( var i = 0; i < iframes.length; i++){
			        var oneIframe = iframes[i];
			        var idoc = oneIframe.contentDocument;
			        if(!idoc)
			        	continue;
			        var ielem = tool.getElementByNameRecursive(oneIframe.contentDocument,id);
			        if (ielem){
				        return ielem;
			        }
		        }
	        }
	        return null;
        }

        tool.fillFormInCurrentInputs = function(isExactly)
        {
        	for(var i=0; i < tool.filledFormArray.length; i++){
	        	 if (tool.nameInput.form == tool.filledFormArray[i]){
		        	 //already filled, return
		        	 return false;
	        	 }
        	}
            tool.lastUsedIndex = -1;
        	var filled = false;
	        if(tool.nameInput && tool.passwordInput){
		        for (var i=tool.formInfoArray.length-1; i>=0; i--){
		        	var formInfo = tool.formInfoArray[i];
			        if(tool.nameInput.id == formInfo.nameInputId && tool.nameInput.name == formInfo.nameInputName &&
			        	tool.passwordInput.id == formInfo.pwdInputId && tool.passwordInput.name == formInfo.pwdInputName){
				        	//matched!
				        	tool.nameInput.value = formInfo.name;
				        	tool.passwordInput.value = formInfo.password;
				        	filled = true;
                            tool.lastUsedIndex = i;
					        break;
			        }
		        }
		        if(!filled && !isExactly){
			        var lastForm = tool.formInfoArray[tool.formInfoArray.length - 1];
			        tool.nameInput.value = formInfo.name;
			        tool.passwordInput.value = formInfo.password;
			        filled = true;
                    tool.lastUsedIndex = tool.formInfoArray.length - 1;
		        }
	        }
	        if (filled){
		        tool.filledFormArray.push(tool.nameInput.form);
	        }
	        return filled;  
        }

        tool.fillFormExactly = function(name, password, formName, nameInputName, nameInputId, pwdInpudName, pwdInputId)
        {
        	if(formName && formName.length){
	        	var form = tool.getElementByNameRecursive(document,formName);
	        	if(form){
		        	var inputs = tool.parseForm(form, false);
		        	tool.nameInput = inputs.nameInput;
		        	tool.passwordInput = inputs.passwordInput;
	        	}
        	} else if(nameInputName && nameInputName.length){
	        	var nameInput = tool.getElementByNameRecursive(document,nameInputName);
	        	if(nameInput){
		        	var inputs = tool.parseForm(nameInput.form, false);
		        	tool.nameInput = inputs.nameInput;
		        	tool.passwordInput = inputs.passwordInput;
	        	}
        	} else if(nameInputId && nameInputId.length){
	        	var nameInput = tool.getElementByIdRecursive(document,nameInputId);
	        	if(nameInput){
		        	var inputs = tool.parseForm(nameInput.form, false);
		        	tool.nameInput = inputs.nameInput;
		        	tool.passwordInput = inputs.passwordInput;
	        	}
        	} else if (pwdInpudName && pwdInpudName.length){
	        	var pwdInput = tool.getElementByNameRecursive(document,pwdInpudName);
	        	if(pwdInput){
		        	var inputs = tool.parseForm(pwdInput.form, false);
		        	tool.nameInput = inputs.nameInput;
		        	tool.passwordInput = inputs.passwordInput;
	        	}
        	} else if (pwdInputId && pwdInputId.length){
	        	var pwdInput = tool.getElementByIdRecursive(document,pwdInputId);
	        	if(pwdInput){
		        	var inputs = tool.parseForm(pwdInput.form, false);
		        	tool.nameInput = inputs.nameInput;
		        	tool.passwordInput = inputs.passwordInput;
	        	}
        	} else {
	        	return false;
        	}
	        if(tool.nameInput && tool.passwordInput && !(tool.nameInput.value.length > 0 && tool.passwordInput.value.length > 0)){
	       		 for(var i=0; i < tool.filledFormArray.length; i++){
		        	 if (tool.nameInput.form == tool.filledFormArray[i]){
			        	 //already filled, return
			        	 return false;
		        	 }
	        	 }
		         tool.nameInput.value = name;
		         tool.passwordInput.value = password;
		         tool.filledFormArray.push(tool.nameInput.form);
		         return true;
	        } else {
		        return false;
	        }
	
        }

        tool.fillFormObscurely = function(name, password)
        {
	        if (!(tool.nameInput && tool.passwordInput)) {
	        	tool.getNamePasswordInputs(false);
	        }
	        if(tool.nameInput && tool.passwordInput){
	        	 for(var i=0; i < tool.filledFormArray.length; i++){
		        	 if (tool.nameInput.form == tool.filledFormArray[i]){
			        	 //already filled, return
			        	 return false;
		        	 }
	        	 }
		         tool.nameInput.value = name;
		         tool.passwordInput.value = password;
		         tool.filledFormArray.push(tool.nameInput.form);
		         return true;
	        } else {
		        return false;
	        }
        }

        tool.fillForm = function()
        {
        	var matched = false;
	        for(var i=0; i < tool.formInfoArray.length; i++){
		        var oneForm = tool.formInfoArray[i];
		        if(tool.fillFormExactly(oneForm.name, oneForm.password, oneForm.formName, oneForm.nameInputName,
		        						oneForm.nameInputId, oneForm.pwdInpudName, oneForm.pwdInputId)){
			    	matched = true;
                    tool.lastUsedIndex = i; //found
                    break;
		        }
	        }
	        if(!matched){
	        	var lastForm = tool.formInfoArray[tool.formInfoArray.length-1];
	        	if(lastForm){
		        	matched = tool.fillFormObscurely(lastForm.name, lastForm.password);
                    if(matched)
                        tool.lastUsedIndex = tool.formInfoArray.length-1; //found
                    else
                        tool.lastUsedIndex = -1; // not found
                } else {
                    tool.lastUsedIndex = -1;
                }
	        }
	        return matched ? 'true' : 'false';
        }

        tool.getName = function()
        {
        	if(tool.nameInput){
	        	return tool.nameInput.value;
        	} else {
	        	return null;
        	}
        }

        tool.getPassword = function()
        {
        	if(tool.passwordInput){
	        	return tool.passwordInput.value;
        	} else {
	        	return null;
        	}
        }

        tool.domFocusIn = function(event)
        {
	        var node = event.target;
		    if (node.tagName.toLowerCase() == "input"){
		    	if(tool.nameInput && node.form == tool.nameInput.form){
			    	return;
		    	}
		        var type = node.type;
		        if (type == "email" || type == "password" || type == "text" || type == "url") {
		            tool.getNamePasswordInputs(false);
		            tool.fillFormInCurrentInputs(false);
		        }
		    }
		}
        tool.domInserted = function(event)
        {
        	var node = event.target;
        	if(!node || !node.tagName)
                return;
            if(node && node.tagName && node.tagName.toLowerCase() == 'iframe'){
                node = node.contentDocument;
            }
            if(!node || !node.tagName)
                return;
        	var forms = node.tagName.toLowerCase() == 'form' ? [node] : node.getElementsByTagName('form');
        	for (var i = 0; i < forms.length; i++){
	        	var currentForm = forms[i];
	        	var result = tool.parseForm(currentForm, false);
	        	if (result.nameInput && result.passwordInput){
		        	tool.nameInput = result.nameInput;
		        	tool.passwordInput = result.passwordInput;
		        	tool.fillFormInCurrentInputs(false);
	        	}
        	}
        }
		document.addEventListener("DOMFocusIn", tool.domFocusIn, false);
        document.addEventListener("DOMNodeInserted", tool.domInserted, false);
	}
})();
