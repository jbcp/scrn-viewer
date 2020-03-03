function getData(){
  return [
    {title :  'Demographic', value:'1', items:[
      {title : '$ gender_source_value', value:'gender'},
      {title : '$ day_of_birth', value:'age'},
      {title : '$ month_of_birth', value:'age'},
      {title : '$ year_of_birth', value:'age'},
      {title : '$ person_id', value:'id'}     
    ]},
    {title : 'Condition', value:'2', items:[
      {title : '$ person_id', value:'id'},
      {title : '$ condition_concept_name', value:'c_name'},
      {title : '$ condition_start_date', value:'start'},
      {title : '$ condition_type_concept_id', value:'c_type_id'}
    ]},
    {title : 'Drug', value:'3', items:[
      {title : '$ person_id', value:'id'},
      {title : '$ drug_concept_name', value:'d_name'},
      {title : '$ drug_exposure_start_date', value:'start'},
      {title : '$ drug_exposure_end_date', value:'end'}
    ]},
    {title : 'Procedure', value:'4', items:[
      {title : '$ person_id', value:'id'},
      {title : '$ procedure_concept_name', value:'m_name'},
      {title : '$ procedure_date', value:'start'}
    ]},
    {title : 'Measurement', value:'5', items:[
      {title : '$ person_id', value:'id'},
      {title : '$ measurement_concept_name', value:'m_name'},
      {title : '$ range_high', value:'range_high'},
      {title : '$ range_low', value:'range_low'},
      {title : '$ value_as_number', value:'value'}
    ]}
  ];
}