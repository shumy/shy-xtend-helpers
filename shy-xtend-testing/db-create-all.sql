create table address (
  id                            bigint auto_increment not null,
  city                          varchar(255) not null,
  country_id                    bigint,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint pk_address primary key (id)
);

create table country (
  id                            bigint auto_increment not null,
  code                          varchar(255) not null,
  name                          varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint pk_country primary key (id)
);

create table user (
  id                            bigint auto_increment not null,
  name                          varchar(255) not null,
  email                         varchar(255) not null,
  birthdate                     date not null,
  address_id                    bigint,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint pk_user primary key (id)
);

alter table address add constraint fk_address_country_id foreign key (country_id) references country (id) on delete restrict on update restrict;
create index ix_address_country_id on address (country_id);

alter table user add constraint fk_user_address_id foreign key (address_id) references address (id) on delete restrict on update restrict;
create index ix_user_address_id on user (address_id);

