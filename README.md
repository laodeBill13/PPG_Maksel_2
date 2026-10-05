# PPG_Maksel_2


# admin 
update public.profiles
set role = 'admin', status = 'approved'
where id = (select id from auth.users where email = 'EMAIL_ADMIN_LU');
