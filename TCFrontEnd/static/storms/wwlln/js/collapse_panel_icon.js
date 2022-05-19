
  /* Once the document is loaded. */
$(document).ready(function() {
  var icon_panel_open   = "glyphicon-triangle-bottom";
  var icon_panel_closed = "glyphicon-triangle-right";
    /* Update all of the panel headers' icons to the icon representing its open or closed state. */
  $(".panel-heading").each(function() {
    var icon = $(this).find("i.glyphicon");
    if ($(this).attr("aria-expanded") === "true") {
      $(icon).removeClass(icon_panel_closed);
      $(icon).addClass(icon_panel_open);
    } else {
      $(icon).removeClass(icon_panel_open);
      $(icon).addClass(icon_panel_closed);
    }
  });

    /* Listen for the expand/collapse events to change the icon to fit the new open/closed state. */
  $(".panel-collapse").on("show.bs.collapse", function(event) {
    if (this !== event.target) { return; }
    var icon = $(this).parent().children(".panel-heading").find("i.glyphicon");
    $(icon).removeClass(icon_panel_closed);
    $(icon).addClass(icon_panel_open);
  }).on("hide.bs.collapse", function(event) {
    if (this !== event.target) { return; }
    var icon = $(this).parent().children(".panel-heading").find("i.glyphicon");
    $(icon).removeClass(icon_panel_open);
    $(icon).addClass(icon_panel_closed);
  });
});
