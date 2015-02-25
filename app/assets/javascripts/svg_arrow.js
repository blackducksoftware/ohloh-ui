SVGArrow = {
  generate: function(){
    $('.svg-arrow').each(function(){
      var arrow_path = SVGArrow.generate_arrow_path($(this));
      var svg_elem = $(this);
      var width = parseFloat(svg_elem.attr('svg-width'),0);
      var stick_height = parseFloat(svg_elem.attr('stick-height'),0);
      var height = parseFloat(svg_elem.attr('tip-height'),0);
      var stroke = svg_elem.attr('stroke');
      var border_width = parseFloat(svg_elem.attr('border-stroke'),0);
      var fill_color = svg_elem.attr('fill-color') || "white" ;
      var transform;
      if (svg_elem.attr('arrow-direction') === 'left'){
       transform = "rotate(180," + parseFloat(width/2,0) +","+parseFloat(height/2,0) + ')';
      }else{
        transform = "";
      }
      $(this).append("<svg width='"+ width + "' height='" + height + "'><path fill='"+ fill_color + "'stroke-width='"+ border_width +"' stroke='"+ stroke + "' d='" + arrow_path + "' transform='" + transform + "'/></svg>");
    });
  },

  generate_arrow_path: function(elem){
    var fx1,fy1,nx1,ny1,wx1,wy1,tx1,ty1,wx2,wy2,nx2,ny2,fx2,fy2;
    var svg_elem = elem;
    var arrow_direction = svg_elem.attr('arrow-direction');
    var width = parseFloat(svg_elem.attr('svg-width'),0);
    var stick_height = parseFloat(svg_elem.attr('stick-height'),0);
    var tip_height = parseFloat(svg_elem.attr('tip-height'),0);
    var stick_width = (width * 0.79);
    fx1 = fx2 = 2;
    fy1 = ny1 = parseFloat((tip_height - stick_height ) / 2,0);
    nx1 = wx1 = nx2 = wx2 = parseFloat(stick_width + fx1,0);
    ny1 = parseFloat(Math.sqrt(Math.pow(stick_width,2) - Math.pow((nx1-fx1),2)) + fy1,0);
    wy1 = 0;
    tx1 = parseFloat(width - 2,0);
    ty1 = parseFloat(fy1 + (stick_height/2),0);
    wy2 = tip_height;
    ny2 = parseFloat(tip_height - ny1,0);
    fy2 = parseFloat(fy1 + stick_height,0);
    var path = "M " + fx1 + " " + fy1 + " " + "L " + nx1 + " " + ny1 + " " + "L " + wx1 + " " + wy1 + " " +
     "L " + tx1 + " " + ty1 + " " + "L " + wx2 + " " + wy2 + " " + "L " + nx2 + " " + ny2 + " " + "L " +
      fx2 + " " + fy2 + " " + "L " + fx1 + " " + fy1 + " ";
    return path;
  }};
