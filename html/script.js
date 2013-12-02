function plotDonut(value1, value2, label1, label2, id) {
  var data = [];

  if(value1 > 0) {
    data.push({ value: value1, label: label1 });
  }

  if(value2 > 0){
    data.push({ value: value2, label: label2 });
  }

  console.log(data);
  Morris.Donut({
    element: id,
    data: data,
    colors: [
      '#0C0',
      '#F00'
    ]
  })
}

function plotLine(id, data, ykeys, labels) {
  Morris.Line({
    element: id,
    data: data,
    xkey: 'timestamp',
    ykeys: ykeys,
    labels: labels,
    lineColors: [
      '#0C0',
      '#F00'
    ],
    dateFormat: function (x) { return new Date(x).toDateString(); }
  });
}

function lastReport(data) {
  return data.sort(function(a, b){
    var keyA = new Date(a.timestamp),
    keyB = new Date(b.timestamp);

    if(keyA < keyB) return -1;
    if(keyA > keyB) return 1;
    return 0;
  }).slice(-1)[0];
}

function dateHeader(last_report) {
  var date = new Date(last_report.timestamp);
  var d = date.toString().split(' ');
  return date_string = [d[3], d[1], d[2], d[4]].join(' ');
}

function setHeader(last_report) {
  $('.js-report-date').text("Latest report from " + dateHeader(last_report));
}

$(document).ready(function(){
  last_report = lastReport(data);

  setHeader(last_report);

  plotDonut(last_report.r10, last_report.r11, '1. Classes under 100 lines', '1. Classes more than 100 lines', 'pie1');
  plotDonut(last_report.r20, last_report.r21, '2. Methods under 5 lines', '2. Methods more than 5 lines', 'pie2');
  plotDonut(last_report.r30, last_report.r31, '3. Method calls with less than 4 params', '3. Method calls with more than 4 params', 'pie3');
  plotDonut(last_report.r40, last_report.r41, '4. Controllers with one instance variable', '4. Controllers with many instance variables', 'pie4');

  plotLine('plot1', data, ['r10', 'r11'], ['under 100 lines', 'more than 100 lines.']);
  plotLine('plot2', data, ['r20', 'r21'], ['under 5 lines', 'more than 5 lines']);
  plotLine('plot3', data, ['r30', 'r31'], ['less than 4 params', 'more than 4 params']);
  plotLine('plot4', data, ['r40', 'r41'], ['one instance variable', 'many instance variables']);

  var $tabs = $(".js-tab-item");
  var $menuItems = $(".js-menu-item")
  $menuItems.on("click", function(e){
    var rel = $(this).data("rel");
    $tabs.hide();
    $menuItems.removeClass("main-menu-active");
    $(rel).show();
    $(this).addClass("main-menu-active");
    e.preventDefault();
  });
})
