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
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

$(function(){ $(document).foundation(); });

function handleNagUpdate(){
  newNagContents = createdInput.val();
  $.ajax({
    type: "PATCH",
    url: "/nags/" + nagId,
    data: {
      nag: {
        contents: newNagContents
      }
    }
  }).done(function() {
    createdForm.remove();
    clickedCell.append("<span class='nag-contents'>" + newNagContents + "</span>");
    bindNagUpdate();
  }).fail(function() {
    alert("Update Unsuccessful.");
    createdForm.remove();
    clickedCell.append("<span class='nag-contents'>" + originalContents + "</span>");
    bindNagUpdate();
  });
};

function bindNagUpdate() {
  $(".nag-contents").click(function(event) {
    clickedContents = $(this);
    originalContents = clickedContents.text().trim();
    clickedCell = clickedContents.parent();
    clickedContents.remove();
    clickedCell.append("<form class='edit-nag-form'><input class='small-12 columns edit-nag-input'></form>");
    createdInput = $(".edit-nag-input");
    createdForm = $(".edit-nag-form");
    createdInput.val(originalContents).focus();
    nagId = clickedCell.parent().attr("id");

    createdInput.focusout(function() {
      handleNagUpdate();
    });

    createdForm.submit(function() {
      handleNagUpdate();
      return false
    });
  });
};

function bindNagDone() {
  $(".nag-done").click(function(event) {

    $.ajax({
      type: "PUT",
      url: '/nags/' + this.children[0].value + '/done',
      dataType: 'json'
    });

    $(this.parentElement).fadeOut();
  });
};

$(document).ready(function(){
  bindNagUpdate();
  bindNagDone();

// ADD CREATE NAG HERE
//  $(".nag").last().append("<tr></tr>");
});
