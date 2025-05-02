-- SQLBook: Code
-- Projekt IDS
-- Skript pro vytvorenie databazy Hotelu
-- Zadani: 28 - Hotel
-- Autori: xfiloja00, xbockaa00

drop table assigned_to cascade constraints;
drop table includes cascade constraints;
drop table managed_by cascade constraints;
drop table price_in_date cascade constraints;
drop table room_type cascade constraints;
drop table payment cascade constraints;
drop table equipment cascade constraints;
drop table room cascade constraints;
drop table reservation cascade constraints;
drop table services cascade constraints;
drop table positiontype cascade constraints;
drop table person cascade constraints;

alter session set nls_date_format = 'DD/MM/YYYY';


create table person (
   id_person     int
      generated always as identity
   primary key,
   id_postype    int,
   firstname     varchar(12) not null,
   lastname      varchar(12) not null,
   mail          varchar(30) not null,
   birthnumber   char(11),
   salary        decimal,
   bankaccount   varchar(30),
   addresstown   varchar(50) not null,
   addressstreet varchar(50) not null,
   addressnum    int not null,
   persontype    varchar(20) not null,
   telephone     varchar(20) not null
);

create table positiontype (
   id_postype       int
      generated always as identity
   primary key,
   responsibilities varchar(40),
   postype          varchar(25) not null
);

create table services (
   id_serv             int
      generated always as identity
   primary key,
   servicesname        varchar(50) not null,
   servicesdescription varchar(100),
   price               decimal(8,2) not null
);

create table reservation (
   id_reser          int
      generated always as identity
   primary key,
   id_room           int not null,
   id_person         int not null,
   id_personemploy   int not null,
   datefrom          date not null,
   dateto            date not null,
   numberofresidents int not null,
   reservationstatus varchar(20) not null,
   price             decimal(8,2) not null
);

create table room (
   id_room      int
      generated always as identity
   primary key,
   id_room_type int not null,
   roomnumber   varchar(10) not null,
   guestcount   int not null,
   roomstatus   varchar(30) not null
);

create table room_type (
   id_room_type int
      generated always as identity
   primary key,
   roomtypetype varchar(30) not null
);

create table price_in_date (
   id_price      int
      generated always as identity
   primary key,
   id_room_type  int not null,
   datefrom      date not null,
   dateto        date not null,
   priceconstant decimal(8,2) not null
);

create table managed_by (
   id_managed           int
      generated always as identity
   primary key,
   id_person            int not null,
   id_room              int not null,
   managedbyname        char(20) not null,
   managedbydescription char(35),
   timeaccessed         timestamp default systimestamp not null
);

create table equipment (
   id_equip              int
      generated always as identity
   primary key,
   equipmentname         varchar(20) not null,
   equipment_description varchar(30)
);

create table payment (
   id_pay        int
      generated always as identity
   primary key,
   id_reser      int not null,
   totalprice    decimal(8,2) not null,
   paymentmethod varchar(25) not null,
   paymentdate   date not null
);

create table includes (
   id_include int
      generated always as identity
   primary key,
   id_room    int not null,
   id_equip   int not null
);

create table assigned_to (
   id_assign int
      generated always as identity
   primary key,
   id_serv   int not null,
   id_reser  int not null
);


-- Foreign Key Constraints
alter table person add constraint fk_person_pos_type foreign key ( id_postype )
   references positiontype;
alter table reservation add constraint fk_reser_per foreign key ( id_person )
   references person;
alter table reservation add constraint fk_reser_employ foreign key ( id_personemploy )
   references person;
alter table reservation add constraint fk_reser_room foreign key ( id_room )
   references room;
alter table room add constraint fk_room_type foreign key ( id_room_type )
   references room_type;
alter table payment add constraint fk_pay_reser foreign key ( id_reser )
   references reservation;
alter table price_in_date add constraint fk_price_in_date_room foreign key ( id_room_type )
   references room_type;
alter table managed_by
   add constraint fk_manage_per foreign key ( id_person )
      references person
         on delete cascade;
alter table managed_by
   add constraint fk_manage_room foreign key ( id_room )
      references room
         on delete cascade;
alter table includes
   add constraint fk_includes_room foreign key ( id_room )
      references room
         on delete cascade;
alter table includes
   add constraint fk_includes_equip foreign key ( id_equip )
      references equipment
         on delete cascade;
alter table assigned_to
   add constraint fk_assign_serv foreign key ( id_serv )
      references services
         on delete cascade;
alter table assigned_to add constraint fk_assign_reser foreign key ( id_reser )
   references reservation;


-- Data Constraints (Check Constraints)

-- Person
alter table person
   add constraint ck_person_telephone_format check ( regexp_like ( telephone,
                                                                   '^\+?[0-9]{12}$' ) );
alter table person
   add constraint ck_person_mail_format check ( regexp_like ( mail,
                                                              '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' ) );
alter table person add constraint ck_person_salary check ( salary >= 0 );
alter table person
   add constraint ck_person_type
      check ( persontype in ( 'employee',
                              'customer',
                              'administrator' ) );
alter table person
   add constraint ck_person_bankaccount_format check ( regexp_like ( bankaccount,
                                                                     '^CZ[0-9]{2}[0-9]{20}$' ) );
alter table person
   add constraint ck_person_customer_no_position
      check ( persontype <> 'customer'
          or id_postype is null );

-- Service
alter table services add constraint ck_service_price check ( price >= 0 );

-- Reservation
alter table reservation add constraint ck_reservation_date check ( datefrom <= dateto );
alter table reservation add constraint ck_reservation_numofresidents check ( numberofresidents >= 0 );
alter table reservation
   add constraint ck_reservation_status
      check ( reservationstatus in ( 'Confirmed',
                                     'Pending',
                                     'Refunded',
                                     'Cancelled',
                                     'Completed' ) );

-- Room
alter table room add constraint ck_room_guest check ( guestcount > 0 );
alter table room
   add constraint ck_room_status
      check ( roomstatus in ( 'Available',
                              'Occupied',
                              'Cleaning',
                              'Maintenance',
                              'Unavailable' ) );

-- Room Types
alter table room_type
   add constraint ck_room_type_types
      check ( roomtypetype in ( 'economy',
                                'standart',
                                'deluxe',
                                'Suite',
                                'executive suite',
                                'presidential suite' ) );

-- Payment
alter table payment add constraint ck_payment_totalprice check ( totalprice >= 0 );

-- PriceInDate
alter table price_in_date add constraint ck_price_in_date_date check ( datefrom <= dateto );
alter table price_in_date add constraint ck_price_in_date_priceconstant check ( priceconstant > 0 );

-- Managed By
alter table managed_by modify (
   timeaccessed default systimestamp
);

-- INSERTS ----------------------------------------------------------------------------------------------

-- PositionType
insert into positiontype (
   responsibilities,
   postype
) values ( 'Manages reservations',
           'Receptionist' );
insert into positiontype (
   responsibilities,
   postype
) values ( 'Cleans rooms',
           'Housekeeper' );
insert into positiontype (
   responsibilities,
   postype
) values ( 'Oversees operations',
           'Manager' );
insert into positiontype (
   responsibilities,
   postype
) values ( 'Performs repairs and maintenance',
           'Maintenance' );
insert into positiontype (
   responsibilities,
   postype
) values ( 'Ensures safety and security',
           'Security' );


-- Person
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 1,
           'John',
           'Doe',
           'john.doe@email.com',
           '800101/1234',
           2500.00,
           'CZ1208000000001234567890',
           'Prague',
           'Main St',
           5,
           'employee',
           '+420777123456' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 2,
           'Jane',
           'Smith',
           'jane.smith@email.com',
           '850505/5678',
           2000.00,
           'CZ2308000000001234567890',
           'Brno',
           'Side St',
           12,
           'employee',
           '+420777654321' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 3,
           'Alice',
           'Johnson',
           'alice.j@email.com',
           '901010/9012',
           3000.00,
           'CZ3408000000001234567890',
           'Ostrava',
           'Park Ave',
           20,
           'employee',
           '+420777112233' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Robert',
           'Williams',
           'robert.w@email.com',
           '750303/3456',
           null,
           null,
           'Plzen',
           'Oak Ln',
           8,
           'customer',
           '+420777445566' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Emily',
           'Brown',
           'emily.b@email.com',
           '880808/8765',
           null,
           null,
           'Liberec',
           'Pine Rd',
           15,
           'customer',
           '+420777998877' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Skrecok',
           'Hravi',
           'skrecok.h@email.com',
           '880809/8765',
           null,
           null,
           'Pri krbe',
           'klieta',
           15,
           'customer',
           '+421777998888' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 4,
           'Peter',
           'Novak',
           'peter.novak@email.com',
           '820202/4321',
           2200.00,
           'CZ5608000000001234567890',
           'Kosice',
           'Industry Rd',
           10,
           'employee',
           '+421905111222' );
-- PositionType (1) - Receptionist
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 1,
           'Eva',
           'Kovacova',
           'eva.kovacova@email.com',
           '911111/1111',
           2600.00,
           'CZ6708000000001234567890',
           'Zilina',
           'High St',
           30,
           'employee',
           '+421905333444' );
-- PositionType (2) - Housekeeper
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 2,
           'Martin',
           'Svoboda',
           'martin.s@email.com',
           '890707/7777',
           2100.00,
           'CZ7808000000001234567890',
           'Banska Bystrica',
           'Low Rd',
           25,
           'employee',
           '+421905555666' );
-- PositionType (3) - Manager
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 3,
           'Maria',
           'Horvathova',
           'maria.h@email.com',
           '781212/2222',
           3500.00,
           'CZ8908000000001234567890',
           'Nitra',
           'Central Sq',
           1,
           'employee',
           '+421905777888' );
-- PositionType (5) - Security
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( 5,
           'Juraj',
           'Mrkvicka',
           'juraj.m@email.com',
           '850909/9999',
           2300.00,
           'CZ9008000000001234567890',
           'Trencin',
           'Guard St',
           50,
           'employee',
           '+421905999000' );
-- Zákazníci (id_posType je NULL)
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Anna',
           'Mala',
           'anna.m@email.com',
           '950404/4444',
           null,
           null,
           'Poprad',
           'Mountain Rd',
           7,
           'customer',
           '+421918111222' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Jan',
           'Velky',
           'jan.v@email.com',
           '920606/6666',
           null,
           null,
           'Trnava',
           'Field St',
           11,
           'customer',
           '+421918333444' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Zuzana',
           'Dlha',
           'zuzana.d@email.com',
           '870101/1111',
           null,
           null,
           'Presov',
           'River Side',
           22,
           'customer',
           '+421918555666' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Tomas',
           'Kratky',
           'tomas.k@email.com',
           '980303/3333',
           null,
           null,
           'Martin',
           'Forest Ln',
           3,
           'customer',
           '+421918777888' );
insert into person (
   id_postype,
   firstname,
   lastname,
   mail,
   birthnumber,
   salary,
   bankaccount,
   addresstown,
   addressstreet,
   addressnum,
   persontype,
   telephone
) values ( null,
           'Viera',
           'Stredna',
           'viera.s@email.com',
           '990505/5555',
           null,
           null,
           'Povazska Bystrica',
           'City Center',
           9,
           'customer',
           '+421918999000' );

-- Services
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Room Service',
           'Food and drinks to your room',
           20.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Laundry',
           'Cleaning of clothes',
           15.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Gym Access',
           'Use of fitness facilities',
           10.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Spa Treatment',
           'Relaxing treatments',
           50.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Breakfast Buffet',
           'All-you-can-eat breakfast',
           12.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Airport Transfer',
           'Shuttle service to/from airport',
           30.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Extra Bed',
           'Additional bed in the room',
           25.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Pet Fee',
           'Fee for bringing a pet',
           20.00 );
insert into services (
   servicesname,
   servicesdescription,
   price
) values ( 'Late Checkout',
           'Extended checkout time',
           40.00 );

-- Room type
insert into room_type ( roomtypetype ) values ( 'economy' );
insert into room_type ( roomtypetype ) values ( 'standart' );
insert into room_type ( roomtypetype ) values ( 'deluxe' );
insert into room_type ( roomtypetype ) values ( 'Suite' );
insert into room_type ( roomtypetype ) values ( 'executive suite' );
insert into room_type ( roomtypetype ) values ( 'presidential suite' );

-- Room
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '101',
           1,
           2,
           'Available' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '102',
           1,
           1,
           'Occupied' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '103',
           2,
           5,
           'Unavailable' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '104',
           2,
           4,
           'Occupied' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '201',
           3,
           3,
           'Cleaning' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '202',
           3,
           2,
           'Available' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '203',
           3,
           6,
           'Maintenance' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '204',
           4,
           2,
           'Cleaning' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '301',
           4,
           4,
           'Available' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '302',
           5,
           1,
           'Unavailable' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '303',
           5,
           3,
           'Cleaning' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '304',
           6,
           2,
           'Available' );
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '401',
           4,
           2,
           'Available' ); -- Suite
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '402',
           4,
           3,
           'Occupied' );  -- Suite
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '403',
           5,
           2,
           'Available' ); -- executive suite
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '404',
           5,
           4,
           'Maintenance' ); -- executive suite
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '501',
           6,
           2,
           'Available' ); -- presidential suite
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '502',
           6,
           3,
           'Occupied' );  -- presidential suite
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '105',
           1,
           2,
           'Cleaning' );   -- economy
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '205',
           2,
           4,
           'Available' );  -- standart
insert into room (
   roomnumber,
   id_room_type,
   guestcount,
   roomstatus
) values ( '305',
           3,
           3,
           'Unavailable' );-- deluxe

-- Reservation
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 1,
           4,
           1,
           to_date('2024-03-01','YYYY-MM-DD'),
           to_date('2024-03-05','YYYY-MM-DD'),
           2,
           'Confirmed',
           100.00 );
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 2,
           5,
           1,
           to_date('2024-03-10','YYYY-MM-DD'),
           to_date('2024-03-15','YYYY-MM-DD'),
           1,
           'Pending',
           75.00 );
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 3,
           4,
           1,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-04-07','YYYY-MM-DD'),
           3,
           'Confirmed',
           150.00 );
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 4,
           6,
           2,
           to_date('2024-05-03','YYYY-MM-DD'),
           to_date('2024-08-07','YYYY-MM-DD'),
           3,
           'Confirmed',
           300.00 );
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 5,
           4,
           2,
           to_date('2024-05-02','YYYY-MM-DD'),
           to_date('2024-07-07','YYYY-MM-DD'),
           3,
           'Confirmed',
           250.00 );
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 13,
           10,
           8,
           to_date('2024-06-10','YYYY-MM-DD'),
           to_date('2024-06-15','YYYY-MM-DD'),
           2,
           'Confirmed',
           625.00 ); -- Room 401, customer 10, emp 8
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 14,
           11,
           1,
           to_date('2024-07-20','YYYY-MM-DD'),
           to_date('2024-07-22','YYYY-MM-DD'),
           3,
           'Pending',
           500.00 ); -- Room 402, customer 11, emp 1
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 15,
           12,
           8,
           to_date('2024-08-05','YYYY-MM-DD'),
           to_date('2024-08-10','YYYY-MM-DD'),
           2,
           'Confirmed',
           2750.00 ); -- Room 403, customer 12, emp 8
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 17,
           13,
           1,
           to_date('2024-09-01','YYYY-MM-DD'),
           to_date('2024-09-03','YYYY-MM-DD'),
           2,
           'Confirmed',
           2000.00 ); -- Room 501, customer 13, emp 1
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 18,
           4,
           2,
           to_date('2024-09-15','YYYY-MM-DD'),
           to_date('2024-09-20','YYYY-MM-DD'),
           3,
           'Cancelled',
           3000.00 ); -- Room 502, customer 4, emp 2
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 7,
           5,
           8,
           to_date('2024-10-01','YYYY-MM-DD'),
           to_date('2024-10-04','YYYY-MM-DD'),
           2,
           'Completed',
           750.00 ); -- Room 202, customer 5, emp 8
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 8,
           6,
           1,
           to_date('2024-11-11','YYYY-MM-DD'),
           to_date('2024-11-12','YYYY-MM-DD'),
           2,
           'Confirmed',
           500.00 ); -- Room 203, customer 6, emp 1
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 9,
           10,
           2,
           to_date('2024-12-01','YYYY-MM-DD'),
           to_date('2024-12-05','YYYY-MM-DD'),
           4,
           'Confirmed',
           2500.00 ); -- Room 204, customer 10, emp 2
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 19,
           11,
           8,
           to_date('2025-01-10','YYYY-MM-DD'),
           to_date('2025-01-15','YYYY-MM-DD'),
           2,
           'Pending',
           650.00 ); -- Room 105, customer 11, emp 8 (Using 2025 dates and new prices)
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 20,
           12,
           1,
           to_date('2025-02-20','YYYY-MM-DD'),
           to_date('2025-02-28','YYYY-MM-DD'),
           4,
           'Confirmed',
           1440.00 ); -- Room 205, customer 12, emp 1 (Using 2025 dates and new prices)
insert into reservation (
   id_room,
   id_person,
   id_personemploy,
   datefrom,
   dateto,
   numberofresidents,
   reservationstatus,
   price
) values ( 21,
           13,
           8,
           to_date('2025-03-10','YYYY-MM-DD'),
           to_date('2025-03-12','YYYY-MM-DD'),
           3,
           'Completed',
           540.00 ); -- Room 305, customer 13, emp 8 (Using 2025 dates and new prices)

-- Payment
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 1,
           100.00,
           'Credit Card',
           to_date('2024-03-05','YYYY-MM-DD') );
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 3,
           150.00,
           'Cash',
           to_date('2024-04-07','YYYY-MM-DD') );
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 6,
           625.00,
           'Credit Card',
           to_date('2024-06-15','YYYY-MM-DD') );
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 8,
           2750.00,
           'Bank Transfer',
           to_date('2024-08-01','YYYY-MM-DD') ); -- Platba pred príchodom
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 11,
           750.00,
           'Cash',
           to_date('2024-10-04','YYYY-MM-DD') );
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 12,
           500.00,
           'Credit Card',
           to_date('2024-11-12','YYYY-MM-DD') );
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 13,
           2500.00,
           'Credit Card',
           to_date('2024-12-05','YYYY-MM-DD') );
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 15,
           1440.00,
           'Bank Transfer',
           to_date('2025-02-18','YYYY-MM-DD') ); -- Platba pred príchodom
insert into payment (
   id_reser,
   totalprice,
   paymentmethod,
   paymentdate
) values ( 16,
           540.00,
           'Cash',
           to_date('2025-03-12','YYYY-MM-DD') );

-- Price_in_date
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 1,
           to_date('2024-01-01','YYYY-MM-DD'),
           to_date('2024-4-28','YYYY-MM-DD'),
           50.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 2,
           to_date('2024-01-01','YYYY-MM-DD'),
           to_date('2024-4-28','YYYY-MM-DD'),
           75.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 3,
           to_date('2024-01-01','YYYY-MM-DD'),
           to_date('2024-4-28','YYYY-MM-DD'),
           100.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 4,
           to_date('2024-01-01','YYYY-MM-DD'),
           to_date('2024-4-28','YYYY-MM-DD'),
           200.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 5,
           to_date('2024-01-01','YYYY-MM-DD'),
           to_date('2024-4-28','YYYY-MM-DD'),
           350.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 6,
           to_date('2024-01-01','YYYY-MM-DD'),
           to_date('2024-4-28','YYYY-MM-DD'),
           500.00 );

insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 1,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-8-28','YYYY-MM-DD'),
           75.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 2,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-8-28','YYYY-MM-DD'),
           100.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 3,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-8-28','YYYY-MM-DD'),
           125.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 4,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-8-28','YYYY-MM-DD'),
           250.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 5,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-8-28','YYYY-MM-DD'),
           400.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 6,
           to_date('2024-04-01','YYYY-MM-DD'),
           to_date('2024-8-28','YYYY-MM-DD'),
           600.00 );

insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 1,
           to_date('2024-08-01','YYYY-MM-DD'),
           to_date('2024-12-28','YYYY-MM-DD'),
           100.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 2,
           to_date('2024-08-01','YYYY-MM-DD'),
           to_date('2024-12-28','YYYY-MM-DD'),
           150.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 3,
           to_date('2024-08-01','YYYY-MM-DD'),
           to_date('2024-12-28','YYYY-MM-DD'),
           250.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 4,
           to_date('2024-08-01','YYYY-MM-DD'),
           to_date('2024-12-28','YYYY-MM-DD'),
           500.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 5,
           to_date('2024-08-01','YYYY-MM-DD'),
           to_date('2024-12-28','YYYY-MM-DD'),
           750.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 6,
           to_date('2024-08-01','YYYY-MM-DD'),
           to_date('2024-12-28','YYYY-MM-DD'),
           1000.00 );

insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 1,
           to_date('2025-01-01','YYYY-MM-DD'),
           to_date('2025-04-30','YYYY-MM-DD'),
           110.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 2,
           to_date('2025-01-01','YYYY-MM-DD'),
           to_date('2025-04-30','YYYY-MM-DD'),
           160.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 3,
           to_date('2025-01-01','YYYY-MM-DD'),
           to_date('2025-04-30','YYYY-MM-DD'),
           270.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 4,
           to_date('2025-01-01','YYYY-MM-DD'),
           to_date('2025-04-30','YYYY-MM-DD'),
           550.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 5,
           to_date('2025-01-01','YYYY-MM-DD'),
           to_date('2025-04-30','YYYY-MM-DD'),
           800.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 6,
           to_date('2025-01-01','YYYY-MM-DD'),
           to_date('2025-04-30','YYYY-MM-DD'),
           1100.00 );

insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 1,
           to_date('2025-05-01','YYYY-MM-DD'),
           to_date('2025-08-31','YYYY-MM-DD'),
           130.00 );
insert into price_in_date (
   id_room_type,
   datefrom,
   dateto,
   priceconstant
) values ( 2,
           to_date('2025-05-01','YYYY-MM-DD'),
           to_date('2025-08-31','YYYY-MM-DD'),
           180.00 );

-- Managed_by
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 1,
           1,
           'John Doe',
           'Checked in guest',
           to_timestamp('2024-03-01 10:00:00',
                        'YYYY-MM-DD HH24:MI:SS') );
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 1,
           1,
           'John Doe',
           'Checked out guest',
           to_timestamp('2024-03-05 12:00:00',
                        'YYYY-MM-DD HH24:MI:SS') );
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 2,
           2,
           'Jane Smith',
           'Cleaned room',
           to_timestamp('2024-03-10 11:00:00',
                        'YYYY-MM-DD HH24:MI:SS') );
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 9,
           1,
           'Martin Svoboda',
           'Cleaned room after checkout',
           to_timestamp('2024-03-05 12:30:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 1, after reser 1
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 7,
           3,
           'Peter Novak',
           'Performed minor repair',
           to_timestamp('2024-03-15 14:00:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 3
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 8,
           13,
           'Eva Kovacova',
           'Checked in guest',
           to_timestamp('2024-06-10 15:00:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 13, reser 6
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 9,
           14,
           'Martin Svoboda',
           'Cleaned room before arrival',
           to_timestamp('2024-07-20 14:00:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 14, reser 7
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 7,
           16,
           'Peter Novak',
           'Fixed AC unit',
           to_timestamp('2024-08-01 09:30:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 404
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 9,
           7,
           'Martin Svoboda',
           'Cleaned room after guest departure',
           to_timestamp('2024-10-04 11:00:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 202, reser 11
insert into managed_by (
   id_person,
   id_room,
   managedbyname,
   managedbydescription,
   timeaccessed
) values ( 8,
           19,
           'Eva Kovacova',
           'Checked in guest',
           to_timestamp('2025-01-10 16:00:00',
                        'YYYY-MM-DD HH24:MI:SS') ); -- Room 105, reser 14

-- Equipment
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Bed',
           'King size' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'TV',
           '55 inch' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Desk',
           'Writing desk' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Chair',
           'Office chair' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Minibar',
           'Stocked with drinks and snacks' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Safe',
           'In-room safety box' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Hair Dryer',
           'Wall-mounted hair dryer' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Coffee Maker',
           'Nespresso machine' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Balcony',
           'Private balcony with view' );
insert into equipment (
   equipmentname,
   equipment_description
) values ( 'Bathtub',
           'Separate bathtub' );

-- Includes
insert into includes (
   id_room,
   id_equip
) values ( 1,
           1 );
insert into includes (
   id_room,
   id_equip
) values ( 1,
           2 );
insert into includes (
   id_room,
   id_equip
) values ( 2,
           1 );
insert into includes (
   id_room,
   id_equip
) values ( 2,
           3 );
-- Viac dát pre Includes (pridanie vybavenia do izieb)
-- Room 101 (ID 1): Bed, TV, Desk, Chair (už má) + Minibar, Safe
insert into includes (
   id_room,
   id_equip
) values ( 1,
           5 ); -- Room 101, Minibar
insert into includes (
   id_room,
   id_equip
) values ( 1,
           6 ); -- Room 101, Safe
-- Room 102 (ID 2): Bed, Desk (už má) + TV, Hair Dryer
insert into includes (
   id_room,
   id_equip
) values ( 2,
           2 ); -- Room 102, TV
insert into includes (
   id_room,
   id_equip
) values ( 2,
           7 ); -- Room 102, Hair Dryer
-- Room 103 (ID 3): Economy family room - Bed, TV, Coffee Maker
insert into includes (
   id_room,
   id_equip
) values ( 3,
           1 ); -- Room 103, Bed
insert into includes (
   id_room,
   id_equip
) values ( 3,
           2 ); -- Room 103, TV
insert into includes (
   id_room,
   id_equip
) values ( 3,
           8 ); -- Room 103, Coffee Maker
-- Room 401 (ID 13): Suite - Bed, TV, Desk, Chair, Minibar, Safe, Balcony, Bathtub
insert into includes (
   id_room,
   id_equip
) values ( 13,
           1 ); -- Room 401, Bed
insert into includes (
   id_room,
   id_equip
) values ( 13,
           2 ); -- Room 401, TV
insert into includes (
   id_room,
   id_equip
) values ( 13,
           3 ); -- Room 401, Desk
insert into includes (
   id_room,
   id_equip
) values ( 13,
           4 ); -- Room 401, Chair
insert into includes (
   id_room,
   id_equip
) values ( 13,
           5 ); -- Room 401, Minibar
insert into includes (
   id_room,
   id_equip
) values ( 13,
           6 ); -- Room 401, Safe
insert into includes (
   id_room,
   id_equip
) values ( 13,
           9 ); -- Room 401, Balcony
insert into includes (
   id_room,
   id_equip
) values ( 13,
           10 );-- Room 401, Bathtub
-- Room 501 (ID 17): Presidential Suite - Všetko vybavenie
insert into includes (
   id_room,
   id_equip
) values ( 17,
           1 ); -- Room 501, Bed
insert into includes (
   id_room,
   id_equip
) values ( 17,
           2 ); -- Room 501, TV
insert into includes (
   id_room,
   id_equip
) values ( 17,
           3 ); -- Room 501, Desk
insert into includes (
   id_room,
   id_equip
) values ( 17,
           4 ); -- Room 501, Chair
insert into includes (
   id_room,
   id_equip
) values ( 17,
           5 ); -- Room 501, Minibar
insert into includes (
   id_room,
   id_equip
) values ( 17,
           6 ); -- Room 501, Safe
insert into includes (
   id_room,
   id_equip
) values ( 17,
           7 ); -- Room 501, Hair Dryer
insert into includes (
   id_room,
   id_equip
) values ( 17,
           8 ); -- Room 501, Coffee Maker
insert into includes (
   id_room,
   id_equip
) values ( 17,
           9 ); -- Room 501, Balcony
insert into includes (
   id_room,
   id_equip
) values ( 17,
           10 );-- Room 501, Bathtub

-- Assigned_to
insert into assigned_to (
   id_serv,
   id_reser
) values ( 1,
           1 );
insert into assigned_to (
   id_serv,
   id_reser
) values ( 2,
           1 );
insert into assigned_to (
   id_serv,
   id_reser
) values ( 1,
           3 );
-- Viac dát pre Assigned_to (pridelené služby k rezerváciám)
-- Rezervácia 1 (už má 1, 2)
-- Rezervácia 3 (už má 1)
-- Pridáme služby k novým rezerváciám (ID 6-16) a aj k existujúcim
-- Služby ID 1-4 (pôvodné), 5-9 (nové)
insert into assigned_to (
   id_serv,
   id_reser
) values ( 3,
           1 ); -- Rezervácia 1, Gym Access
insert into assigned_to (
   id_serv,
   id_reser
) values ( 4,
           3 ); -- Rezervácia 3, Spa Treatment
insert into assigned_to (
   id_serv,
   id_reser
) values ( 5,
           6 ); -- Rezervácia 6, Breakfast Buffet
insert into assigned_to (
   id_serv,
   id_reser
) values ( 6,
           6 ); -- Rezervácia 6, Airport Transfer
insert into assigned_to (
   id_serv,
   id_reser
) values ( 1,
           7 ); -- Rezervácia 7, Room Service
insert into assigned_to (
   id_serv,
   id_reser
) values ( 7,
           8 ); -- Rezervácia 8, Extra Bed
insert into assigned_to (
   id_serv,
   id_reser
) values ( 8,
           8 ); -- Rezervácia 8, Pet Fee
insert into assigned_to (
   id_serv,
   id_reser
) values ( 5,
           11 );-- Rezervácia 11, Breakfast Buffet
insert into assigned_to (
   id_serv,
   id_reser
) values ( 1,
           13 );-- Rezervácia 13, Room Service
insert into assigned_to (
   id_serv,
   id_reser
) values ( 9,
           13 );-- Rezervácia 13, Late Checkout
insert into assigned_to (
   id_serv,
   id_reser
) values ( 5,
           15 );-- Rezervácia 15, Breakfast Buffet
insert into assigned_to (
   id_serv,
   id_reser
) values ( 6,
           15 );-- Rezervácia 15, Airport Transfer

commit;

-- SELECT * FROM Person;
-- SELECT * FROM PositionType;
-- SELECT * FROM Services;
-- SELECT * FROM Reservation;
-- SELECT * FROM Room;
-- SELECT * FROM Room_type;
-- SELECT * FROM Price_in_date;
-- SELECT * FROM Managed_by;
-- SELECT * FROM Includes;
-- SELECT * FROM Equipment;
-- SELECT * FROM Payment;
-- SELECT * FROM Assigned_to;


-- Odovzdanie 3: Project03

-- Uloha: join 2 tables: xbockaa00
-- Opis: Zobrazi jednotlivych zamestnancov a ich pracovnu poziciu (+ povinnosti)
select p.firstname,
       p.lastname,
       t.postype,
       t.responsibilities
  from person p
 inner join positiontype t
on p.id_postype = t.id_postype;

-- Uloha: join 2 tables: xbockaa00
-- Opis: Zobrazi datumi rezervacie, cislo priradenej izby s poctom hosti (hotel vie kedy a ake izby pripravit pre dany pocet hosti)
select r.datefrom,
       r.dateto,
       ro.roomnumber as room,
       ro.guestcount as guests
  from reservation r
 inner join room ro
on r.id_room = ro.id_room;

-- Uloha: join 3 tables: xbockaa00
-- Opis: Zobrazi vypis izieb a ich cenove konstanty vo vymedzenych datumoch
select ro.roomnumber,
       r.roomtypetype,
       p.datefrom,
       p.dateto,
       p.priceconstant
  from room_type r
 inner join room ro
on ro.id_room_type = r.id_room_type
 inner join price_in_date p
on p.id_room_type = r.id_room_type
   and p.datefrom < to_date('2024-02-01','YYYY-MM-DD')
   and p.dateto > to_date('2024-04-01','YYYY-MM-DD');

-- Uloha: join 4 tables: xfiloja00
-- Opis: Zobrazi aktualne rezervácie s poctom vybranych sluzieb a celkovu cenu rezervacie vo zvolenom datume pobytu
select ro.roomnumber,
       r.datefrom,
       r.dateto,
       count(t.id_serv) as services,
       p.totalprice
  from reservation r
 inner join assigned_to t
on r.id_reser = t.id_reser
 inner join payment p
on r.id_reser = p.id_reser
 inner join room ro
on r.id_room = ro.id_room
 group by ro.roomnumber,
          r.datefrom,
          r.dateto,
          p.totalprice
having count(t.id_serv) > 0
 order by ro.roomnumber;


-- Uloha: Group by + agregation func (count,sum,avg,min,max): xfiloja00
-- Opis: Zobrazi aktualny stav dostupnosti izieb v hoteli
select roomstatus,
       count(*)
  from room
 group by roomstatus
 order by count(*);

-- Uloha: Group by + agregation func (count,sum,avg,min,max): xbockaa00
-- Opis: Zobrazi zamestnancov s poctom priradenych rezervacii
select p.firstname,
       p.lastname as lastname,
       count(r.id_personemploy) as pocetrezervacii
  from person p
 inner join reservation r
on r.id_personemploy = p.id_person
 group by p.id_person,
          p.firstname,
          p.lastname
 order by count(r.id_personemploy) desc;

-- Uloha: predikat exists: xbockaa00
-- Opis: Zobrazi vsetkych zakaznikov ktory opakovane navstivili hotel
select firstname,
       lastname
  from person
 where exists (
   select 1
     from reservation
    where reservation.id_person = person.id_person
    group by reservation.id_person
   having count(*) > 1
);

-- Uloha: predikat exists: xfiloja00
-- Opis: Zobrazi vsetkych zakaznikov, ktori vytvorili aspon jednu rezervaciu
select p.firstname,
       p.lastname,
       (
          select count(*)
            from reservation re
           where re.id_person = p.id_person
       ) as reservationcount
  from person p
 where p.persontype = 'customer'
   and exists (
   select 1
     from reservation r
    where r.id_person = p.id_person
);

-- Uloha: Predikat IN s vnorenym selectem (nikoliv IN s množinou konstantních dat): xbockaa00
-- Opis: Zobrazi vsetkych klientov ktory boli ubytovany v urcity datum
select *
  from person
 where person.id_person in (
   select reservation.id_person
     from reservation
    where reservation.datefrom <= to_date('2024-05-04',
                    'YYYY-MM-DD')
      and reservation.dateto >= to_date('2024-07-01',
                 'YYYY-MM-DD')
);


-- Select for room ID, their type, and availability
select r.id_room as room_id,
       rt.roomtypetype as room_type,
       r.roomstatus as availability
  from room r
 inner join room_type rt
on r.id_room_type = rt.id_room_type
 order by r.roomstatus,
          rt.roomtypetype;

-- Procedures
create or replace procedure showavailablerooms (
   p_roomtypetype  in varchar default null,
   p_guestcount    in number default null,      -- Zmenené na NUMBER
   p_datefrom      in date default sysdate,
   p_dateto        in date default null,
   p_priceconstant in decimal default null,    -- Zmenené na DECIMAL
   p_equipmentname in varchar default null
) as
   v_dummy                 number; -- Na overenie existencie parametrov
   v_found_rows            boolean := false; -- Príznak, či sa našiel aspoň jeden výsledok

   cursor availableroomscursor is
   select rt.roomtypetype as room_type,
          r.guestcount as housed,
          p.datefrom as price_period_from, -- Premenované pre jasnosť
          p.dateto as price_period_to,   -- Premenované pre jasnosť
          p.priceconstant as price,
          eq.equipmentname as equipment,
          eq.equipment_description
     from room r
    inner join room_type rt
   on r.id_room_type = rt.id_room_type
    inner join price_in_date p
   on r.id_room_type = p.id_room_type
    inner join includes inc
   on r.id_room = inc.id_room
    inner join equipment eq
   on eq.id_equip = inc.id_equip
    where
              -- Krok 1: Filter podľa statusu izby
     r.roomstatus in ( 'Available',
                            'Cleaning' ) -- Zobrazí dostupné a čistené (čoskoro dostupné) izby
      and -- Krok 2: Filter podľa zadaných parametrov
       ( p_roomtypetype is null
       or rt.roomtypetype = p_roomtypetype )
      and ( p_guestcount is null
       or r.guestcount >= p_guestcount ) -- >=, ako si mal v check constraint
      and ( p_equipmentname is null
       or eq.equipmentname = p_equipmentname )
      and ( p_priceconstant is null
       or p.priceconstant <= p_priceconstant ) -- Filtrujeme ceny mensie rovne (predpokladam)

          -- Krok 3: Filter cenových období - hľadá obdobia, ktoré sa prekrývajú s požadovaným rozsahom [p_dateFrom, p_dateTo]
      and p.datefrom <= nvl(
      p_dateto,
      p.datefrom
   ) -- Cena platí od dátumu, ktorý je <= koncu požadovaného rozsahu (alebo neobmedzený koniec)
      and p.dateto >= nvl(
      p_datefrom,
      p.dateto
   )   -- Cena platí do dátumu, ktorý je >= začiatku požadovaného rozsahu (alebo neobmedzený začiatok)

          -- Krok 4: Kontrola, či izba NIE JE obsadená existujúcou rezerváciou v požadovanom dátumovom rozsahu
      and not exists (
      select 1
        from reservation res
       where res.id_room = r.id_room
         and res.reservationstatus in ( 'Confirmed',
                                        'Pending' ) -- Kontrolujeme len aktívne/čakajúce rezervácie
                -- Podmienka prekrývania dvoch intervalov [A, B] a [C, D] je A <= D AND B >= C
                -- Tu: [p_dateFrom, p_dateTo] a [Res.dateFrom, Res.dateTo]
         and res.datefrom <= nvl(
         p_dateto,
         res.datefrom
      ) -- Rezervácia začína <= koncu požadovaného rozsahu
         and res.dateto >= nvl(
         p_datefrom,
         res.dateto
      )   -- Rezervácia končí >= začiatku požadovaného rozsahu
   );


    -- Deklarácia premenných pre načítanie dát z kurzora
   v_roomtype              room_type.roomtypetype%type;
   v_guestcount            room.guestcount%type;
   v_pricefrom             date; -- Zmena typu na DATE
   v_priceto               date;   -- Zmena typu na DATE
   v_price                 price_in_date.priceconstant%type;
   v_equipment             equipment.equipmentname%type;
   v_equipment_description equipment.equipment_description%type;


    -- Custom Exceptions
   noroomtypeavailable exception;
   pragma exception_init ( noroomtypeavailable,-20001 );
    -- noGuestCountAvailable EXCEPTION; -- Táto kontrola nie je pri >= filtri potrebná/zmysluplná
    -- PRAGMA EXCEPTION_INIT(noGuestCountAvailable, -20002);
    -- noDateFrom EXCEPTION; -- Dátumy validuje databáza/používateľ pri vstupe
    -- PRAGMA EXCEPTION_INIT(noDateFrom, -20003);
    -- noDateTo EXCEPTION;   -- Dátumy validuje databáza/používateľ pri vstupe
    -- PRAGMA EXCEPTION_INIT(noDateTo, -20004);
    -- noPriceConstant EXCEPTION; -- Táto kontrola nie je pri <= filtri potrebná/zmysluplná
    -- PRAGMA EXCEPTION_INIT(noPriceConstant, -20005);
   noequipmentnameavailable exception;
   pragma exception_init ( noequipmentnameavailable,-20006 );
    -- Cursor Exception empty
   noavailablerooms exception;
   pragma exception_init ( noavailablerooms,-20007 );
begin

    -- Overenie existencie zadaných hodnôt v tabuľkách (voliteľné, ale môže byť užitočné pre chyby parametrov)
   if p_roomtypetype is not null then
      begin
         select 1
           into v_dummy
           from room_type
          where roomtypetype = p_roomtypetype;
      exception
         when no_data_found then
            raise noroomtypeavailable;
      end;
   end if;

   if p_equipmentname is not null then
      begin
         select 1
           into v_dummy
           from equipment
          where equipmentname = p_equipmentname;
         if v_count = 0 then
            raise noroomtypeavailable; -- Stále vyvoláš tú istú vlastnú výnimku
         end if;
      end;
   end if;

    -- Otvorenie kurzora
   open availableroomscursor;

    -- Výpis hlavičky
   dbms_output.put_line(rpad(
      'Typ izby',
      15
   )
                        || rpad(
      'Miesto',
      10
   )
                        || rpad(
      'Cena Od',
      12
   )
                        || rpad(
      'Cena Do',
      12
   )
                        || rpad(
      'Cena',
      10
   )
                        || rpad(
      'Vybavenie',
      15
   )
                        || 'Popis vybavenia');
   dbms_output.put_line(rpad(
      '----------',
      15
   )
                        || rpad(
      '----------',
      10
   )
                        || rpad(
      '----------',
      12
   )
                        || rpad(
      '----------',
      12
   )
                        || rpad(
      '----------',
      10
   )
                        || rpad(
      '---------------',
      15
   )
                        || '-----------------');

    -- Prechádzanie výsledkov kurzora a ich výpis
   loop
      fetch availableroomscursor into
         v_roomtype,
         v_guestcount,
         v_pricefrom,
         v_priceto,
         v_price,
         v_equipment,
         v_equipment_description;
      exit when availableroomscursor%notfound;
      v_found_rows := true; -- Ak sme načítali riadok, nastavíme príznak

      dbms_output.put_line(rpad(
         v_roomtype,
         15
      )
                           || rpad(
         v_guestcount,
         10
      )
                           || rpad(
         to_char(
            v_pricefrom,
            'YYYY-MM-DD'
         ),
         12
      )
                           || rpad(
         to_char(
            v_priceto,
            'YYYY-MM-DD'
         ),
         12
      )
                           || rpad(
         v_price,
         10
      )
                           || rpad(
         v_equipment,
         15
      )
                           || v_equipment_description);
   end loop;

    -- Zatvorenie kurzora
   close availableroomscursor;

    -- Kontrola, či sa našli nejaké riadky AŽ PO prechode celým kurzorom
   if not v_found_rows then
      raise noavailablerooms;
   end if;
exception
   when noroomtypeavailable then
      dbms_output.put_line('Chyba parametra: Typ izby "'
                           || p_roomtypetype
                           || '" neexistuje.');
    -- WHEN noGuestCountAvailable THEN DBMS_OUTPUT.PUT_LINE('Chyba parametra: Zadaný počet hostí ' || p_guestCount || ' nie je platná hodnota.'); -- Odstránená výnimka
    -- WHEN noPriceConstant THEN DBMS_OUTPUT.PUT_LINE('Chyba parametra: Zadaná cena ' || p_priceConstant || ' nie je platná hodnota.'); -- Odstránená výnimka
   when noequipmentnameavailable then
      dbms_output.put_line('Chyba parametra: Vybavenie "'
                           || p_equipmentname
                           || '" neexistuje.');
   when noavailablerooms then
      dbms_output.put_line('Nenašli sa žiadne dostupné izby zodpovedajúce zadaným kritériám.');
   when others then
        -- Vypísať viac detailov o neočakávanej chybe
      dbms_output.put_line('Vyskytla sa neočakávaná chyba: '
                           || sqlcode
                           || ' - '
                           || sqlerrm);
        -- Môžeš pridať aj RAISE_APPLICATION_ERROR pre návrat kódu chyby na volajúcu stranu, ak je to potrebné
        -- RAISE_APPLICATION_ERROR(-20999, 'Neočakávaná chyba: ' || SQLERRM);
end;
/

   SET SERVEROUTPUT ON;
EXEC showAvailableRooms(p_roomTypeType => 'economy');
EXEC showAvailableRooms(p_guestCount => '3');
EXEC showAvailableRooms(p_dateFrom => DATE '2025-05-05', p_dateTo => DATE '2025-05-01');
EXEC showAvailableRooms(p_priceConstant => '99999');
EXEC showAvailableRooms(p_equipmentName => 'TV');
EXEC showAvailableRooms;