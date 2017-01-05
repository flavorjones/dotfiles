///
/// TOC:
/// - flavorjonesSearch javascript to build magic sidebar links
/// - keypress handler to make sidebar visible
///

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
  var searchWidgetClass = "flavorjonesSearch" ;

  var uriPrefix = "https://mail.google.com/mail/u/0/#search/" ;
  var labelSelector = ".nU" ;
  var widgetContainerSelector = "*[role=complementary] .T0" ;

  var unifiedFlavor     = /^@/ ;
  var unfilteredFlavor  = /^\./ ;
  var splitFlavor       = /^_/ ;
  var unimportantFlavor = /^~/ ;
  var flavors = [unifiedFlavor, unfilteredFlavor, splitFlavor, unimportantFlavor] ;

  var searchSchema = [
    [unifiedFlavor,     "in:inbox", "💡"],
    [unfilteredFlavor,  "", "📖"], // 📰
    [splitFlavor,       "in:inbox (is:starred OR is:important OR label:~GSS)", "❤"],
    [splitFlavor,       "in:inbox -is:starred -is:important -label:~GSS", "💤"],
    [unimportantFlavor, "in:inbox -is:starred -is:important", "💩"],
  ];

  function labelTextToLabelName(labelText) {
    return labelText.split("(")[0] ;
  }

  function labelNameToSearchName(labelName) {
    return flavors.reduce(function(labelName, flavor) {
      if (flavor.test(labelName)) {
        return labelName.split(flavor)[1] ;
      }
      return labelName ;
    }, labelName) ;
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

  function forEachLabel(flavor, labels, block) {
    for (var j = 0; j < labels.length; ++j) {
      var labelText = labels[j].textContent ;
      if (flavor.test(labelText)) {
        var labelName = labelTextToLabelName(labelText);
        var searchName = labelNameToSearchName(labelName) ;

        block(labelText, labelName, searchName);
      }
    }  
  }

  function buildSearchLinks(flavor, filter, searchNamePrefix, labels, widget) {
    forEachLabel(flavor, labels, function(labelText, labelName, searchName) {
      widget.appendChild(createSearchLink(
        labelName,
        filter,
        searchNamePrefix + " " + searchName));
    });
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

    searchSchema.forEach(function(schemaSpec) {
      var flavor = schemaSpec[0] ;
      var filter = schemaSpec[1] ;
      var symbol = schemaSpec[2] ;

      buildSearchLinks(flavor, filter, symbol, labels, widget);
    }) ;
  }
};
console.log("flavorjones setting timer ...");
setTimeout(flavorjonesSearch, 5000);

//
//  handle keypresses
//
document.addEventListener('keyup', function(event) {
  if (event['key'] == "Escape") {
    // toggle visibility of the productivity-mode sidebar
    var sidebarCss = "body>div>div.nH>div.nH>div.nH>div.no>:first-child";
    var sidebar = document.body.querySelector(sidebarCss);
    sidebar.classList.toggle("flavorjonesVisible");
  }
});
