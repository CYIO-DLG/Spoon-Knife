/*UPDATE STATEMENTS for Sample Policy Numbers*/
update tmp_dap_dw_stg.staging_pc9_policy_periods
set jb_notificationdelaydays_dlg=5
where pp_policynumber in (8006030285);

update tmp_dap_dw_stg.staging_pc9_policy_periods
set jb_notificationdelaydays_dlg=10
where pp_policynumber in (8005932457);

update tmp_dap_dw_stg.staging_pc9_policy_periods
set jb_notificationdelaydays_dlg=0
where pp_policynumber in (8005875599);

/*staging_pc9_policy_periods - post update*/
select  distinct pp_id, pp_policynumber,jb_notificationdelaydays_dlg,dap_processed_timestamp
            from tmp_dap_dw_stg.staging_pc9_policy_periods
          where pp_policynumber in  (8006030285,8005932457,8005875599,8005647758);
          
/*v_policy_period - post update
Note that 'Renewal' policies have the changes updated*/
select pp_id,policy_number,
renewal_notification_delays_days,pps_st_name,persist_id,jb_st_name
from tmp_dap_dw_stg.v_policy_period
 where policy_number in (8006030285,8005932457,8005875599,8005647758)
 
/*v_quote_fact_ir - post update*/
select policy_number,notification_delay_days
from tmp_dap_dw_stg.v_quote_fact_ir
 where policy_number in (8006030285,8005932457,8005875599,8005647758)
 /*v_quote_fact_ir - created from v_quote_fact_ir*/
select policy_number,persist_quote_reference,notification_delay_days
from tmp_dap_dw_stg.v_quoted_risk_rating
where policy_number in (8006030285,8005932457,8005875599,8005647758)

/*fact_quoted_risk - final fact table*/
select policy_number,quote_persist_reference,notification_delay_days
from tmp_dap_dw_core.fact_quoted_risk 
where policy_number in (8006030285,8005932457,8005875599,8005647758)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*v_quote_fact_ir - table creation from v_policy_period 
TYPICALLY from v_policy_periods_esb_rating which is created from 
v_policy_periods_esb_rating - Bound, renewal and quoted,renewal data picked (screenshot attached) */
select distinct rnk,esb_rating_id,persist_quote_reference,policy_number,notification_delay_days from 
(SELECT DISTINCT rnk,
       esb_rating_id,
       brand,
       product,
       original_channel,
       original_sub_channel,
       irq_esb_polnbind,
       trans_channel,
       trans_sub_channel,
       transaction_date,
       contract_created_date,
       transaction_type,
       persist_quote_reference,
       correlation_id,
       initial_quote,
       term_id,
       policy_accepted_date,
       transaction_effective_from,
       seq_start_date,
       contract_end_date,
       policy_number,
       auto_renewal_intent_flag,
       live_autorenewal_flag,
       autorenewal_status_timestamp,
       declined_flag,
       accepted_type,
       renewal_type,
       MAX(policy_number_q_p) OVER (PARTITION BY esb_rating_id) policy_number_q_p,
       rescue_term_id,
       notification_delay_days
FROM (SELECT irq.rnk,
             irq.esb_rating_id,
             irq.brand,
             irq.product,
             irq.original_channel,
             irq.original_sub_channel,
             irq.irq_esb_polnbind,
             irq.trans_channel,
             irq.trans_sub_channel,
             irq.transaction_date,
             nvl(pp.quote_created_date,irq.contract_created_date) AS contract_created_date,
             irq.transaction_type,
             irq.persist_quote_reference,
             irq.correlation_id,
             irq.initial_quote,
             irq.term_id,
             irq.policy_accepted_date,
             irq.transaction_effective_from,
             irq.seq_start_date,
             irq.contract_end_date,
             irq.policy_number,
             irq.auto_renewal_intent_flag,
             irq.live_autorenewal_flag,
             irq.autorenewal_status_timestamp,
             ordf.declined_flag,
             pp.accepted_type_acc_lvl AS accepted_type,
             pp.renewal_type_acc_lvl AS renewal_type,
             pp.notification_delay_days,
             CAST(COALESCE(irq.policy_number,pp.policy_number) AS BIGINT) AS policy_number_q_p,
             irq.rescue_tenure +1 AS rescue_term_id
      FROM (SELECT ROW_NUMBER() OVER (PARTITION BY a.irq_esb_ratingid ORDER BY irq_shredding_timestamp DESC,dap_processed_timestamp DESC) rnk,
                   a.irq_esb_ratingid esb_rating_id,
                   decode (irq_pcr_polbrand ,
                         'DLI','Direct Line',
                         'CHU','Churchill',
                         'PRV','Privilege',
                         'Unknown'
                   ) brand,
                   irq_pcr_productcode product,
                   decode( irq_pcr_polnborigchannel ,
                         NULL,'Unknown',
                         irq_pcr_polnborigchannel
                   ) original_channel,
                   decode( irq_pcr_polnborigsubchannel ,
                         NULL,'Unknown',
                         irq_pcr_polnborigsubchannel
                   ) original_sub_channel,
                   irq_esb_polnbind,
                   decode( irq_pcr_transplatform,
                         NULL,'Unknown',
                         irq_pcr_transplatform
                   ) trans_channel,
                   decode( irq_pcr_transplatform,
                         NULL,'Unknown',
                         irq_pcr_transplatform
                   ) trans_sub_channel,
                   irq_pcr_transactiondate transaction_date,
                   irq_pcr_polquotedate contract_created_date,
                   ' get_quote' transaction_type,
                   a.irq_esb_persistid persist_quote_reference,
                   irq_correlationid correlation_id,
                   irq_esb_initialquote initial_quote,
                   irq_pcr_polmotortenure term_id,
                   irq_pcr_polacceptdate policy_accepted_date,
                   irq_pcr_polstartdate transaction_effective_from,
                   irq_pcr_seqstartdate seq_start_date,
                   irq_pcr_polexpirydate contract_end_date,
                   CASE
                     WHEN NOT regexp_instr (a.irq_pcr_policynumber,'[[:digit:]]') THEN NULL
                     ELSE a.irq_pcr_policynumber
                   END AS policy_number,
                   irq_pcr_polautorenewalatinvite auto_renewal_intent_flag,
                   c.live_autorenewal_flag,
                   c.autorenewal_status_timestamp,
                   irq_pcr_polrsqtenure rescue_tenure
            FROM tmp_dap_dw_stg.staging_in_radar_quote a,
                 tmp_dap_dw_stg.v_quote_delta_lookup b,
                 tmp_dap_dw_stg.quote_policy_renewal_lookup c
            WHERE dap_deleted = 0
            AND   a.irq_esb_persistid = b.irq_esb_persistid
            AND   a.irq_esb_ratingid = c.irq_esb_ratingid (+)) irq,
           (SELECT ormq_esb_ratingid esb_rating_id,
                   declined_flag
            FROM (SELECT ormq_esb_ratingid,
                         MIN(ormq_rdr_uwdecline) declined_flag
                  FROM tmp_dap_dw_stg.staging_out_radar_motor_quote
                  GROUP BY ormq_esb_ratingid)
            WHERE declined_flag = 1) ordf,
           (SELECT * FROM tmp_dap_dw_stg.v_policy_periods_esb_rating) pp
      WHERE rnk = 1
      AND   irq.esb_rating_id = ordf.esb_rating_id (+)
      AND   irq.persist_quote_reference = pp.persist_id (+)
      AND   irq.esb_rating_id = pp.esb_rating_id (+))
      where policy_number in (8006030285,8005932457,8005875599,8005647758))


