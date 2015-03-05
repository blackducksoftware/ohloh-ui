// Edit handles setting up undo/redo ajax links
Edit = {
  init: function(){
    Edit.setup_hook('.edit');
    $('label#human_edits :checkbox').click(Edit.human_edits)
  },

  human_edits: function(event){
    if($(this).is(':checked')){
      var humanParam = 'human=true'
      if(location.search.indexOf('?') == -1) humanParam = '?' + humanParam;
      if(location.search.match(/\?\w+/) != null) humanParam = '&' + humanParam;
      Edit.setupHumanParam(location.search.replace('&&', '&'), humanParam);
    }else{
      var noHumanParam = location.search.replace('human=true', '');
      Edit.setupHumanParam(noHumanParam, '');
    };
  },

  setupHumanParam: function(locationVal, value){
    var url = location.protocol + '//' + location.host + location.pathname;
    var strippedUrl = '';
    if(location.search.indexOf('page=') != -1){
      strippedUrl =  url + locationVal.replace(/page=\d+/.exec(locationVal)[0], '') + value;
    }else{
      strippedUrl = url + locationVal + value;
    }
    if(strippedUrl.indexOf('?&') == strippedUrl.length - 2) strippedUrl = strippedUrl.replace('?&', '');
    window.location = strippedUrl;
  },

  setup_hook: function(edit_sel){
    $(edit_sel + " .undo," + edit_sel +" .redo").attr('href','#').click(Edit.undo);
  },

  undo: function(){
    $(this).unbind('click').html("Working...");

    var do_undo = $(this).hasClass('undo');
    /* START -- Identifying the page (Orgs or Project) and passing the respective params and value
      so that when Undo/Redo happens, the edit.subject for Orgs gets manipaulated accordingly */
    var is_org_page = location.pathname.indexOf("/orgs/") == 0;
    var is_project_page = location.pathname.indexOf("/p/") == 0;
    var parent_id = $(this).closest('tr').attr("parent_id");
    if (is_org_page == true)
      var extra_params = "&organization_id="+parent_id;
    else if (is_project_page == true)
      var extra_params = "&project_id="+parent_id;
    else
      var extra_params = "";
    /* END */
    $(this).parents('div.edit').each(function() {
      var object_id = $(this).closest('tr').attr("id").slice(5);
      $.ajax({
        object_id: object_id,
        type: "POST",
        timeout: 5000,
        url: "/edits/" + object_id + "?ajax=1"+extra_params,
        data: {_method:'put',undo:do_undo},
        success: function (data, textStatus) {
          var edit_sel = '#edit_'+this.object_id;
          $(edit_sel).replaceWith(data);
          $(edit_sel).ohloh_fade();
          Edit.setup_hook(edit_sel);
        },
        error: function (xml_http_request, textStatus, errorThrown) {
          alert('Error: ' + xml_http_request.responseText);
        }
      });
    });
    return false;
  }
}
