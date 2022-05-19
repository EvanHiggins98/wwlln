$(document).ready(function() {

  var html_class_name = 'organization_hierarchy_choice';
  for (var i = 0; i < (organizationOptions.length - 1); i++) {
    $('#organization_hierarchy').append('<select class="'
                                        + html_class_name
                                        + '">\n</select>');
  }

  html_class_name = ('.' + html_class_name);

  $(html_class_name).each(function(index) {
    for (var i = 0; i < organizationOptions.length; i++) {
      var opt = organizationOptions[i];
      var html_opt = jQuery('<option/>', {
        class: ('class_' + opt['column_tag']),
        rel:   opt['column_tag'],
        text:  opt['option_text']
      });
      if ((i - 1) == index) {
        html_opt.addClass('selected');
        html_opt.attr('selected', 'selected');
      }
      html_opt.appendTo( $(this) );
    }
  });

  $(html_class_name).selectmenu( {
    change: function( event, ui ) {
      //alert('Hello, World! From: ' + ui);
      $('#organization_hierarchy select.organization_hierarchy_choice option.selected').each(alert('Hello, World!'));
    }
  });
});

