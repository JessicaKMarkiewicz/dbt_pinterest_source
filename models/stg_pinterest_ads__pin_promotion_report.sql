with base as (

    select *
    from {{ var('pin_promotion_report') }}

), fields as (

    select 
        date as date_day,
        pin_promotion_id,
        ad_group_id,
        campaign_id,
        advertiser_id,
        _fivetran_synced,
        coalesce(impression_1,0) + coalesce(impression_2,0) as impressions,
        coalesce(clickthrough_1,0) + coalesce(clickthrough_2,0) as clicks,
        spend_in_micro_dollar / 1000000.0 as spend
        {% if var('pin_promotion_report_pass_through_metric') %}
        ,
        {{ var('pin_promotion_report_pass_through_metric') | join (", ")}}

        {% endif %}

    from base

), surrogate_key as (

    select
        *,
        {{ dbt_utils.surrogate_key(['date_day','pin_promotion_id']) }} as report_id
    from fields

)

select *
from surrogate_key  