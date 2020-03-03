var view, pgRef, pcRef
var view_lab, pgRef_lab, pcRef_lab



buf_a=[]
onload = function () {

  var getParam = function(key){
      var _parammap = {};
      document.location.search.replace(/\??(?:([^=]+)=([^&]*)&?)/g, function () {
          function decode(s) {
              return decodeURIComponent(s.split("+").join(" "));
          }

          _parammap[decode(arguments[1])] = decode(arguments[2]);
      });

      return _parammap[key];
  };


  // var study = getParam("study_id");
  // var query = getParam("query_id");
  var study_id = getParam("study_id");
  var query_id = getParam("query_id");

 var obj = load(study_id,query_id);
          console.log({obj:obj})
          buf_a =obj;
          //  view(obj);
            //view_flex(obj);
           view_pivot(obj.person);
            //view_demographics(obj);
           view_noti(obj.person);

           view_pivot_lab(obj.lab);
           //view_noti(obj.lab);
           view.refresh();
           pgRef.refresh();
           pcRef.refresh();

           view_lab.refresh();
           pgRef_lab.refresh();
           pcRef_lab.refresh();


  // var obj_diagnoses = load_diagnoses(study, query);
  // view_diagnoses_pivot(obj_diagnoses)

    // // generate some random data
    // var countries = 'US,Germany,UK,Japan,Italy,Greece'.split(','),
    //     data = [];
    // for (var i = 0; i < countries.length; i++) {
    //   data.push({
    //     country: countries[i],
    //     downloads: Math.round(Math.random() * 20000),
    //     sales: Math.random() * 10000,
    //     expenses: Math.random() * 5000
    //   });
    // }
  
    // // create grid and show data
    // var grid = new wijmo.grid.FlexGrid('#theGrid', {
    //   itemsSource: data
    // });
  
    // // create a chart and show the same data    
    // var chart = new wijmo.chart.FlexChart('#theChart', {
    //     itemsSource: data,
    //     bindingX: 'country',
    //     series: [
    //         { name: 'Sales', binding: 'sales' },
    //         { name: 'Expenses', binding: 'expenses' },
    //         { name: 'Downloads', binding: 'downloads', chartType: wijmo.chart.ChartType.LineSymbols } ]
    // });

  }


  function view_noti(data_obj){
    var female=0, male=0
      for (var i = 0; i < data_obj.length; i++) {
        if(data_obj[i].gender=='Male'){
          male +=1;
        }else{
          female +=1;
        }
      }
      var male_value = (male/(male+female)*100)-(male/(male+female)*100)%5;
      var female_value = (female/(male+female)*100)-(female/(male+female)*100)%5
      console.log({
        male_value:male_value,
        female_value:female_value
      })

      $('#male')[0].innerHTML=male;
      $('#female')[0].innerHTML=female;
      $('#male_label').attr("data-label",Math.round((male/(male+female)*100))+"%");
      $('#female_label').attr("data-label",Math.round(female/(male+female)*100)+"%");
      
      $('#male_label').attr("class", "doughnut mt-2 doughnut-primary doughnut-"+male_value);
      $('#female_label').attr("class", "doughnut mt-2 doughnut-warning doughnut-"+female_value);

      
      
      
      
      // document.getElementById("total_study_doughnut").setAttribute("class", "doughnut mt-2 doughnut-primary doughnut-"+(graph_data[0].percent_study-(graph_data[0].percent_study%5)));

      console.log(Math.round(female/(male+female)*100));

      //$('#total')[0].innerHTML=male + female;

  }


  function load(study_id, query_id){
    var req = new XMLHttpRequest();
    req.open('post', `http://192.1.170.194:52273/test-protocol-advanced/${study_id}/${query_id}`,false);
    req.send();

   return JSON.parse(req.responseText);


  }


  function load_diagnoses(study_id, query_id){
    var req = new XMLHttpRequest();
    req.open('GET', 'http://127.0.0.1:52273/doctor-result-diagnoses-list/'+study_id+'/'+query_id+'',false);
    req.send();

   return JSON.parse(req.responseText);


  }
  

function view(data_obj) {
  // generate some random data
  var countries = 'US,Germany,UK,Japan,Italy,Greece'.split(','),
    data = [];
  for (var i = 0; i < data_obj.length; i++) {
    data.push({
      id: data_obj[i].id,
      gender: data_obj[i].gender,
      age: data_obj[i].age,
      
    });
  }

  // create grid and show data
  var grid = new wijmo.grid.FlexGrid('#theGrid', {
    itemsSource: data
  });

  // // create a chart and show the same data    
  // var chart = new wijmo.chart.FlexChart('#theChart', {
  //   itemsSource: data,
  //   bindingX: 'country',
  //   series: [
  //     { name: 'Sales', binding: 'sales' },
  //     { name: 'Expenses', binding: 'expenses' },
  //     { name: 'Downloads', binding: 'downloads', chartType: wijmo.chart.ChartType.LineSymbols }]
  // });

}

async function pivot_refresh(){
  try{
    setTimeout(function(){
      view.refresh()
      pgRef.refresh()
      pcRef.refresh()
    },500);
   
  }catch(err){console.log(err)}
  

}

function pivot_lab_refresh(){
  try{
    setTimeout(function(){
      view_lab.refresh()
      pgRef_lab.refresh()
      pcRef_lab.refresh()
    },500);
  }catch(err){console.log({ERROR:err})}
  
}

function view_flex(data_obj){
  data = [];
  for (var i = 0; i < data_obj.length; i++) {
    data.push({
      total: data_obj[i].id,
      gender: data_obj[i].gender,
      age: data_obj[i].age,
    });
  }


  var view = new wijmo.collections.CollectionView(data);
  // initialize the FlexSheet
  var grid = new wijmo.grid.sheet.FlexSheet('#theSheet');
  var sheet = new wijmo.grid.sheet.Sheet();
  sheet.itemsSource = view;
  console.log(sheet.columnHeaders);
  grid.sheets.push(sheet);

}

function view_pivot(data_obj) {
  data = [];
  for (var i = 0; i < data_obj.length; i++) {
    data.push({
      total: data_obj[i].id.toString(),
      gender: data_obj[i].gender,
      age: data_obj[i].age
    });
  }

  
  var ngPanel = new wijmo.olap.PivotEngine({
    itemsSource: data, //row data
    valueFields : ['Total'],
    rowFields : ['Age'],
    columnFields:['Gender']
  
  });


  ngPanel.fields.getField('Total').aggregate = 'Cnt'

  view = new wijmo.olap.PivotPanel('#ppRef',{
    itemsSource : ngPanel
  })
  // view.rowFields.push('Year');
  // view.valueFields.push('Person_id');
  // view.columnFields.push('Gender');
  // view.
  pgRef = new wijmo.olap.PivotGrid('#pgRef',{
    itemsSource : view
  })

  pcRef = new wijmo.olap.PivotChart('#pcRef')
  pcRef.chartType = 'Area';
  pcRef.itemsSource = view;

  
  // var chartTypes = 'Column,Bar,Scatter,Line,Area,Pie'.split(',');
  // var ctcb = new wijmo.olap.('#ctcb');
  // ctcb.itemsSource = chartTypes;
  // ctcb.addEventListener('text-changed', function (e) {
  //     pcRef.chartType = ctcb.text;
  // });

  var cmbChartType = new wijmo.input.ComboBox('#ctcb', {
    textChanged: function(s, e) {
      pcRef.chartType = s.text;
    },
    itemsSource: 'Column,Bar,Line,Area,Pie'.split(',')
  });
  
}


function view_pivot_lab(data_obj) {
  data_lab = [];
  for (var i = 0; i < data_obj.length; i++) {
    data_lab.push({
      date        :   data_obj[i].measurement_date,
      id          :   data_obj[i].person_id,
      measurement :   data_obj[i].concept_name,
      value       :   data_obj[i].value_as_number,
      "Aspartate aminotransferase serum/plasma": data_obj[i].ast,
      "Alanine aminotransferase [Enzymatic activity/volume] in Serum, Plasma or Blood": data_obj[i].alt,
      "Hemoglobin A1c in Blood" :data_obj[i].hba1c,
      "Random blood glucose measurement": data_obj[i].glucose1,
      "Glucose [Mass/volume] in Serum, Plasma or Blood": data_obj[i].glucose2,
      "Fasting glucose [Mass/volume] in Capillary blood": data_obj[i].glucose3,
      "Glucose [Mass/volume] in Blood --2 hours post meal": data_obj[i].glucose4,
      "Glucose [Mass/volume] in Capillary blood": data_obj[i].glucose5
    });
  }
  console.log(data_lab);

  
  var ngPanel_lab = new wijmo.olap.PivotEngine({
    itemsSource: data_lab, //row data
    valueFields : ['Value'],
    rowFields : ['Date'],
    columnFields:['Measurement']
  
  });


   ngPanel_lab.fields.getField('Value').aggregate = 'Avg'

  view_lab = new wijmo.olap.PivotPanel('#ppRef_lab',{
    itemsSource : ngPanel_lab
  })
  // view.rowFields.push('Year');
  // view.valueFields.push('Person_id');
  // view.columnFields.push('Gender');
  // view.
  pgRef_lab = new wijmo.olap.PivotGrid('#pgRef_lab',{
    itemsSource : view_lab
  })

  pcRef_lab = new wijmo.olap.PivotChart('#pcRef_lab')
  pcRef_lab.chartType = 'Area';
  pcRef_lab.itemsSource = view_lab;

  
  // var chartTypes = 'Column,Bar,Scatter,Line,Area,Pie'.split(',');
  // var ctcb = new wijmo.olap.('#ctcb');
  // ctcb.itemsSource = chartTypes;
  // ctcb.addEventListener('text-changed', function (e) {
  //     pcRef.chartType = ctcb.text;
  // });

  var cmbChartType = new wijmo.input.ComboBox('#ctcb_lab', {
    textChanged: function(s, e) {
      pcRef_lab.chartType = s.text;
    },
    itemsSource: 'Column,Bar,Line,Area,Pie'.split(',')
  });
  
}
// var ng = ppRef.engine;
//     ng.itemsSource = rawData;
//     ng.rowFields.push('Product', 'Country');
//     ng.valueFields.push('Sales', 'Downloads');
//     ng.showRowTotals = wjOlap.ShowTotals.Subtotals;
//     ng.showColumnTotals = wjOlap.ShowTotals.Subtotals;
function text_cut_length(buf){
  if(buf.length>30){
    return  buf.substring(0,30)+'....';
  }else{
    return buf;
  }
}

function view_diagnoses_pivot(data_obj){
  data = [];
  for (var i = 0; i <20; i++) {
    data.push({
      name: text_cut_length(data_obj[i].name),
      cnt: data_obj[i].cnt
    });
  }
  console.log(data);
  var ngPanel = new wijmo.olap.PivotEngine({
    itemsSource: data, //row data
    valueFields : ['Cnt'],
    rowFields : ['Name'],
    
});
//ngPanel.fields.getField('Id').aggregate = 'Cnt'

  var view = new wijmo.olap.PivotPanel('#ppRef_diagnoses',{
    itemsSource : ngPanel
  })
  // view.rowFields.push('Year');
  // view.valueFields.push('Person_id');
  // view.columnFields.push('Gender');
  // view.
  var pgRef = new wijmo.olap.PivotGrid('#pgRef_diagnoses',{
    itemsSource : view
  })

  var pcRef = new wijmo.olap.PivotChart('#pcRef_diagnoses')
  pcRef.chartType = 'Bar';
  pcRef.itemsSource = view;

  
  // var chartTypes = 'Column,Bar,Scatter,Line,Area,Pie'.split(',');
  // var ctcb = new wijmo.olap.('#ctcb');
  // ctcb.itemsSource = chartTypes;
  // ctcb.addEventListener('text-changed', function (e) {
  //     pcRef.chartType = ctcb.text;
  // });

  var cmbChartType = new wijmo.input.ComboBox('#ctcb_diagnoses', {
    textChanged: function(s, e) {
      pcRef.chartType = s.text;
    },
    itemsSource: 'Bar,Column,,Line,Area,Pie'.split(',')
  });
  
  
}
