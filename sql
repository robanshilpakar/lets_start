-- count diff verification as per client / search_hours for SEO
@set dataflow_name = 'Merkle_Industry_Travel_SEA_SEO'
@set search_hour= 19
@set previous_date= '2026-03-06'
@set present_date='2026-03-30'
@set serp_widget= 'Shopping'

select keyword, search_device, dataflow_id, dataflow_name, previous_dump,count_ads_present2,  present_dump, count_ads_present1,
--'https://daf.growbydata.com:8000/daf-classic/'||loc1||'/projects/'||scraper_id2||'/dumps/'||keyword_id1||'.html?file_expiry=90' as QA_previous,
'https://daf.growbydata.com:8000/daf-xtend/prod/projects/'||scraper_id2||'/screenshots/'||keyword_id1 as QA_previous
--'https://daf.growbydata.com:8000/daf-classic/'||loc2||'/projects/'||scraper_id1||'/dumps/'||keyword_id2||'.html?file_expiry=90' as QA_present
, 'https://daf.growbydata.com:8000/daf-xtend/prod/projects/'||scraper_id1||'/screenshots/'||keyword_id2 as QA_present
from (
with ccte as (
with cte as (
select * from
(select *,
split_part(k1, '.', 1) as keyword_id1, split_part(k2, '.', 1) as  keyword_id2
from 
(select run_id as run_id1, dataflow_id, dataflow_name, search_hour, raw_html_file as present_dump , keyword , search_region , search_device, 
split_part(raw_html_file, '/', 9) as k1, count(*) as count_ads_present1
FROM pla.fact_cai_seo
where dataflow_name = ${dataflow_name}  and search_date = ${present_date}
--and search_hour = ${search_hour}
--and search_device = 'Desktop'
and serp_widget = ${serp_widget}
--and tags like '%"AIO_Source": "PeopleAlsoAsk"%'
group by 1,2,3,4,5,6,7,8,9
--run_id  ='5c946553-90ff-43da-8d42-3bbbbe90dbab'
)
full outer join
(select distinct run_id as run_id2, dataflow_id, dataflow_name, search_hour, raw_html_file as previous_dump , keyword , search_region , search_device, 
split_part(raw_html_file, '/', 9) as k2,  count(*) as count_ads_present2 --5 keyword, 3 server
 FROM pla.fact_cai_seo
where dataflow_name = ${dataflow_name}  and search_date = ${previous_date}
--and search_device = 'Desktop'
--and search_hour = ${search_hour}
and serp_widget = ${serp_widget}
--and tags like '%"AIO_Source": "PeopleAlsoAsk"%'
group by 1,2,3,4,5,6,7,8,9
--run_id  ='5c946553-90ff-43da-8d42-3bbbbe90dbab'
)
using (search_region, search_hour, search_device, keyword,dataflow_id, dataflow_name)))
select * from cte 
left join
(select * from
(select distinct  search_region , dataflow_id, dataflow_name, search_hour, search_device, split_part(raw_html_file,'/',7) as scraper_id1 from pla.fact_cai_seo
where dataflow_name = ${dataflow_name}  and search_date = ${present_date}
and tags like '%"AIO_Source": "PeopleAlsoAsk"%'
--and search_device = 'Desktop'
--and search_hour = ${search_hour}
)
 )using (search_region, search_hour, search_device,dataflow_id, dataflow_name)
)
select * from ccte
left join
(select distinct search_region, dataflow_id, dataflow_name , search_hour, search_device, split_part(raw_html_file,'/',7) as scraper_id2 from pla.fact_cai_seo -- 4 scraper id
where dataflow_name = ${dataflow_name}  and search_date = ${previous_date}
and serp_widget = ${serp_widget}
--and search_device = 'Desktop'
--and search_hour = ${search_hour}
and tags like '%"AIO_Source": "PeopleAlsoAsk"%'
)

 using (search_region, search_hour, search_device,dataflow_id, dataflow_name)
) 
--where present_dump is not null 
--and previous_dump is null
--limit 10
