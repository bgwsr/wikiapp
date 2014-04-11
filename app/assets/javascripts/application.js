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
//= require_tree .


window.location.hash = "";
var data = {collection: '', country: ''};

$('[data-target="choose_country"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  $('#thanks').fadeOut();
  $('#choose_country').removeClass('hide');
});


$('[data-target="add_startup"]').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  data.collection = 'startup';
  data.country = $('#ddn_country').val();
  $('#choose_country,#thanks').addClass('hide');
  $('#add_startup').removeClass('hide');
});

$('#btn_submit').click(function(e){
  e.preventDefault();
  $('.form').addClass('hide');
  if (data.collection == 'startup')
  {
    data.name = $('#startup_name').val();
    data.year = $('#startup_year').val();
    data.valuation = $('#startup_valuation').val();
    data.city = $('#startup_city').val();
    data.context = $('#startup_description').val();
  }
  $('#starting_point').removeClass('hide');
});
