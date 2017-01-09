alter table address drop constraint if exists fk_address_country_id;
drop index if exists ix_address_country_id;

alter table user drop constraint if exists fk_user_address_id;
drop index if exists ix_user_address_id;

drop table if exists address;

drop table if exists country;

drop table if exists user;

