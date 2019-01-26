create table locations
(
  gps     varchar(40) not null
    constraint locations_pkey
    primary key,
  city    varchar(20),
  country varchar(20),
  zip     varchar(6),
  street  varchar(20)
);

alter table locations
  owner to postgres;

create table cars
(
  car_id       integer     not null
    constraint cars_pkey
    primary key,
  model        varchar(20) not null,
  price        integer     not null,
  charge       integer     not null,
  condition    varchar(20) not null,
  location_cur varchar(40) not null
    constraint cars_location_cur_fkey
    references locations,
  plate_number varchar(10) not null,
  color        varchar(20) not null
);

alter table cars
  owner to postgres;

create unique index cars_car_id_uindex
  on cars (car_id);

create unique index cars_plate_number_uindex
  on cars (plate_number);

create table charging_stations
(
  station_id integer     not null
    constraint charging_stations_pkey
    primary key,
  price      integer     not null,
  location   varchar(40) not null
    constraint charging_stations_location_fkey
    references locations
);

alter table charging_stations
  owner to postgres;

create unique index charging_stations_station_id_uindex
  on charging_stations (station_id);

create table customers
(
  customer_id integer     not null
    constraint customers_pkey
    primary key,
  email       varchar(60) not null,
  phone       varchar(20) not null,
  name        varchar(60) not null,
  username    varchar(60) not null,
  location    varchar(40) not null
    constraint customers_location_fkey
    references locations
);

alter table customers
  owner to postgres;

create unique index customers_customer_id_uindex
  on customers (customer_id);

create unique index customers_email_uindex
  on customers (email);

create unique index customers_username_uindex
  on customers (username);

create unique index customers_phone_uindex
  on customers (phone);

create table parts
(
  part_id   integer     not null
    constraint parts_pkey
    primary key,
  name      varchar(20) not null,
  price     integer     not null,
  car_model varchar(20) not null
);

alter table parts
  owner to postgres;

create unique index parts_part_id_uindex
  on parts (part_id);

create table plugs
(
  type  varchar(20) not null
    constraint plugs_pkey
    primary key,
  size  integer     not null,
  shape integer     not null
);

alter table plugs
  owner to postgres;

create unique index plugs_type_uindex
  on plugs (type);

create table plug_amounts
(
  station_id integer     not null
    constraint plug_amounts_charging_stations_station_id_fk
    references charging_stations,
  plug_type  varchar(20) not null
    constraint plug_amounts_plugs_type_fk
    references plugs,
  amount     integer     not null,
  constraint plug_amounts_pk
  primary key (station_id, plug_type)
);

alter table plug_amounts
  owner to postgres;

create table providers
(
  provider_id integer     not null
    constraint providers_pkey
    primary key,
  name        varchar(60) not null,
  phone       varchar(11) not null,
  location    varchar(40) not null
    constraint providers_location_fkey
    references locations
);

alter table providers
  owner to postgres;

create unique index providers_provider_id_uindex
  on providers (provider_id);

create table parts_providers
(
  provider_id integer not null
    constraint parts_providers_providers_provider_id_fk
    references providers,
  part_id     integer not null
    constraint parts_providers_parts_part_id_fk
    references parts,
  constraint parts_providers_pk
  primary key (provider_id, part_id)
);

alter table parts_providers
  owner to postgres;

create table transactions
(
  transaction_id integer     not null
    constraint transactions_pkey
    primary key,
  amount         integer     not null,
  date           timestamp   not null,
  type           varchar(20) not null,
  customer_id    integer     not null
    constraint transactions_customers_customer_id_fk
    references customers
);

alter table transactions
  owner to postgres;

create unique index transaction_transaction_id_uindex
  on transactions (transaction_id);

create table orders
(
  car_id               integer     not null
    constraint car_usage_cars_car_id_fk
    references cars,
  transaction_id       integer     not null
    constraint order_pk
    primary key
    constraint car_usage_transactions_transaction_id_fk
    references transactions,
  date_from            timestamp   not null,
  date_to              timestamp   not null,
  location_destination varchar(40) not null
    constraint order_locations_gps_fk
    references locations,
  location_pickup      varchar(40) not null
    constraint order_locations_gps_fk_2
    references locations
);

alter table orders
  owner to postgres;

create table charging_stations_usage
(
  car_id         integer     not null
    constraint charging_stations_usage_cars_car_id_fk
    references cars,
  station_id     integer     not null
    constraint charging_stations_usage_charging_stations_station_id_fk
    references charging_stations,
  plug_type      varchar(20) not null
    constraint charging_stations_usage_plugs_type_fk
    references plugs,
  date_from      timestamp   not null,
  date_to        timestamp   not null,
  amount         integer     not null,
  transaction_id integer     not null
    constraint charging_stations_usage_pk
    primary key
    constraint charging_stations_usage_transactions_transaction_id_fk
    references transactions
);

alter table charging_stations_usage
  owner to postgres;

create table workshops
(
  workshop_id integer     not null
    constraint workshops_pkey
    primary key,
  location    varchar(40) not null
    constraint workshops_location_fkey
    references locations
);

alter table workshops
  owner to postgres;

create unique index workshops_workshop_id_uindex
  on workshops (workshop_id);

create table parts_requests
(
  part_id         integer   not null
    constraint parts_requests_parts_part_id_fk
    references parts,
  workshop_id     integer   not null
    constraint parts_requests_workshops_workshop_id_fk
    references workshops,
  provider_id     integer   not null
    constraint parts_requests_providers_provider_id_fk
    references providers,
  date_of_arrival timestamp not null,
  amount          integer   not null,
  request_id      integer   not null
    constraint parts_requests_pk
    primary key
);

alter table parts_requests
  owner to postgres;

create table workshop_calendar
(
  workshop_id    integer   not null
    constraint workshop_calendar_workshops_workshop_id_fk
    references workshops,
  date_from      timestamp not null,
  date_to        timestamp not null,
  car_id         integer   not null
    constraint workshop_calendar_cars_car_id_fk
    references cars,
  transaction_id integer   not null
    constraint workshop_calendar_pk
    primary key
    constraint workshop_calendar_transactions_transaction_id_fk
    references transactions
);

alter table workshop_calendar
  owner to postgres;

create table workshop_parts_availability
(
  workshop_id integer not null
    constraint workshop_parts_availability_workshops_workshop_id_fk
    references workshops,
  part_id     integer not null
    constraint workshop_parts_availability_parts_part_id_fk
    references parts,
  amount      integer not null,
  constraint workshop_parts_availability_pk
  primary key (workshop_id, part_id)
);

alter table workshop_parts_availability
  owner to postgres;


