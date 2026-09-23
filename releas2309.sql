select distinct pp_policynumber,jb_st_name,pps_st_name,jb_notificationdelaydays_dlg
from ext_curation_policy_center_9.gw_pc9_policy_periods
where jb_notificationdelaydays_dlg is not null
and pps_st_name in ('Bound','Quoted') and pp_policynumber in (8006093309,8006095056);

pp_policynumber | jb_st_name | pps_st_name | jb_notificationdelaydays_dlg
----------------+------------+-------------+-----------------------------
8006093309      | Renewal    | Bound       |                            0
8006093309      | Renewal    | Quoted      |                            0
8006095056      | Renewal    | Bound       |                            4
8006095056      | Renewal    | Quoted      |                            4


select distinct pp_policynumber,jb_st_name,pps_st_name,jb_notificationdelaydays_dlg
from tmp_dap_dw_stg.staging_pc9_policy_periods
where jb_notificationdelaydays_dlg is not null
and pps_st_name in ('Bound','Quoted') and pp_policynumber in (8006093309,8006095056);

pp_policynumber | jb_st_name | pps_st_name | jb_notificationdelaydays_dlg
----------------+------------+-------------+-----------------------------
8006093309      | Renewal    | Bound       |                            0
8006093309      | Renewal    | Quoted      |                            0
8006095056      | Renewal    | Quoted      |                            4
8006095056      | Renewal    | Bound       |                            4


select distinct policy_number,
renewal_notification_delays_days,pps_st_name,persist_id,jb_st_name
from tmp_dap_dw_stg.v_policy_period
 where policy_number in (8006093309,8006095056);

policy_number | renewal_notification_delays_days | pps_st_name | persist_id     | jb_st_name   
--------------+----------------------------------+-------------+----------------+--------------
8006093309    |                                0 | Bound       | PRV30017397359 | Renewal      
8006093309    |                                  | Bound       | PRV30017397359 | New Business 
8006095056    |                                  | Bound       | DLI10017398199 | New Business 
8006095056    |                                4 | Bound       | DLI10017398199 | Renewal      
8006095056    |                                  | Quoted      | DLI10017398199 | Policy Change
8006095056    |                                  | Bound       | DLI10017398199 | Policy Change

select distinct policy_number,esb_rating_id,notification_delay_days
from tmp_dap_dw_stg.v_quote_fact_ir
 where policy_number in (8006093309,8006095056);
 
policy_number | esb_rating_id                        | notification_delay_days
--------------+--------------------------------------+------------------------
8006093309    | e545f23d-2378-44f8-be06-55558407a2d4 |                       0
8006095056    | ad4f41f6-e6b8-4807-b7fb-bd5fc45a00d7 |                        
8006095056    | 2f7766f3-ccc9-49eb-826e-820ca4fc83d2 |                        
8006095056    | edb071f9-6059-4e11-94a7-cf96fefffdbf |                       4
8006095056    | cf47a1a5-b5fb-4baa-8e39-558c382b1b4e |                        
8006095056    | 86053a25-4dc9-4738-9504-94c7ff189ba8 |                        
8006095056    | c0ec7c5a-a2c2-4577-b94e-cd2c9f5bdfa5 |                        
8006095056    | 856c780b-241f-40e3-bd95-6788b499fd02 |                        

select policy_number,persist_quote_reference,notification_delay_days
from tmp_dap_dw_stg.v_quoted_risk_rating
where policy_number in (8006093309,8006095056);

policy_number | persist_quote_reference | notification_delay_days
--------------+-------------------------+------------------------
8006093309    | PRV30017397359          |                       0
8006095056    | DLI10017398199          |                        
8006095056    | DLI10017398199          |                        
8006095056    | DLI10017398199          |                        
8006095056    | DLI10017398199          |                        
8006095056    | DLI10017398199          |                        
8006095056    | DLI10017398199          |                        
8006095056    | DLI10017398199          |                       4

select policy_number,quote_persist_reference,notification_delay_days
from tmp_dap_dw_core.fact_quoted_risk 
where policy_number in (8006093309,8006095056);

policy_number | quote_persist_reference | notification_delay_days
--------------+-------------------------+------------------------
   8006093309 | PRV30017397359          |                       0
   8006093309 | PRV30017397359          |                        
   8006095056 | DLI10017398199          |                        
   8006095056 | DLI10017398199          |                        
   8006095056 | DLI10017398199          |                       4

