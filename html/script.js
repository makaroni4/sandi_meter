function plotDonut(value1, value2, label1, label2, id) {
  var data = [];

  if(value1 > 0) {
    data.push({ value: value1, label: label1 });
  }

  if(value2 > 0){
    data.push({ value: value2, label: label2 });
  }

  Morris.Donut({
    element: id,
    data: data,
    colors: [
      '#0C0',
      '#F00'
    ]
  })
}

function plotLine(selector, data, ykeys, labels, ymax_value) {
  var ymax_value = typeof ymax_value !== 'undefined' ? ymax_value : 'auto';
  var graph = Morris.Line({
    element: $(selector),
    data: data,
    xkey: 'timestamp',
    ykeys: ykeys,
    ymax: ymax_value,
    labels: labels,
    lineColors: [
      '#0C0',
      '#F00'
    ],
    dateFormat: function (x) {
      return new Date(x).toDateString();
    }
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

function calculate_percentage(row) {
  [1,2,3,4].forEach(function(rule) {
    var green_index = "r" + rule + "0";
    var red_index = "r" + rule + "1";
    var total = row[green_index] + row[red_index];
    row[green_index + "p"] = total == 0 ? 0 : Math.round(100 * row[green_index] / total, 0);
    row[red_index + "p"] = total == 0 ? 0 : Math.round(100 * row[red_index] / total, 0);
  })
}

function calculate_percentage_data(data) {
  data.forEach(function(row){
    calculate_percentage(row);
    row["overall"] = Math.round((row["r10p"] + row["r20p"] + row["r30p"] + row["r40p"]) / 4, 0);
  })
}

$(document).ready(function(){
  last_report = lastReport(data);
  calculate_percentage_data(data);

  $(".charts-percentage").html($(".plot-charts").html());

  setHeader(last_report);

  plotDonut(last_report.r10, last_report.r11, '1. Classes under 100 lines', '1. Classes more than 100 lines', 'pie1');
  plotDonut(last_report.r20, last_report.r21, '2. Methods under 5 lines', '2. Methods more than 5 lines', 'pie2');
  plotDonut(last_report.r30, last_report.r31, '3. Method calls with less than 4 params', '3. Method calls with more than 4 params', 'pie3');
  plotDonut(last_report.r40, last_report.r41, '4. Controllers with one instance variable', '4. Controllers with many instance variables', 'pie4');

  plotLine('.plot-charts .plot1', data, ['r10', 'r11'], ['under 100 lines', 'more than 100 lines.'], 'auto');
  plotLine('.plot-charts .plot2', data, ['r20', 'r21'], ['under 5 lines', 'more than 5 lines'], 'auto');
  plotLine('.plot-charts .plot3', data, ['r30', 'r31'], ['less than 4 params', 'more than 4 params'], 'auto');
  plotLine('.plot-charts .plot4', data, ['r40', 'r41'], ['one instance variable', 'many instance variables'], 'auto');

  plotLine('.charts-percentage .plot1', data, ['r10p'], ['under 100 lines'], 100);
  plotLine('.charts-percentage .plot2', data, ['r20p'], ['under 5 lines'], 100);
  plotLine('.charts-percentage .plot3', data, ['r30p'], ['less than 4 params'], 100);
  plotLine('.charts-percentage .plot4', data, ['r40p'], ['one instance variable'], 100);

  plotLine('.progress .plot', data, ['overall'], ['Overall progress'], 100);

  $(".charts-percentage").hide();
  $(".progress").hide();

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
