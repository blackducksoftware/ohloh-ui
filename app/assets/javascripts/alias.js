 var Alias = {
   init: function() {
     $('.alias #commit_name_id').change(Alias.update_preferred_names).change();
   },
   before: function() {
     $('.alias #submit_button').hide();
     $('.alias .spinner').show();
   },
   after: function() {
     $('.alias #submit_button').show();
     $('.alias .spinner').hide();
     $('.alias select#preferred_name_id').chosen()
   },
   update_preferred_names: function() {
     Alias.before();
     $.ajax({
       url: $(this).attr('url') + '?commit_name_id=' + $('#commit_name_id').val(),
       success: function(html) {
         $('.alias #preferred_name').html(html);
         Alias.after();
       }
     });
   }
 }
