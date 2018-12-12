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
  console.log("flavorjones: search ...");
  var searchWidgetClass = "flavorjonesSearch" ;
  var labelListSelector = "*[role=navigation]";

  var uriPrefix = "https://mail.google.com/mail/u/0/#search/" ;
  var labelSelector = ".nU" ;
  // var widgetContainerSelector = "*[role=complementary] .T0" ; // previous widget sidebar tab

  var filterByImportance1 = /^@/ ;
  var findAnywhere        = /^\./ ;
  var filterByGss         = /^_/ ;
  var filterByImportance2 = /^~/ ;
  var flavors = [filterByImportance1, findAnywhere, filterByGss, filterByImportance2] ;

  var permaLinks = [
    {
      'filter': 'label:omg in:inbox -label:.Hiring -label:~Calendar',
      'title': 'OMG'
    },
    {
      'filter': '(label:!!! OR label:omg) in:inbox -label:.Hiring -label:~Calendar',
      'title': 'OMG!!!'
    },
    {
      'filter': '(label:!!! OR label:omg OR label:cfd) in:inbox -label:.Hiring -label:~Calendar is:important',
      'title': 'OMG!!!cfd+i'
    },
    {
      'filter': '(label:!!! OR label:omg OR label:cfd) in:inbox -label:.Hiring -label:~Calendar -is:important',
      'title': 'OMG!!!cfd-i'
    }
  ];

  var searchSchema = [
    [findAnywhere, "", ["", ""]], // 📰
    [filterByImportance1, "in:inbox",
     ["(is:starred OR is:important)", "🡅"],
     ["-is:starred -is:important", "🡇"] // "💩"
    ],
    [filterByGss, "in:inbox -label:.Hiring -label:~Calendar ",
     ["(is:starred OR is:important OR label:~GSS)", "🡅"],
     ["-is:starred -is:important -label:~GSS", "🡇"]
    ],
    [filterByImportance2, "in:inbox -label:.Hiring -label:~Calendar",
     ["(is:starred OR is:important)", "🡅"],
     ["-is:starred -is:important", "🡇"] // "💩"
    ],
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

  function createPermaLink(title, filter) {
    var div = document.createElement("div") ;

    var anchor = document.createElement("a") ;
    var uri = uriPrefix + filter ;
    anchor.setAttribute("href", encodeURI(uri));
    anchor.appendChild(document.createTextNode(title)) ;
    div.appendChild(anchor);

    return div ;
  }

  function createSearchLinks(labelName, defaultFilter, queryFilters, readableName) {
    var div = document.createElement("div") ;

    var anchor = document.createElement("a") ;
    var uri = uriPrefix
        + "label:" + labelName
        + " " + defaultFilter ;
    anchor.setAttribute("href", encodeURI(uri));
    anchor.appendChild(document.createTextNode(readableName)) ;
    div.appendChild(anchor);

    for (var j = 0 ; j < queryFilters.length ; j++) {
      var queryFilter = queryFilters[j][0] ;
      var emoji = queryFilters[j][1] ;

      var anchor = document.createElement("a") ;
      var uri = uriPrefix
          + "label:" + labelName
          + " " + defaultFilter
          + " " + queryFilter ;
      anchor.setAttribute("href", encodeURI(uri));
      anchor.appendChild(document.createTextNode(emoji));
      div.appendChild(anchor);
    }

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

  function buildSearchLinks(flavor, defaultFilter, filters, labels, widget) {
    forEachLabel(flavor, labels, function(labelText, labelName, searchName) {
      widget.appendChild(createSearchLinks(labelName, defaultFilter, filters, searchName));
    });
  }

  var labels = document.body.querySelectorAll(labelSelector);
  if (labels.length > 0) {
    var searchWidget = document.body.querySelector("." + searchWidgetClass) ;
    if (searchWidget) {
      console.log("flavorjones: deleting existing search links");
      searchWidget.remove() ;
    }

    console.log("flavorjones: search building search links");
    var widgetContainer = document.body.querySelector(labelListSelector);

    var widget = document.createElement("div")
    widget.setAttribute("class", searchWidgetClass);

    // widgetContainer.appendChild(widget);
    // widget.appendChild(document.createElement("hr"));
    widgetContainer.insertBefore(widget, widgetContainer.firstChild);

    permaLinks.forEach(function(permaLink) {
      widget.appendChild(createPermaLink(permaLink["title"], permaLink["filter"]));
    });

    widget.appendChild(document.createElement("hr"));

    searchSchema.forEach(function(schemaSpec) {
      var flavor = schemaSpec[0] ;
      var defaultFilter = schemaSpec[1] ;

      var filters = []
      for (var j = 2 ; j < schemaSpec.length ; j++ ) {
        filters.push(schemaSpec[j]);
      }

      buildSearchLinks(flavor, defaultFilter, filters, labels, widget);

      widget.appendChild(document.createElement("hr"));
    }) ;
  }
};
console.log("flavorjones: setting timer ...");
setTimeout(flavorjonesSearch, 5000);
setTimeout(flavorjonesSearch, 10000);
setTimeout(flavorjonesSearch, 20000);

//
//  handle keypresses
//
console.log("flavorjones: keyup handler attached");
document.addEventListener('keyup', function(event) {
  if (event['key'] == "p" &&
      event['ctrlKey'] &&
      event['altKey']) {
    // ctrl-alt-p toggles visibility of the productivity-mode sidebar
    var sidebarSelector = "body>div>div.nH>div.nH>div.nH>div.no>:first-child";
    var sidebar = document.body.querySelector(sidebarSelector);

    var visibleClass = "flavorjonesVisible";
    var searchWidgetClass = "flavorjonesSearch" ;
    var searchWidget = sidebar.querySelector("." + searchWidgetClass) ;

    console.log("flavorjones: toggling productivity sidebar");
    sidebar.classList.toggle(visibleClass);

    if (sidebar.classList.contains(visibleClass)) {
      var firstLink = searchWidget.querySelector("a")
      firstLink.focus();
    }
  }
})
;
