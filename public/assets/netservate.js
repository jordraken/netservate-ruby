$(document).ready(function(){
  console.log('Netservate Active');
  $("#log-table").load("../log/log.html");
  setInterval(function() {
    $("#log-table").load("../log/log.html");
  }, 30000);
});
