select * from
(
with cte as (
select distinct
ben.ms_pk
,scheme_name
,first_name
,surname
,gender	
,birth_date
,main_email	
,main_work_tel	
,id_num 
,ben.dep_fk 
,ben.comp_name
,mipst_dbo.tsf_ccm_template.template_label	
,mipst_dbo.tsf_ccm_template.template_description
,user_code
,replace(substring(call_start_datetime,1,10), '-','') as call_date 
,coalesce(g.comp_name,'none') as group_name	
,dep_type
,ben.comp_fk
,scheme_fk

FROM mipst_dbo.tsf_ccm_template
left join mipst_dbo.tsf_cct_call call ON call.template_obj = mipst_dbo.tsf_ccm_template.template_obj and call.status_key = 'cc_StCctcaComp' 
inner join mipst_dbo.tsd_cc_relationship real ON real.owning_obj::NUMERIC = call.call_obj
and UPPER(owning_entity_mnemonic) = 'CCTCA'
AND   UPPER(related_entity_mnemonic) in ('MEMBER','MEMDEP')
inner join  mipbi_dbo.td_beneficiary ben ON ben.ms_pk = coalesce(nullif(split_part(related_key, '|',1), ''), '0') --and scheme_fk='126'
and dep_fk::int	=coalesce(nullif(split_part(related_key, '|',2), ''), '0')::int
left join mipst_dbo.tsd_ben_memcom g  on  (case when ben.group_code='0' then ben.comp_fk else ben.group_code end)=g.comp_fk
) select cte.ms_pk
,scheme_name
,first_name
,surname
,gender	
,birth_date
,main_email	
,main_work_tel	
,id_num as identity_number 
,dep_fk as dependent_no
,dep_type
,cte.comp_name as companyname
, group_name
,cte.template_label	
,cte.template_description
,cte.user_code
, cte.call_date::varchar::date as call_date 
, array_to_string(array_agg(distinct (coalesce((c.Problem||'-'||c.sub_category),'') ||','||coalesce(l.Problem ,'')||','||coalesce(f.Problem ,''))),',') as Problem_name
from cte 
INNER JOIN
mipst_dbo.tsd_dates on mipst_dbo.tsd_dates.date_pk::VARCHAR =call_date
left join
mipst_dbo.legal_raw_2021 l on cte.ms_pk=l.ms_pk and cte.dep_fk=l.dependent_no::int and  cte.call_date::varchar::date =l.call_date and cte.template_label=l.template_label and cte.comp_name=l.comp_name 
				  and  cte.scheme_fk=l.scheme_fk and cte.user_code=l.user_code  left join
mipst_dbo.councelling_raw_2021 c on cte.ms_pk=c.ms_pk and cte.dep_fk=c.dependent_no::int and  cte.call_date::varchar::date =c.call_date and cte.template_label=c.template_label and cte.comp_name=c.comp_name 			 
and  cte.scheme_fk=c.scheme_fk and cte.user_code=c.user_code  left join
mipst_dbo.financial_raw_2021 f on cte.ms_pk=f.ms_pk and cte.dep_fk=f.dependent_no::int and  cte.call_date::varchar::date =f.call_date and cte.template_label=f.template_label and cte.comp_name=f.comp_name 			 
and  cte.scheme_fk=f.scheme_fk and cte.user_code=f.user_code  
group by cte.ms_pk
,scheme_name
,first_name
,surname
,gender	
,birth_date
,main_email	
,main_work_tel	
,id_num  
,dep_fk
,dep_type				  
,cte.comp_name 
, group_name
,cte.template_label	
,cte.template_description
,cte.user_code
, cte.call_date::varchar::date 
) a