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
  $('.form').addClass('hide');
  data.collection = 'Startup';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_startup').removeClass('hide');
});


$('[data-target="add_investor"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  data.collection = 'Investor';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_investor').removeClass('hide');
});


$('[data-target="add_community"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  data.collection = 'Community';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_community').removeClass('hide');
});

$('[id*="btn_submit_"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  s_json = '';
  
  if (data.collection == 'Startup')
  {
    s_json = collect_startup();
  }
  
  if (data.collection == 'Investor')
  {
    s_json = collect_investor();
  }
  
  if (data.collection == 'Community')
  {
    s_json = collect_community();
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
        console.log(o_return);
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
    $('#'+key).val( $(this).prev('input').val() );
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
            +'"category": "'+escape($('#silk_category').val())+'", '
            +'"silk_identifier": "'+escape($('#silk_identifier').val())+'", '
            +'"content": "'+escape(markdown.toHTML($('.md-input').val()))+'"}',
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
    data: '{"status": "rejected", "reason": "'+escape($('#body_why').val())+'"}',
    complete: function() {
      
    }
  });
  $('#mdl_reject #data_id').val("");
  $('#mdl_reject #body_why').val("");
});

function collect_startup()
{
  s_json = '{"collection":"Startup","silk_identifier":"'+escape($('#startup_name').val())+'",'
  s_json = s_json + '"country": "'+escape($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+escape($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"Startup"}';
  s_json = s_json + ',{"title":"'+escape($('#startup_name').val())+'"}';
  s_json = s_json + ',{"year_founded":"'+escape($('#startup_year').val())+'"}';
  s_json = s_json + ',{"valuation":"'+escape($('#startup_valuation').val())+'"}';
  s_json = s_json + ',{"city":"'+escape($('#startup_city').val())+'"}],';
  s_json = s_json + '"body":"'+$('#startup_description').val()+'"}';
  s_json = s_json + '}';
  
  return s_json;
}

function collect_investor()
{
  s_json = '{"collection":"Investor","silk_identifier":"'+escape($('#investor_name').val())+'",'
  s_json = s_json + '"country": "'+escape($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+escape($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"Investor"}';
  s_json = s_json + ',{"title":"'+escape($('#investor_name').val())+'"}';
  s_json = s_json + ',{"city":"'+escape($('#investor_city').val())+'"}],';
  s_json = s_json + '"body":"'+$('#investor_description').val()+'"}';
  s_json = s_json + '}';
  
  return s_json;
}

function collect_community()
{
  s_json = '{"collection":"Community","silk_identifier":"'+escape($('#community_name').val())+'",'
  s_json = s_json + '"country": "'+escape($('#ddn_country').val())+'",';
  s_json = s_json + '"content":{"tags":[{"country": "'+escape($('#ddn_country').val())+'"}';
  s_json = s_json + ',{"category":"Community"}';
  s_json = s_json + ',{"title":"'+escape($('#community_name').val())+'"}';
  s_json = s_json + ',{"city":"'+escape($('#community_city').val())+'"}],';
  s_json = s_json + '"body":"'+$('#community_description').val()+'"}';
  s_json = s_json + '}';
  
  return s_json;
}