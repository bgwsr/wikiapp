
function autoblend(selector)
{
  $(selector).each(function(){
    if ( typeof $(this).css('background-color') != 'undefined' )
    {
      if (eval($(this).css('background-color')))
      {
        $(this).css('color', "#555");
        if ( $(this).hasClass('badge') )
        {
          $(this).css('border-right', "1px solid #ddd");
          $(this).css('border-bottom', "1px solid #ddd");
        }
      }
      else
      {
        $(this).find('.close').addClass('inverted');
      }
    }
    blend_close_button($(this));
  });
}

function blend_close_button(parent)
{
  parent.find('.close')
}

function rgb(R,G,B) { return R + G > 400 || R + B > 400 || G + B > 400; }
function toHex(n) {
 n = parseInt(n,10);
 if (isNaN(n)) return "00";
 n = Math.max(0,Math.min(n,255));
 return "0123456789ABCDEF".charAt((n-n%16)/16)
      + "0123456789ABCDEF".charAt(n%16);
}