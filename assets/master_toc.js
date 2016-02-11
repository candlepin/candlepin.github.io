'use strict';
// Create a JQuery plugin function to adjust sidebar height
(function($) {
  $.fn.sidebar = function () {
    var documentHeight = 0;
    var navbarHeight = 0;
    var footerHeight = 0;
    var colHeight = 0;

    $('.index-column').parent('.row').children('[class*="col-"]').css({"min-height": ""});
    if ($('.navbar .navbar-toggle').is(':hidden')) {
      documentHeight = $(document).height();
      footerHeight = $('footer').outerHeight();
      navbarHeight = $('header').outerHeight();
      colHeight = documentHeight - navbarHeight - footerHeight;

      $('.index-column').parent('.row').children('[class*="col-"]').css({"min-height": colHeight});
    }
    return this;
  };
}(jQuery));

var plus = "glyphicon-plus";
var minus = "glyphicon-minus";
var glyph = "glyphicon";
// Which level should be collapsed by default
var default_level_collapse = 2;

$(document).ready(function() {
  var collapsed_items = $('li[data-level]').filter(function() {
    // If this node is highlighted or if its sibling is highlighted, we need to show this node.
    var should_be_expanded = $(this).hasClass('highlight-node') || $(this).siblings('.highlight-node').length !== 0;
    // Close all subsections that are on level > default_level_collapse
    return $(this).attr('data-level') > default_level_collapse && !should_be_expanded;
  });

  // 0 means slide up quickly :-)
  collapsed_items.slideUp(0);

  $("span.hide_link").addClass(glyph);
  // Set all hide_links to 'minus' by default
  $("span.hide_link").addClass(minus);

  // Set all hide links on levels below default_level_collapse to plus
  var expandable_items =
    $("li[data-level = '" + default_level_collapse + "'] > span.hide_link").filter(function(i, e) {
      // Due to the way the Jekyll template constructs the DOM, each sub-section is actually an unordered-list that
      // immediately follows the logical parent.
      return !($(e).parent().next().children('.highlight-node').length !== 0);
    });
  // Special exemption for a highlighted node that is actually a logical parent.  Always set this to a plus
  expandable_items = expandable_items.add($('li[data-level]').filter('li.highlight-node').children('span.hide_link'));
  expandable_items.removeClass(minus).addClass(plus);

  // Resize the sidebar
  if ($('.index-column').length > 0) {
    $(this).sidebar();
  }

  $(".hide_link").click(function(event) {
      // Class and level of wrapper li.
      var this_parent = $(this).parent();

      // Note that this call to filter is using Javascript's Array filter function and not
      // JQuery's Element filter function.  Conveniently, the argument order for the two
      // is reversed.  Array is function(element, index) while Element is
      // function(index, element).  Thanks Javascript!
      var this_level_class = this_parent.attr('class').split(/\s+/).filter(function(e) {
        return e !== "highlight-node";
      }).join(' ');
      var this_data_level = this_parent.attr('data-level');

      var sublevels = $("li[class*='" + this_level_class + ".']");
      var sublevels_with_children = $("li[class*='" + this_level_class + ".'] > span.hide_link");

      var collapsed_sublevel_items = sublevels.filter(function(i, e) {
        // Close all subsections that are more than 1 level down
        return $(e).attr('data-level') > (parseInt(this_data_level, 10) + 1);
      });

      if ($(this).hasClass(plus)) {
        $(this).removeClass(plus).addClass(minus);

        // when sliding down, we always have to change the hide_links to plus
        // so they can be expanded
        sublevels_with_children.removeClass(minus).addClass(plus);

        sublevels.filter(function(i, e) {
            // Remove items that should be collapsed
            return $.inArray(e, collapsed_sublevel_items) === -1;
        }).slideDown(function() {
          // Resize the sidebar after all animations are complete
          if ($('.index-column').length > 0) {
            $(this).sidebar();
          }
        });
      }
      else {
        $(this).removeClass(minus);
        $(this).addClass(plus);
        sublevels.slideUp(function() {
          if ($('.index-column').length > 0) {
            $(this).sidebar();
          }
        });
      }
  });
});

$(window).resize(function () {
  // Call sidebar() on resize if .index-column exists
  if ($('.index-column').length > 0) {
    $(this).sidebar();
  }
});
