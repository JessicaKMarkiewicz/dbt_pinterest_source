{{ config(enabled=var('ad_reporting__pinterest_ads_enabled', True)) }}

select * 
from {{ var('keyword_report') }}
