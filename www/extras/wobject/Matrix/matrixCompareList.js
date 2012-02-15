YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
	var Dom = YAHOO.util.Dom;
	var hideStickies = 0;
	var rowDisplay = '';

	this.formatStickied = function(elCell, oRecord, oColumn, sData) {
		if(!(oRecord.getData("fieldType") in {'category':'','lastUpdated':''})){
            		var innerHTML = "<input type='checkBox' class='stickieCheckbox' id='" + oRecord.getData("attributeId") + "_stickied' name='" + oRecord.getData("attributeId") + "' onChange='setStickied(this)'";
			if(typeof(oRecord.getData("checked")) != 'undefined' && oRecord.getData("checked") == 'checked'){
				innerHTML = innerHTML + " checked='checked'";
			}
			innerHTML = innerHTML + ">";
			elCell.innerHTML = innerHTML;
		}
        };

	this.formatColors = function(elCell, oRecord, oColumn, sData) {
		if(!(oRecord.getData("fieldType") in {'category':'','lastUpdated':''})){
			var colorField = oColumn.key + "_compareColor";
			var color = oRecord.getData(colorField);
			if(color){
				Dom.setStyle(elCell.parentNode, "background-color", color);
			}
			elCell.innerHTML = sData;
		}else{
			elCell.innerHTML = sData;
		}
        };
	this.formatLabel = function(elCell, oRecord, oColumn, sData) {
		if(oRecord.getData("fieldType") == 'category'){
            		elCell.innerHTML = "<b>" +sData + "</b>";
		}else{
			elCell.innerHTML = sData; 
			if(oRecord.getData("description")){
				elCell.innerHTML = elCell.innerHTML + "<div class='wg-hoverhelp'>" + oRecord.getData("description") +"</div>";
			}
		}
        };

	YAHOO.widget.DataTable.Formatter.formatColors = this.formatColors; 

        var myColumnDefs = [
            	{key:"stickied",formatter:this.formatStickied,label:""},
		{key:"name",formatter:this.formatLabel,label:""}
        ];

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: responseFields 
        };

	var uri = "func=getCompareListData";
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}

	var initAttributeHoverHelp = function() {
		initHoverHelp('compareList');
	}

        var myDataTable = new YAHOO.widget.DataTable("compareList", myColumnDefs,
                this.myDataSource, {initialRequest:uri});
	myDataTable.subscribe("initEvent", initAttributeHoverHelp);


	window.removeListing = function(key) {
		myDataTable.hideColumn(myDataTable.removeColumn(key));
	}

	this.myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		this.responseSchema.fields = oFullResponse.ResponseFields;
		var existingColumns = myDataTable.getColumnSet().keys;
		for (var i = 0; i < existingColumns.length; i++) {
		if(i > 1){
			// after deleting a column the next column will
			// allways be no. 2 (the third in the array)
			myDataTable.removeColumn(existingColumns[2]);
		}
		}
	    if (oFullResponse.ColumnDefs) {
		var len = oFullResponse.ColumnDefs.length;
		
		for (var i = 0; i < len; i++) {
		var c = oFullResponse.ColumnDefs[i];
		oFullResponse.ColumnDefs[i].label = "<a href='"+ oFullResponse.ColumnDefs[i].url +"'>" + oFullResponse.ColumnDefs[i].label + "</a> <a href='javascript:removeListing(\""+oFullResponse.ColumnDefs[i].key+"\")'><img src='/extras/toolbar/bullet/delete.gif' border='0'></a>"
		myDataTable.insertColumn(c);
		}
	    }
	    return oFullResponse;		
	}

        var myCallback = function() {
            	this.set("sortedBy", null);
            	this.onDataReturnAppendRows.apply(this,arguments);
		initHoverHelp('compareList');
        };

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };

	if(document.getElementById("compare3")){
	var btnCompare3 = new YAHOO.widget.Button("compare3",{id:"compareButton3"});
        btnCompare3.on("click", function(e) {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		var checked = 0;
		var checkedCompareBoxes = new Object();
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked){	
				checked++;
				checkedCompareBoxes[compareCheckBoxes[i].value] = true;
			}
    		}
		if (checked < 2){
			alert(tooFewMessage);
		}else if (checked > maxComparisons){
			alert(tooManyMessage);
		}else{
			//window.document.forms['doCompare'].submit();
			var uri = "func=getCompareListData";
			for (var i = compareCheckBoxes.length; i--; ) {
				if(compareCheckBoxes[i].checked == true){
					uri = uri+';listingId='+compareCheckBoxes[i].value;
				}
			}
			myDataTable.getRecordSet().reset();
			myDataTable.refreshView();
			myDataTable.showTableMessage('Loading...');
	            	this.myDataSource.sendRequest(uri,callback2); 
		}
		
        },this,true);
	}

	if(document.getElementById("stickied")){
	var btnStickied = new YAHOO.widget.Button("stickied");
        btnStickied.on("click", function(e) {
		var elements = myDataTable.getRecordSet().getRecords();
		if(hideStickies == 0){
			// hide non-selected attributes
			for(i=0; i<elements.length; i++){
				if(!(elements[i].getData('fieldType')  in {'category':'','lastUpdated':''})){
					var attributeId = elements[i].getData('attributeId');
					var checkBox = Dom.get(attributeId+"_stickied");
					if (checkBox.checked == false){
						elRow = myDataTable.getTrEl(elements[i]);
						rowDisplay = Dom.getStyle(elRow, "display");
						Dom.setStyle(elRow, "display", "none");
					}
				}
			}
			hideStickies = 1;
		}else{
			// show all attributes
			for(i=0; i<elements.length; i++){
				if(!(elements[i].getData('fieldType')  in {'category':'','lastUpdated':''})){
					var attributeId = elements[i].getData('attributeId');
					var checkBox = Dom.get(attributeId+"_stickied");
					if (checkBox.checked == false){
						elRow = myDataTable.getTrEl(elements[i]);
						Dom.setStyle(elRow, "display", rowDisplay);
					}
				}
			}
			hideStickies = 0;
		}
	},this,true);
	}
    };
});

YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON2 = new function() {
        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
	     elCell.innerHTML = "<a href='" + oRecord.getData("url") + "'>" + sData + "</a>";
        };
	this.formatCheckBox = function(elCell, oRecord, oColumn, sData) { 
		var innerHTML = "<input type='checkbox' name='listingId' value='" + sData + "' id='" + sData + "_checkBox'";
		if(typeof(oRecord.getData("checked")) != 'undefined' && oRecord.getData("checked") == 'checked'){
			innerHTML = innerHTML + " checked='checked'";
		}
		innerHTML = innerHTML + " class='compareCheckBox'>";
		elCell.innerHTML = innerHTML;
	};

        var myColumnDefs = [
	    {key:"assetId",label:"",sortable:false, formatter:this.formatCheckBox},
            {key:"title", label:"", sortable:true, formatter:this.formatUrl},
            {key:"views", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"clicks", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"compares", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"lastUpdated", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}}
        ];

	var uri = "func=getCompareFormData";
		if(typeof(listingIds) != 'undefined'){
		uri = uri + ';__listingId_isIn=1';
		for (var i = 0; i < listingIds.length; i++) {
			uri = uri+';listingId='+listingIds[i];
		}
	}

        this.myDataSource = new YAHOO.util.DataSource(matrixUrl + "?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["title",{key: "views", parser: "number"},{key: "clicks", parser: "number"},{key: "compares", parser: "number"},{key: "checked"},{key: "lastUpdated", parser: "number"},"url","assetId"]
        };

        this.myDataTable = new YAHOO.widget.DataTable("compareForm", myColumnDefs,
                this.myDataSource, {initialRequest:uri});

	this.myDataTable.hideColumn(this.myDataTable.getColumn(2)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(3)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(4)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(5)); 

        var myCallback = function() {
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };
	
	if(document.getElementById("search")){
	var btnSearch = new YAHOO.widget.Button("search");
        btnSearch.on("click", function(e) {
		window.location.href = matrixUrl + '?func=search';
	},this,true);
	}

	window.compareDataTable = this.myDataTable;

    };
});


function setStickied (checkbox) {
	if(checkbox.checked == true){
		var request = YAHOO.util.Connect.asyncRequest('POST', "?func=setStickied;attributeId="+checkbox.name);
	}else{
		var request = YAHOO.util.Connect.asyncRequest('POST', "?func=deleteStickied;attributeId="+checkbox.name);
	}
	
}



