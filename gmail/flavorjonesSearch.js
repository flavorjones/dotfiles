// user javascript to build helpful search links in gmail
// based on a label naming convention:
// - starting with "_" means to bundle into high and low importance links
// - starting with "@" means to bundle everything
// - starting with "~" means to only bundle unimportant
//
// use with the chrome extension "Custom JavaScript for websites"
//   https://chrome.google.com/webstore/detail/poakhlngfciodnhlhhgnaaelnpjljija
//
var flavorjonesSearch = function() {
  console.log("flavorjones search ...");
  var labelSelector = ".nU" ;
  var widgetContainerSelector = "*[role=complementary]" ;
  var searchWidgetClass = "flavorjonesSearch" ;
  var uriPrefix = "https://mail.google.com/mail/u/0/#search/" ;

  function labelTextToLabelName(labelText) {
    return labelText.split("(")[0] ;
  }

  function labelNameToSearchName(labelName) {
    return labelName.split(/^[_@~]/)[1];
  }

  function createSearchLink(labelName, queryFilter, readableName) {
    var div = document.createElement("div") ;
    var anchor = document.createElement("a") ;
    var uri = uriPrefix
      + "label:" + labelName
      + " " + queryFilter ;
    anchor.setAttribute("href", encodeURI(uri));
    anchor.appendChild(document.createTextNode(readableName)) ;
    div.appendChild(anchor);
    return div ;
  }

  function forEachSplitLabel(labels, block) {
    for (var j = 0; j < labels.length; ++j) {
      var labelText = labels[j].textContent ;
      if (/^_/.test(labelText)) {
        var labelName = labelTextToLabelName(labelText);
        var searchName = labelNameToSearchName(labelName) ;

        block(labelText, labelName, searchName);
      }
    }  
  }

  function forEachUnifiedLabel(labels, block) {
    for (var j = 0; j < labels.length; ++j) {
      var labelText = labels[j].textContent ;
      if (/^@/.test(labelText)) {
        var labelName = labelTextToLabelName(labelText);
        var searchName = labelNameToSearchName(labelName) ;

        block(labelText, labelName, searchName);
      }
    }  
  }

  function forEachUnimportantLabel(labels, block) {
    for (var j = 0; j < labels.length; ++j) {
      var labelText = labels[j].textContent ;
      if (/^~/.test(labelText)) {
        var labelName = labelTextToLabelName(labelText);
        var searchName = labelNameToSearchName(labelName) ;

        block(labelText, labelName, searchName);
      }
    }  
  }

  var labels = document.body.querySelectorAll(labelSelector);
  if (labels.length > 0) {
    var searchWidget = document.body.querySelector("." + searchWidgetClass) ;
    if (searchWidget) {
      console.log("flavorjones deleting existing search links");
      searchWidget.remove() ;
    }

    console.log("flavorjones search building search links");
    var widgetContainer = document.body.querySelector(widgetContainerSelector);

    var widget = document.createElement("div")
    widget.setAttribute("class", searchWidgetClass);
    widgetContainer.appendChild(widget);

    forEachUnifiedLabel(labels, function(labelText, labelName, searchName) {
      widget.appendChild(createSearchLink(
        labelName,
        "in:inbox",
        "💡 " + searchName));
    });

    forEachSplitLabel(labels, function(labelText, labelName, searchName) {
      widget.appendChild(createSearchLink(
        labelName,
        "in:inbox (is:starred OR is:important OR label:~GSS)",
        "❤ " + searchName));
    });

    forEachSplitLabel(labels, function(labelText, labelName, searchName) {
      widget.appendChild(createSearchLink(
        labelName,
        "in:inbox -is:starred -is:important -label:~GSS",
        "💩 " + searchName));
    });

    forEachUnimportantLabel(labels, function(labelText, labelName, searchName) {
      widget.appendChild(createSearchLink(
        labelName,
        "in:inbox -is:starred -is:important",
        "💩 " + searchName));
    });
  }
};
flavorjonesSearch();

