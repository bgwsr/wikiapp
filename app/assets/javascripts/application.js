// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery_ujs
//= require turbolinks
//= require markdown
//= require to-markdown
//= require bootstrap-markdown
//= require autoblend
//= require_tree .


window.location.hash = "";
var data = {collection: '', country: ''};

$('[data-target="choose_country"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  $('#thanks').addClass('hide');
  $('#choose_country').removeClass('hide');
});


$('[data-target="add_startup"]').click(function(e){
  e.preventDefault();
  if ( $('#ddn_country').val().length == 0 )
  {
    alert( "Please select a country" );
    return false;
  }
  $('.form').addClass('hide');
  data.collection = 'Startups';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_startup').removeClass('hide');
});


$('[data-target="add_investor"]').click(function(e){
  e.preventDefault();
  if ( $('#ddn_country').val().length == 0 )
  {
    alert( "Please select a country" );
    return false;
  }
  $('.form').addClass('hide');
  data.collection = 'Investors';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_investor').removeClass('hide');
});


$('[data-target="add_community"]').click(function(e){
  e.preventDefault();
  if ( $('#ddn_country').val().length == 0 )
  {
    alert( "Please select a country" );
    return false;
  }
  $('.form').addClass('hide');
  data.collection = 'Communities';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_community').removeClass('hide');
});


$('[data-target="add_people"]').click(function(e){
  e.preventDefault();
  if ( $('#ddn_country').val().length == 0 )
  {
    alert( "Please select a country" );
    return false;
  }
  $('.form').addClass('hide');
  data.collection = 'People';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_people').removeClass('hide');
});


$('[data-target="add_opportunity"]').click(function(e){
  e.preventDefault();
  if ( $('#ddn_country').val().length == 0 )
  {
    alert( "Please select a country" );
    return false;
  }
  $('.form').addClass('hide');
  data.collection = 'Opportunities';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_opportunity').removeClass('hide');
});

$('[id*="btn_submit_"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  s_json = '';
  if (data.collection == 'Startups')
  {
    s_json = collect_startup();
  }
  
  if (data.collection == 'Investors')
  {
    s_json = collect_investor();
  }
  
  if (data.collection == 'Communities')
  {
    s_json = collect_community();
  }
  
  if (data.collection == 'People')
  {
    s_json = collect_person();
  }
  
  if (data.collection == 'Opportunities')
  {
    s_json = collect_opportunity();
  }
  
  if ( $('#hdn_category').length )
  {
    s_json = eval("collect_"+$('#hdn_category').val()+"()");
  }
  
  if (s_json.length)
  {
    $.ajax({
      url: '/api/submissions',
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json',
      processData: false,
      data: s_json,
      success: function(o_return, s_status, o_xhr) {
        location.href = "/";
      }
    });
  }
  
  $('#starting_point').removeClass('hide');
});

$('a.list-group-item').click(function(){
  $('#editor textarea').val($(this).find('.data-description').html());
  $('#editor .modal-title').text($(this).find('.data-title').val());
  $('#editor #btn_reject').attr('data-id', $(this).find('.data-id').val());
});

$('a.picker').click(function(e){
  e.preventDefault;
  var key = $(this).parents('[data-key]:first').attr('data-key');
  $('[data-key="'+key+'"]').find('.glyphicon-check').addClass('glyphicon-unchecked').removeClass('glyphicon-check');
  $('[data-key="'+key+'"]').parents('.form-group').removeClass('has-success');
  $(this).attr('href', 'javascript:void(0);');
  $(this).find('.glyphicon').toggleClass('glyphicon-unchecked').toggleClass('glyphicon-check');
  if ($(this).find('.glyphicon-check').length)
  {
    $(this).parents('.form-group').addClass('has-success');
    $('#'+key).val( $(this).prev('input,textarea').val() );
  }
});

$('#btn_silk_submit').click(function(){ 
  btn = $(this);
  $(this).attr('disabled', '');
  var enabled = $(this).html();
  $(this).html($(this).attr('data-disable-with'));
  $.ajax({
    url: '/api/submissions/merge',
    type: 'POST',
    dataType: 'json',
    contentType: 'application/json',
    processData: false,
    data: '{"status": "approved", '
            +'"category": "'+encodeURI($('#silk_category').val())+'", '
            +'"silk_identifier": "'+encodeURI($('#silk_identifier').val())+'", '
            +'"content": "'+encodeURI(markdown.toHTML($('.md-input').val()))+'"}',
    complete: function() {
      $('input[type="text"],textarea').val('');
      btn.html(enabled);
      btn.removeAttr('disabled');
      location.href = "/moderator"
    }
  });
});

$('.markdown-data').each(function(){
  $(this).markdown({
    autofocus: true,
    savable: false,
    onSave: function(e) {
  /*
      $('.markdown-data').html( markdown.toHTML(e.getContent()) );
      $('form.ticket-edit').addClass('hide');
      $('[data-form=".ticket-edit"]').show();
      description = $('form.ticket-edit #ticket_description').val().replace(/\n/g, "\\n");
      $.ajax({
        url: '/api/ticket/update/'+$('form.ticket-edit #ticket_id').val(),
        type: 'POST',
        processData: false,
        dataType: 'json',
        contentType: 'application/json',
        data: '{"ticket":{"description":"'+description+'"}}'
      });
  */
    }
  });
});

$('#btn_reject').click(function(){
  var submission_id = $(this).attr('data-id');
  $('#lgi_'+submission_id).remove();
  $('#mdl_reject #data_id').val($(this).attr('data-id'));
});

$('#mdl_reject #btn_submit_reason').click(function(){
  $.ajax({
    url: '/api/submissions/'+$('#mdl_reject #data_id').val(),
    type: 'PATCH',
    dataType: 'json',
    contentType: 'application/json',
    processData: false,
    data: '{"status": "rejected", "reason": "'+encodeURI($('#body_why').val())+'"}',
    complete: function() {
      
    }
  });
  $('#mdl_reject #data_id').val("");
  $('#mdl_reject #body_why').val("");
});

function check_if_edit()
{
  var r = '';
  if ( $('#wsw_id').length && $('#wsw_id').val() != "" )
  {
    r = ',"id":"'+$('#wsw_id').val()+'"';
  }
  return r;
}

function collect_startup()
{
  s_json = '{"collection":"Startups","silk_identifier":"'+encodeURI($('#startup_name').val())+'",'
  s_json = s_json + '"country": "'+encodeURI($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+encodeURI($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"startups"}';
  s_json = s_json + ',{"title":"'+encodeURI($('#startup_name').val())+'"}';
  s_json = s_json + ',{"year_founded":"'+encodeURI($('#startup_year').val())+'"}';
  s_json = s_json + ',{"valuation":"'+encodeURI($('#startup_valuation').val())+'"}';
  s_json = s_json + ',{"city":"'+encodeURI($('#startup_city').val())+'"}],';
  s_json = s_json + '"body":"'+encodeURI($('#startup_description').val())+'"}';
  s_json = s_json + check_if_edit();
  s_json = s_json + '}';
  
  return s_json;
}

function collect_investor()
{
  s_json = '{"collection":"Investors","silk_identifier":"'+encodeURI($('#investor_name').val())+'",'
  s_json = s_json + '"country": "'+encodeURI($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+encodeURI($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"investors"}';
  s_json = s_json + ',{"title":"'+encodeURI($('#investor_name').val())+'"}';
  s_json = s_json + ',{"city":"'+encodeURI($('#investor_city').val())+'"}],';
  s_json = s_json + '"body":"'+encodeURI($('#investor_description').val())+'"}';
  s_json = s_json + check_if_edit();
  s_json = s_json + '}';
  
  return s_json;
}

function collect_community()
{
  s_json = '{"collection":"Communities","silk_identifier":"'+encodeURI($('#community_name').val())+'",'
  s_json = s_json + '"country": "'+encodeURI($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+encodeURI($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"communities"}';
  s_json = s_json + ',{"title":"'+encodeURI($('#community_name').val())+'"}';
  s_json = s_json + ',{"city":"'+encodeURI($('#community_city').val())+'"}],';
  s_json = s_json + '"body":"'+encodeURI($('#community_description').val())+'"}';
  s_json = s_json + check_if_edit();
  s_json = s_json + '}';
  
  return s_json;
}

function collect_person()
{
  s_json = '{"collection":"People","silk_identifier":"'+encodeURI($('#person_name').val())+'",'
  s_json = s_json + '"country": "'+encodeURI($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+encodeURI($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"people"}';
  s_json = s_json + ',{"title":"'+encodeURI($('#person_name').val())+'"}';
  s_json = s_json + ',{"city":"'+encodeURI($('#person_city').val())+'"}],';
  s_json = s_json + '"body":"'+encodeURI($('#person_description').val())+'"}';
  s_json = s_json + check_if_edit();
  s_json = s_json + '}';
  
  return s_json;
}

var market_saturation = null;
function tag_label( label )
{
  return encodeURI( label )
}
function collect_opportunity()
{
  title = $('#opportunity_name').val()+' - '+$('#ddn_country').val();
  s_json = '{"collection":"Opportunities","silk_identifier":"'+encodeURI(title)+'",'
  s_json = s_json + '"country": "'+encodeURI($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[';
  
  /* usual tags */
  s_json = s_json + '{"country": "'+encodeURI($('#ddn_country').val())+'"},';
  s_json = s_json + '{"category":"opportunities"},';
  
/* category specific tags */
  s_json = s_json + '{"Local%20Market%20Leader": "'+encodeURI($('#local_leader_name').val())+'"},';
  s_json = s_json + '{"Local%20Players":"'+encodeURI($('#local_players').val())+'"},';
  
  market_saturation = new SaturationTicker().init({
    value: $('#market_saturation').val()
  });
  s_json = s_json + '{"Market%20Saturation%20Color":"'+market_saturation.color+'"},';
  s_json = s_json + '{"Market%20Saturation":"'+market_saturation.value+'"},';

  var mobile_saturation = new SaturationTicker().init({
    value: $('#m_market_saturation').val()
  });
  s_json = s_json + '{"Mobile%20Market%20Saturation%20Color":"'+mobile_saturation.color+'"},';
  s_json = s_json + '{"Mobile%20Market%20Saturation":"'+mobile_saturation.value+'"}';
  
  s_json = s_json + '],';
/* end of "content":{"tags":[ */

  s_json = s_json + '"body":"'+encodeURI($('#opportunity_comments').val())+'"}';
  s_json = s_json + check_if_edit();
  s_json = s_json + '}';
  
  return s_json;
}



$('button[data-reject-id]').click(function(){
  
  $('#mdl_reject #data_id').val($(this).attr('data-reject-id'));
  $('#mdl_reject').modal('show');
  
});


var SaturationTicker = function() {
  this.value = '';
  this.color = encodeURI('http://i.imgur.com/OKqBu1h.png');
  
  this.init = function(options) {
    if (typeof options.value != 'undefined')
    {
      this.set_saturation(parseInt(options.value));
    }
    return this;
  }
  
  this.set_saturation = function( saturation ) {
    switch (saturation)
    {
      case 4:
        this.value = 'Saturated';
        this.color = encodeURI('http://i.imgur.com/iZIQQ9r.png');
        break;
      case 3:
        this.value = 'Mature';
        this.color = encodeURI('http://i.imgur.com/Xt6hcOv.png');
        break;
      case 2:
        this.value = encodeURI('Semi-mature');
        this.color = encodeURI('http://i.imgur.com/Wqp7b5o.png');
        break;
      case 1:
        this.value = 'Infancy';
        this.color = encodeURI('http://i.imgur.com/3n1OCMq.png');
        break;
      case 0:
        this.value = encodeURI('Non-existent');
        this.color = encodeURI('http://i.imgur.com/OKqBu1h.png');
        break;
    }
  }
  
}