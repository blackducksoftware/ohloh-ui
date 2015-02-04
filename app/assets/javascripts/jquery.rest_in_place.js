/* Copyright (c) 2007 [Jan Varwig]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// modifications Copyright (c) 2008 Ohloh Corporations, released
// under same terms and limitations as above

jQuery.fn.rest_in_place = function(url, objectName, attributeName) {
  var e = $(this);

  function tearDown(node) {
    node.click(clickFunction);
    var pencil = $(node.siblings(".rest_in_place_helper"));
    pencil.fadeIn();
  }

  function clickFunction() {
    var oldValue = jQuery.trim(e.html());
    $(e.siblings(".rest_in_place_helper")).fadeOut("slow")
    var cols = e.attr('col') || 50;
    var rows = e.attr('rows') || 4;
    var max_length = e.attr('max_length');
    e.html('<form action="javascript:void(0)" style="display:inline;"><textarea max_length="' +max_length+ '" class="rest_in_peace" cols="' + cols + '" style="overflow:hidden" rows="'+rows+'" type="text" value="' + oldValue + '"/></form>');
    e.find("textarea")[0].select();
    e.find("textarea").html(oldValue);
    e.find("textarea").keypress(function(key) {
      if (key!=null && key.which == 13)
        e.find("form").submit();
        else if (key!=null && key.which == 27) { // ESC - work in MSIE?
          cancelEditInPlace();
        } else if (key!=null && max_length && e.find("textarea").val().length >= max_length) {
          //alert("The maximum length of this field is " +max_length+ " characters.");
          //e.find("textarea").val(e.find("textarea").val().substring(0,max_length-1) );
        }
      });
      e.unbind('click');
      e.find("form").submit(submitEditInPlace);
      createButtons();
      hookEdit();
      function cancelEditInPlace() {
        e.html(oldValue);
        tearDown(e);
        return false;
      };
      function hookEdit() {
        var html = '<br/><input readonly type="text" class="input-mini input-mini-num" name="remaining" size="5" maxlength="5" value="" disabled="true"></input><span style="font-size:8.5pt;vertical-align: text-top;"> characters left</span>';
        e.append(html);
        e.find('textarea[max_length]').keyup(function() {
          var m = parseInt(e.attr('max_length'));
          var l = this.value.length;
          if (l > m) {
            this.value = this.value.substring(0, m);
          } else {
            e.find('input[name="remaining"]')[0].value = m - l;
          }
        }).trigger('keyup');
      }
      function createButtons() {
        var submitButton = $('<button type="submit" class="btn btn-small btn-primary">');
        submitButton.html('Submit');
        submitButton.click(submitEditInPlace);
        e.find("form").append(submitButton);

        var cancelButton = $('<button type="cancel" class="btn btn-small">');
        cancelButton.html('Cancel');
        cancelButton.click(cancelEditInPlace);
        e.find("form").append(cancelButton);
      }
      function submitEditInPlace(){
        var value = e.find("textarea").val();
        e.html("saving...");
        jQuery.ajax({
          url : url,
          type : "put",
          data : "_method=put&"+objectName+'['+attributeName+']='+encodeURIComponent(value),
          error : function (xml_http_request, textStatus, errorThrown) {
            alert('Error: ' + xml_http_request.responseText);
            cancelEditInPlace();
          },
          success : function() {
            jQuery.ajax({
              "url" : url,
              dataType: "json",
              "beforeSend" : function(xhr) { xhr.setRequestHeader("Accept", "application/json"); },
              "success" : function(jsondata, status){
                e.html(jsondata[attributeName]);
                tearDown(e);
                return false;
              }
            });
            return false;
          }
        });
        return false;
      }
    }
    this.unbind('click').click(clickFunction);
  }

  RestInPlace = {
    init: function(){
      $(".rest_in_place").each(function(){
        RestInPlace.init_one(this);
      });
      // make the pencils act just like you clicked on the item
      $(".rest_in_place_helper").click(function() {
        $(this).siblings('.rest_in_place').click();
      });
    },
    init_one: function(node) {
      var e = $(node);
      var url; var obj; var attrib;
      e.parents().each(function(){
        url    = url    || $(this).attr("url");
        obj    = obj    || $(this).attr("object");
        attrib = attrib || $(this).attr("attribute");
      });
      e.parents().each(function(){
        if (res = this.id.match(/^(\w+)_(\d+)$/i)) {
          obj = obj || res[1];
        }
      });
      url    = e.attr("url")       || url    || document.location.pathname;
      obj    = e.attr("object")    || obj;
      attrib = e.attr("attribute") || attrib;
      e.rest_in_place(url, obj, attrib);
    }
  }

  jQuery(function(){ RestInPlace.init(); });
