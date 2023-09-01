{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__pinterest_ads_enabled','pinterest__using_keywords'])) }}

with base as (

    select * 
    from {{ ref('stg_pinterest_ads__keyword_report_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pinterest_ads__keyword_report_tmp')),
                staging_columns=get_keyword_report_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='pinterest_union_schemas', 
            union_database_variable='pinterest_union_databases') 
        }}

    from base
),

final as (

    select
        source_relation,
        {{ dbt.date_trunc('day', 'date') }} as date_day,
        keyword_id,
        pin_promotion_id,
        ad_group_id,
        ad_group_name,
        ad_group_status,
        campaign_id,
        advertiser_id,
        coalesce(impression_1,0) + coalesce(impression_2,0) as impressions,
        coalesce(clickthrough_1,0) + coalesce(clickthrough_2,0) as clicks,
        spend_in_micro_dollar / 1000000.0 as spend

        {{ fivetran_utils.fill_pass_through_columns('pinterest__keyword_report_passthrough_metrics') }}

    from fields
)

select *
from final
