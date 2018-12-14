DROP PROCEDURE if exists deluser;
DELIMITER //
CREATE PROCEDURE deluser(IN user_mp BIGINT)
begin
DECLARE uid int;
DECLARE aid int;
select userid into uid from navi_db.navi_mp_map where mp = user_mp;
delete from navi_db.navi_uid_map where userid = uid;
delete from navi_db.navi_mp_map where userid = uid;
delete from navi_db.navi_mail_map where userid = uid;
delete from navi_db.navi_uri_map where userid = uid;
delete from ubiz_db.ubiz_weathers where userid = uid;
delete from ubiz_db.ubiz_reminders_users where rmnduid = uid;
delete from ubiz_db.ubiz_capability_map where userid = uid;
delete from cinf_db.cinf_employees where userid = uid;
select adminid into aid from imop_db.imop_admin where adminuid = uid;
if (aid is not null) then
         delete from imop_db.imop_admin where adminuid = uid;
         delete from imop_db.imop_admin_permission where adminid = aid;
         delete from imop_db.imop_admin_dept where adminid = aid;
end if;
end 
//
DELIMITER ;
