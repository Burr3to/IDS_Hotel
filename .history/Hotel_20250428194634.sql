-- SQLBook: Code
-- Projekt IDS
-- Skript pro vytvorenie databazy Hotelu
-- Zadani: 28 - Hotel
-- Autori: xfiloja00, xbockaa00

DROP TABLE Assigned_to CASCADE CONSTRAINTS;
DROP TABLE Includes CASCADE CONSTRAINTS;
DROP TABLE Managed_by CASCADE CONSTRAINTS;
DROP TABLE Price_in_date CASCADE CONSTRAINTS;
DROP TABLE Room_type CASCADE CONSTRAINTS;
DROP TABLE Payment CASCADE CONSTRAINTS;
DROP TABLE Equipment CASCADE CONSTRAINTS;
DROP TABLE Room CASCADE CONSTRAINTS;
DROP TABLE Reservation CASCADE CONSTRAINTS;
DROP TABLE Services CASCADE CONSTRAINTS;
DROP TABLE PositionType CASCADE CONSTRAINTS;
DROP TABLE Person CASCADE CONSTRAINTS;

-- Toto nastavenie platí pre aktuálnu session
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';


create table Person(
    id_person int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_posType int,
    firstName varchar(12) NOT NULL,
    lastName varchar(12) NOT NULL,
    mail varchar(30) NOT NULL,
    birthNumber  char(11),
    salary decimal,
    bankAccount varchar(30),
    addressTown varchar(50) NOT NULL,
    addressStreet varchar(50) NOT NULL,
    addressNum int NOT NULL,
    personType varchar(20) NOT NULL,
    telephone varchar(20) NOT NULL
);

create table PositionType(
    id_posType int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    responsibilities varchar(40),
    posType varchar(25) NOT NULL
);

create table Services(
    id_serv int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    servicesName varchar(50) NOT NULL,
    servicesDescription varchar(100),
    price decimal(8, 2) NOT NULL
);

create table Reservation(
    id_reser int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_room int NOT NULL,
    id_person int NOT NULL,
    id_personEmploy int NOT NULL,
    dateFrom date NOT NULL,
    dateTo date NOT NULL,
    numberOfResidents int NOT NULL,
    reservationStatus varchar(20) NOT NULL,
    price decimal(8, 2) NOT NULL
);

create table Room(
    id_room int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_room_type int NOT NULL,
    roomNumber varchar(10) NOT NULL,
    guestCount int NOT NULL,
    roomStatus varchar(30) NOT NULL
);

create table Room_type(
    id_room_type int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    roomTypeType varchar(30) NOT NULL
);

create table Price_in_date(
    id_price int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_room_type int NOT NULL,
    dateFrom date NOT NULL,
    dateTo date NOT NULL,
    priceConstant decimal(8, 2) NOT NULL
);

create table Managed_by(
    id_managed int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_person int NOT NULL,
    id_room int NOT NULL,
    managedByName char(20) NOT NULL,
    managedByDescription char(35),
    timeAccessed TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

create table Equipment(
    id_equip int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    equipmentName varchar(20) NOT NULL,
    equipment_description varchar(30)
);

create table Payment(
    id_pay int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_reser int NOT NULL,
    totalPrice decimal(8, 2) NOT NULL,
    paymentMethod varchar(25) NOT NULL,
    paymentDate date NOT NULL
);

create table Includes(
    id_include int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_room int NOT NULL,
    id_equip int NOT NULL
);

create table Assigned_to(
    id_assign int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_serv int NOT NULL,
    id_reser int NOT NULL
);


-- Foreign Key Constraints
ALTER TABLE Person ADD CONSTRAINT FK_person_pos_type FOREIGN KEY (id_posType) REFERENCES PositionType;
ALTER TABLE Reservation ADD CONSTRAINT FK_reser_per FOREIGN KEY (id_person) REFERENCES Person;
ALTER TABLE Reservation ADD CONSTRAINT FK_reser_employ FOREIGN KEY (id_personEmploy) REFERENCES Person;
ALTER TABLE Reservation ADD CONSTRAINT FK_reser_room FOREIGN KEY (id_room) REFERENCES Room;
ALTER TABLE Room ADD CONSTRAINT FK_room_type FOREIGN KEY (id_room_type) REFERENCES Room_type;
ALTER TABLE Payment ADD CONSTRAINT FK_pay_reser FOREIGN KEY (id_reser) REFERENCES Reservation;
ALTER TABLE Price_in_date ADD CONSTRAINT FK_price_in_date_room FOREIGN KEY (id_room_type) REFERENCES Room_type;
ALTER TABLE Managed_by ADD CONSTRAINT FK_manage_per FOREIGN KEY (id_person) REFERENCES Person ON DELETE CASCADE;
ALTER TABLE Managed_by ADD CONSTRAINT FK_manage_room FOREIGN KEY (id_room) REFERENCES Room ON DELETE CASCADE;
ALTER TABLE Includes ADD CONSTRAINT FK_includes_room FOREIGN KEY (id_room) REFERENCES Room ON DELETE CASCADE;
ALTER TABLE Includes ADD CONSTRAINT FK_includes_equip FOREIGN KEY (id_equip) REFERENCES Equipment ON DELETE CASCADE;
ALTER TABLE Assigned_to ADD CONSTRAINT FK_assign_serv FOREIGN KEY (id_serv) REFERENCES Services ON DELETE CASCADE;
ALTER TABLE Assigned_to ADD CONSTRAINT FK_assign_reser FOREIGN KEY (id_reser) REFERENCES Reservation;


-- Data Constraints (Check Constraints)

-- Person
ALTER TABLE Person ADD CONSTRAINT CK_Person_telephone_format CHECK (REGEXP_LIKE(telephone, '^\+?[0-9]{12}$'));
ALTER TABLE Person ADD CONSTRAINT CK_Person_mail_format CHECK (REGEXP_LIKE(mail, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'));
ALTER TABLE Person ADD CONSTRAINT CK_Person_salary CHECK (salary >= 0);
ALTER TABLE Person ADD CONSTRAINT CK_person_type CHECK (personType IN ('employee', 'customer', 'administrator'));
ALTER TABLE Person ADD CONSTRAINT CK_Person_bankAccount_format CHECK (REGEXP_LIKE(bankAccount, '^CZ[0-9]{2}[0-9]{20}$'));
ALTER TABLE Person ADD CONSTRAINT CK_Person_customer_no_position CHECK (personType <> 'customer' OR id_posType IS NULL);

-- Service
ALTER TABLE Services ADD CONSTRAINT CK_Service_price CHECK (price >= 0);

-- Reservation
ALTER TABLE Reservation ADD CONSTRAINT CK_Reservation_date CHECK (DateFrom <= DateTo);
ALTER TABLE Reservation ADD CONSTRAINT CK_Reservation_numOfResidents CHECK (numberOfResidents >= 0);
ALTER TABLE Reservation ADD CONSTRAINT CK_Reservation_status CHECK (reservationStatus IN ('Confirmed', 'Pending', 'Refunded', 'Cancelled', 'Completed'));

-- Room
ALTER TABLE Room ADD CONSTRAINT CK_Room_guest CHECK (guestCount > 0);
ALTER TABLE Room ADD CONSTRAINT CK_Room_status CHECK (roomStatus IN ('Available', 'Occupied', 'Cleaning', 'Maintenance', 'Unavailable'));

-- Room Types
ALTER TABLE Room_type ADD CONSTRAINT CK_Room_type_types CHECK (roomTypeType IN ('economy', 'standart', 'deluxe', 'Suite', 'executive suite', 'presidential suite'));

-- Payment
ALTER TABLE Payment ADD CONSTRAINT CK_Payment_totalPrice CHECK (totalPrice >= 0);

-- PriceInDate
ALTER TABLE Price_in_date ADD CONSTRAINT CK_Price_in_date_date CHECK (DateFrom <= DateTo);
ALTER TABLE Price_in_date ADD CONSTRAINT CK_Price_in_date_priceConstant CHECK (priceConstant > 0);

-- Managed By
ALTER TABLE Managed_by MODIFY (timeAccessed DEFAULT SYSTIMESTAMP);

-- INSERTS ----------------------------------------------------------------------------------------------

-- PositionType
INSERT INTO PositionType (responsibilities, posType) VALUES ('Manages reservations', 'Receptionist');
INSERT INTO PositionType (responsibilities, posType) VALUES ('Cleans rooms', 'Housekeeper');
INSERT INTO PositionType (responsibilities, posType) VALUES ('Oversees operations', 'Manager');
INSERT INTO PositionType (responsibilities, posType) VALUES ('Performs repairs and maintenance', 'Maintenance');
INSERT INTO PositionType (responsibilities, posType) VALUES ('Ensures safety and security', 'Security');


-- Person
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (1, 'John', 'Doe', 'john.doe@email.com', '800101/1234', 2500.00, 'CZ1208000000001234567890', 'Prague', 'Main St', 5, 'employee', '+420777123456');
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (2, 'Jane', 'Smith', 'jane.smith@email.com', '850505/5678', 2000.00, 'CZ2308000000001234567890', 'Brno', 'Side St', 12, 'employee', '+420777654321');
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (3, 'Alice', 'Johnson', 'alice.j@email.com', '901010/9012', 3000.00, 'CZ3408000000001234567890', 'Ostrava', 'Park Ave', 20, 'employee', '+420777112233');
INSERT INTO Person (id_posType ,firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Robert', 'Williams', 'robert.w@email.com', '750303/3456', NULL, NULL, 'Plzen', 'Oak Ln', 8, 'customer', '+420777445566');
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Emily', 'Brown', 'emily.b@email.com', '880808/8765', NULL, NULL, 'Liberec', 'Pine Rd', 15, 'customer', '+420777998877');
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Skrecok', 'Hravi', 'skrecok.h@email.com', '880809/8765', NULL, NULL, 'Pri krbe', 'klieta', 15, 'customer', '+421777998888');
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (4, 'Peter', 'Novak', 'peter.novak@email.com', '820202/4321', 2200.00, 'CZ5608000000001234567890', 'Kosice', 'Industry Rd', 10, 'employee', '+421905111222');
-- PositionType (1) - Receptionist
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (1, 'Eva', 'Kovacova', 'eva.kovacova@email.com', '911111/1111', 2600.00, 'CZ6708000000001234567890', 'Zilina', 'High St', 30, 'employee', '+421905333444');
-- PositionType (2) - Housekeeper
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (2, 'Martin', 'Svoboda', 'martin.s@email.com', '890707/7777', 2100.00, 'CZ7808000000001234567890', 'Banska Bystrica', 'Low Rd', 25, 'employee', '+421905555666');
-- PositionType (3) - Manager
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (3, 'Maria', 'Horvathova', 'maria.h@email.com', '781212/2222', 3500.00, 'CZ8908000000001234567890', 'Nitra', 'Central Sq', 1, 'employee', '+421905777888');
-- PositionType (5) - Security
INSERT INTO Person (id_posType, firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (5, 'Juraj', 'Mrkvicka', 'juraj.m@email.com', '850909/9999', 2300.00, 'CZ9008000000001234567890', 'Trencin', 'Guard St', 50, 'employee', '+421905999000');
-- Zákazníci (id_posType je NULL)
INSERT INTO Person (id_posType ,firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Anna', 'Mala', 'anna.m@email.com', '950404/4444', NULL, NULL, 'Poprad', 'Mountain Rd', 7, 'customer', '+421918111222');
INSERT INTO Person (id_posType ,firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Jan', 'Velky', 'jan.v@email.com', '920606/6666', NULL, NULL, 'Trnava', 'Field St', 11, 'customer', '+421918333444');
INSERT INTO Person (id_posType ,firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Zuzana', 'Dlha', 'zuzana.d@email.com', '870101/1111', NULL, NULL, 'Presov', 'River Side', 22, 'customer', '+421918555666');
INSERT INTO Person (id_posType ,firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Tomas', 'Kratky', 'tomas.k@email.com', '980303/3333', NULL, NULL, 'Martin', 'Forest Ln', 3, 'customer', '+421918777888');
INSERT INTO Person (id_posType ,firstName, lastName, mail, birthNumber, salary, bankAccount, addressTown, addressStreet, addressNum, personType, telephone)
VALUES (NULL, 'Viera', 'Stredna', 'viera.s@email.com', '990505/5555', NULL, NULL, 'Povazska Bystrica', 'City Center', 9, 'customer', '+421918999000');

-- Services
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Room Service', 'Food and drinks to your room', 20.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Laundry', 'Cleaning of clothes', 15.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Gym Access', 'Use of fitness facilities', 10.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Spa Treatment', 'Relaxing treatments', 50.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Breakfast Buffet', 'All-you-can-eat breakfast', 12.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Airport Transfer', 'Shuttle service to/from airport', 30.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Extra Bed', 'Additional bed in the room', 25.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Pet Fee', 'Fee for bringing a pet', 20.00);
INSERT INTO Services (servicesName, servicesDescription, price) VALUES ('Late Checkout', 'Extended checkout time', 40.00);

-- Room type
INSERT INTO Room_type (roomTypeType)
VALUES ('economy');
INSERT INTO Room_type (roomTypeType)
VALUES ('standart');
INSERT INTO Room_type (roomTypeType)
VALUES ('deluxe');
INSERT INTO Room_type (roomTypeType)
VALUES ('Suite');
INSERT INTO Room_type (roomTypeType)
VALUES ('executive suite');
INSERT INTO Room_type (roomTypeType)
VALUES ('presidential suite');

-- Room
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('101', 1, 2, 'Available');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('102', 1, 1, 'Occupied');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('103', 2, 5, 'Unavailable');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('104', 2, 4, 'Occupied');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('201', 3, 3, 'Cleaning');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('202', 3, 2, 'Available');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('203', 3, 6, 'Maintenance');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('204', 4, 2, 'Cleaning');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('301', 4, 4, 'Available');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('302', 5, 1, 'Unavailable');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('303', 5, 3, 'Cleaning');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('304', 6, 2, 'Available');
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('401', 4, 2, 'Available'); -- Suite
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('402', 4, 3, 'Occupied');  -- Suite
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('403', 5, 2, 'Available'); -- executive suite
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('404', 5, 4, 'Maintenance'); -- executive suite
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('501', 6, 2, 'Available'); -- presidential suite
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('502', 6, 3, 'Occupied');  -- presidential suite
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('105', 1, 2, 'Cleaning');   -- economy
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('205', 2, 4, 'Available');  -- standart
INSERT INTO Room (roomNumber, id_room_type, guestCount, roomStatus) VALUES ('305', 3, 3, 'Unavailable');-- deluxe

-- Reservation
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (1, 4, 1, TO_DATE('01/03/2024', 'DD/MM/YYYY'), TO_DATE('05/03/2024', 'DD/MM/YYYY'), 2, 'Confirmed', 100.00);
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (2, 5, 1, TO_DATE('10/03/2024', 'DD/MM/YYYY'), TO_DATE('15/03/2024', 'DD/MM/YYYY'), 1, 'Pending', 75.00);
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (3, 4, 1, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('07/04/2024', 'DD/MM/YYYY'), 3, 'Confirmed', 150.00);
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (4, 6, 2, TO_DATE('03/05/2024', 'DD/MM/YYYY'), TO_DATE('07/08/2024', 'DD/MM/YYYY'), 3, 'Confirmed', 300.00);
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (5, 4, 2, TO_DATE('02/05/2024', 'DD/MM/YYYY'), TO_DATE('07/07/2024', 'DD/MM/YYYY'), 3, 'Confirmed', 250.00);
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (13, 10, 8, TO_DATE('10/06/2024', 'DD/MM/YYYY'), TO_DATE('15/06/2024', 'DD/MM/YYYY'), 2, 'Confirmed', 625.00); -- Room 401, customer 10, emp 8
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (14, 11, 1, TO_DATE('20/07/2024', 'DD/MM/YYYY'), TO_DATE('22/07/2024', 'DD/MM/YYYY'), 3, 'Pending', 500.00); -- Room 402, customer 11, emp 1
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (15, 12, 8, TO_DATE('05/08/2024', 'DD/MM/YYYY'), TO_DATE('10/08/2024', 'DD/MM/YYYY'), 2, 'Confirmed', 2750.00); -- Room 403, customer 12, emp 8
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (17, 13, 1, TO_DATE('01/09/2024', 'DD/MM/YYYY'), TO_DATE('03/09/2024', 'DD/MM/YYYY'), 2, 'Confirmed', 2000.00); -- Room 501, customer 13, emp 1
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (18, 4, 2, TO_DATE('15/09/2024', 'DD/MM/YYYY'), TO_DATE('20/09/2024', 'DD/MM/YYYY'), 3, 'Cancelled', 3000.00); -- Room 502, customer 4, emp 2
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (7, 5, 8, TO_DATE('01/10/2024', 'DD/MM/YYYY'), TO_DATE('04/10/2024', 'DD/MM/YYYY'), 2, 'Completed', 750.00); -- Room 202, customer 5, emp 8
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (8, 6, 1, TO_DATE('11/11/2024', 'DD/MM/YYYY'), TO_DATE('12/11/2024', 'DD/MM/YYYY'), 2, 'Confirmed', 500.00); -- Room 203, customer 6, emp 1
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (9, 10, 2, TO_DATE('01/12/2024', 'DD/MM/YYYY'), TO_DATE('05/12/2024', 'DD/MM/YYYY'), 4, 'Confirmed', 2500.00); -- Room 204, customer 10, emp 2
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (19, 11, 8, TO_DATE('10/01/2025', 'DD/MM/YYYY'), TO_DATE('15/01/2025', 'DD/MM/YYYY'), 2, 'Pending', 650.00); -- Room 105, customer 11, emp 8 (Using 2025 dates and new prices)
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (20, 12, 1, TO_DATE('20/02/2025', 'DD/MM/YYYY'), TO_DATE('28/02/2025', 'DD/MM/YYYY'), 4, 'Confirmed', 1440.00); -- Room 205, customer 12, emp 1 (Using 2025 dates and new prices)
INSERT INTO Reservation (id_room, id_person, id_personEmploy, dateFrom, dateTo, numberOfResidents, reservationStatus, price)
VALUES (21, 13, 8, TO_DATE('10/03/2025', 'DD/MM/YYYY'), TO_DATE('12/03/2025', 'DD/MM/YYYY'), 3, 'Completed', 540.00); -- Room 305, customer 13, emp 8 (Using 2025 dates and new prices)

-- Payment
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (1, 100.00, 'Credit Card', TO_DATE('05/03/2024', 'DD/MM/YYYY'));
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (3, 150.00, 'Cash', TO_DATE('07/04/2024', 'DD/MM/YYYY'));
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (6, 625.00, 'Credit Card', TO_DATE('15/06/2024', 'DD/MM/YYYY'));
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (8, 2750.00, 'Bank Transfer', TO_DATE('01/08/2024', 'DD/MM/YYYY')); -- Platba pred príchodom
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (11, 750.00, 'Cash', TO_DATE('04/10/2024', 'DD/MM/YYYY'));
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (12, 500.00, 'Credit Card', TO_DATE('12/11/2024', 'DD/MM/YYYY'));
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (13, 2500.00, 'Credit Card', TO_DATE('05/12/2024', 'DD/MM/YYYY'));
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (15, 1440.00, 'Bank Transfer', TO_DATE('18/02/2025', 'DD/MM/YYYY')); -- Platba pred príchodom
INSERT INTO Payment (id_reser, totalPrice, paymentMethod, paymentDate)
VALUES (16, 540.00, 'Cash', TO_DATE('12/03/2025', 'DD/MM/YYYY'));

-- Price_in_date
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (1, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('28/04/2024', 'DD/MM/YYYY'), 50.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (2, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('28/04/2024', 'DD/MM/YYYY'), 75.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (3, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('28/04/2024', 'DD/MM/YYYY'), 100.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (4, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('28/04/2024', 'DD/MM/YYYY'), 200.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (5, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('28/04/2024', 'DD/MM/YYYY'), 350.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (6, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('28/04/2024', 'DD/MM/YYYY'), 500.00);

INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (1, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('28/08/2024', 'DD/MM/YYYY'), 75.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (2, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('28/08/2024', 'DD/MM/YYYY'), 100.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (3, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('28/08/2024', 'DD/MM/YYYY'), 125.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (4, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('28/08/2024', 'DD/MM/YYYY'), 250.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (5, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('28/08/2024', 'DD/MM/YYYY'), 400.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (6, TO_DATE('01/04/2024', 'DD/MM/YYYY'), TO_DATE('28/08/2024', 'DD/MM/YYYY'), 600.00);

INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (1, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('28/12/2024', 'DD/MM/YYYY'), 100.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (2, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('28/12/2024', 'DD/MM/YYYY'), 150.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (3, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('28/12/2024', 'DD/MM/YYYY'), 250.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (4, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('28/12/2024', 'DD/MM/YYYY'), 500.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (5, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('28/12/2024', 'DD/MM/YYYY'), 750.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (6, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('28/12/2024', 'DD/MM/YYYY'), 1000.00);

INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (1, TO_DATE('01/01/2025', 'DD/MM/YYYY'), TO_DATE('30/04/2025', 'DD/MM/YYYY'), 110.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (2, TO_DATE('01/01/2025', 'DD/MM/YYYY'), TO_DATE('30/04/2025', 'DD/MM/YYYY'), 160.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (3, TO_DATE('01/01/2025', 'DD/MM/YYYY'), TO_DATE('30/04/2025', 'DD/MM/YYYY'), 270.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (4, TO_DATE('01/01/2025', 'DD/MM/YYYY'), TO_DATE('30/04/2025', 'DD/MM/YYYY'), 550.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (5, TO_DATE('01/01/2025', 'DD/MM/YYYY'), TO_DATE('30/04/2025', 'DD/MM/YYYY'), 800.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (6, TO_DATE('01/01/2025', 'DD/MM/YYYY'), TO_DATE('30/04/2025', 'DD/MM/YYYY'), 1100.00);

INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (1, TO_DATE('01/05/2025', 'DD/MM/YYYY'), TO_DATE('31/08/2025', 'DD/MM/YYYY'), 130.00);
INSERT INTO Price_in_date (id_room_type, dateFrom, dateTo, priceConstant)
VALUES (2, TO_DATE('01/05/2025', 'DD/MM/YYYY'), TO_DATE('31/08/2025', 'DD/MM/YYYY'), 180.00);

-- Managed_by
-- TO_TIMESTAMP format byva YYYY-MM-DD HH24:MI:SS.fff, tento format nebudem menit, lebo NLS_DATE_FORMAT sa tyka len typu DATE, nie TIMESTAMP
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (1, 1, 'John Doe', 'Checked in guest', TO_TIMESTAMP('2024-03-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (1, 1, 'John Doe', 'Checked out guest', TO_TIMESTAMP('2024-03-05 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (2, 2, 'Jane Smith', 'Cleaned room', TO_TIMESTAMP('2024-03-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (9, 1, 'Martin Svoboda', 'Cleaned room after checkout', TO_TIMESTAMP('2024-03-05 12:30:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 1, after reser 1
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (7, 3, 'Peter Novak', 'Performed minor repair', TO_TIMESTAMP('2024-03-15 14:00:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 3
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (8, 13, 'Eva Kovacova', 'Checked in guest', TO_TIMESTAMP('2024-06-10 15:00:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 13, reser 6
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (9, 14, 'Martin Svoboda', 'Cleaned room before arrival', TO_TIMESTAMP('2024-07-20 14:00:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 14, reser 7
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (7, 16, 'Peter Novak', 'Fixed AC unit', TO_TIMESTAMP('2024-08-01 09:30:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 404
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (9, 7, 'Martin Svoboda', 'Cleaned room after guest departure', TO_TIMESTAMP('2024-10-04 11:00:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 202, reser 11
INSERT INTO Managed_by (id_person, id_room, managedByName, managedByDescription, timeAccessed)
VALUES (8, 19, 'Eva Kovacova', 'Checked in guest', TO_TIMESTAMP('2025-01-10 16:00:00', 'YYYY-MM-DD HH24:MI:SS')); -- Room 105, reser 14

-- Equipment
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Bed', 'King size');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('TV', '55 inch');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Desk', 'Writing desk');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Chair', 'Office chair');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Minibar', 'Stocked with drinks and snacks');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Safe', 'In-room safety box');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Hair Dryer', 'Wall-mounted hair dryer');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Coffee Maker', 'Nespresso machine');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Balcony', 'Private balcony with view');
INSERT INTO Equipment (equipmentName, equipment_description) VALUES ('Bathtub', 'Separate bathtub');

-- Includes
INSERT INTO Includes (id_room, id_equip) VALUES (1, 1);
INSERT INTO Includes (id_room, id_equip) VALUES (1, 2);
INSERT INTO Includes (id_room, id_equip) VALUES (2, 1);
INSERT INTO Includes (id_room, id_equip) VALUES (2, 3);
-- Viac dát pre Includes (pridanie vybavenia do izieb)
-- Room 101 (ID 1): Bed, TV, Desk, Chair (už má) + Minibar, Safe
INSERT INTO Includes (id_room, id_equip) VALUES (1, 5); -- Room 101, Minibar
INSERT INTO Includes (id_room, id_equip) VALUES (1, 6); -- Room 101, Safe
-- Room 102 (ID 2): Bed, Desk (už má) + TV, Hair Dryer
INSERT INTO Includes (id_room, id_equip) VALUES (2, 2); -- Room 102, TV
INSERT INTO Includes (id_room, id_equip) VALUES (2, 7); -- Room 102, Hair Dryer
-- Room 103 (ID 3): Economy family room - Bed, TV, Coffee Maker
INSERT INTO Includes (id_room, id_equip) VALUES (3, 1); -- Room 103, Bed
INSERT INTO Includes (id_room, id_equip) VALUES (3, 2); -- Room 103, TV
INSERT INTO Includes (id_room, id_equip) VALUES (3, 8); -- Room 103, Coffee Maker
-- Room 401 (ID 13): Suite - Bed, TV, Desk, Chair, Minibar, Safe, Balcony, Bathtub
INSERT INTO Includes (id_room, id_equip) VALUES (13, 1); -- Room 401, Bed
INSERT INTO Includes (id_room, id_equip) VALUES (13, 2); -- Room 401, TV
INSERT INTO Includes (id_room, id_equip) VALUES (13, 3); -- Room 401, Desk
INSERT INTO Includes (id_room, id_equip) VALUES (13, 4); -- Room 401, Chair
INSERT INTO Includes (id_room, id_equip) VALUES (13, 5); -- Room 401, Minibar
INSERT INTO Includes (id_room, id_equip) VALUES (13, 6); -- Room 401, Safe
INSERT INTO Includes (id_room, id_equip) VALUES (13, 9); -- Room 401, Balcony
INSERT INTO Includes (id_room, id_equip) VALUES (13, 10);-- Room 401, Bathtub
-- Room 501 (ID 17): Presidential Suite - Všetko vybavenie
INSERT INTO Includes (id_room, id_equip) VALUES (17, 1); -- Room 501, Bed
INSERT INTO Includes (id_room, id_equip) VALUES (17, 2); -- Room 501, TV
INSERT INTO Includes (id_room, id_equip) VALUES (17, 3); -- Room 501, Desk
INSERT INTO Includes (id_room, id_equip) VALUES (17, 4); -- Room 501, Chair
INSERT INTO Includes (id_room, id_equip) VALUES (17, 5); -- Room 501, Minibar
INSERT INTO Includes (id_room, id_equip) VALUES (17, 6); -- Room 501, Safe
INSERT INTO Includes (id_room, id_equip) VALUES (17, 7); -- Room 501, Hair Dryer
INSERT INTO Includes (id_room, id_equip) VALUES (17, 8); -- Room 501, Coffee Maker
INSERT INTO Includes (id_room, id_equip) VALUES (17, 9); -- Room 501, Balcony
INSERT INTO Includes (id_room, id_equip) VALUES (17, 10);-- Room 501, Bathtub

-- Assigned_to
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (1, 1);
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (2, 1);
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (1, 3);
-- Viac dát pre Assigned_to (pridelené služby k rezerváciám)
-- Rezervácia 1 (už má 1, 2)
-- Rezervácia 3 (už má 1)
-- Pridáme služby k novým rezerváciám (ID 6-16) a aj k existujúcim
-- Služby ID 1-4 (pôvodné), 5-9 (nové)
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (3, 1); -- Rezervácia 1, Gym Access
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (4, 3); -- Rezervácia 3, Spa Treatment
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (5, 6); -- Rezervácia 6, Breakfast Buffet
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (6, 6); -- Rezervácia 6, Airport Transfer
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (1, 7); -- Rezervácia 7, Room Service
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (7, 8); -- Rezervácia 8, Extra Bed
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (8, 8); -- Rezervácia 8, Pet Fee
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (5, 11);-- Rezervácia 11, Breakfast Buffet
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (1, 13);-- Rezervácia 13, Room Service
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (9, 13);-- Rezervácia 13, Late Checkout
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (5, 15);-- Rezervácia 15, Breakfast Buffet
INSERT INTO Assigned_to (id_serv, id_reser) VALUES (6, 15);-- Rezervácia 15, Airport Transfer

COMMIT;

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
SELECT P.firstName, P.lastName, T.posType, T.responsibilities
FROM Person P
INNER JOIN POSITIONTYPE T ON P.id_posType = T.id_posType;

-- Uloha: join 2 tables: xbockaa00
-- Opis: Zobrazi datumi rezervacie, cislo priradenej izby s poctom hosti (hotel vie kedy a ake izby pripravit pre dany pocet hosti)
SELECT R.dateFrom, R.dateTo, Ro.roomNumber as Room, Ro.guestCount as Guests
FROM Reservation R
INNER JOIN Room Ro ON R.id_room = Ro.id_room;

-- Uloha: join 3 tables: xbockaa00
-- Opis: Zobrazi vypis izieb a ich cenove konstanty vo vymedzenych datumoch
SELECT Ro.roomNumber, R.roomTypeType, P.dateFrom, P.dateTo, P.priceConstant
FROM Room_type R
INNER JOIN Room Ro ON Ro.id_room_type=R.id_room_type
INNER JOIN Price_in_date P ON P.id_room_type=R.id_room_type
    -- Zmena formatu datumu v TO_DATE
    AND P.dateFrom < TO_DATE('01/02/2024', 'DD/MM/YYYY') AND P.dateTo > TO_DATE('01/04/2024', 'DD/MM/YYYY');

-- Uloha: join 4 tables: xfiloja00
-- Opis: Zobrazi aktualne rezervácie s poctom vybranych sluzieb a celkovu cenu rezervacie vo zvolenom datume pobytu
select Ro.roomNumber, R.dateFrom, R.dateTo, count(T.id_serv) as Services, P.totalPrice
from reservation R
inner join Assigned_to T on R.id_reser = T.id_reser
inner join Payment P on R.id_reser = P.id_reser
inner join Room Ro on R.id_room = Ro.id_room
group by Ro.roomNumber, R.dateFrom, R.dateTo, P.totalPrice
having count(T.id_serv) > 0
order by Ro.roomNumber;


-- Uloha: Group by + agregation func (count,sum,avg,min,max): xfiloja00
-- Opis: Zobrazi aktualny stav dostupnosti izieb v hoteli
select roomStatus ,count(*)
from room
group by roomStatus
ORDER BY count(*);

-- Uloha: Group by + agregation func (count,sum,avg,min,max): xbockaa00
-- Opis: Zobrazi zamestnancov s poctom priradenych rezervacii
SELECT P.firstName, P.lastName as lastname, count(R.id_personEmploy) as pocetRezervacii
FROM Person P
INNER JOIN Reservation R ON R.id_personEmploy = P.id_person
GROUP BY P.id_person, P.firstName, P.lastName
ORDER BY count(R.id_personEmploy) DESC;

-- Uloha: predikat exists: xbockaa00
-- Opis: Zobrazi vsetkych zakaznikov ktory opakovane navstivili hotel
SELECT firstName, lastName
FROM Person
WHERE EXISTS (
    SELECT 1
    FROM Reservation
    WHERE Reservation.ID_PERSON = Person.ID_PERSON
    GROUP BY Reservation.ID_PERSON
    HAVING COUNT(*) > 1);

-- Uloha: predikat exists: xfiloja00
-- Opis: Zobrazi vsetkych zakaznikov, ktori vytvorili aspon jednu rezervaciu
SELECT P.firstName, P.lastName,
    (select COUNT(*)
    from Reservation Re
    where Re.id_person = P.id_person) as ReservationCount
from Person P
where P.personType = 'customer'
and exists (
    select 1
    from Reservation R
    where R.id_person = P.id_person
    );

-- Uloha: Predikat IN s vnorenym selectem (nikoliv IN s množinou konstantních dat): xbockaa00
-- Opis: Zobrazi vsetkych klientov ktory boli ubytovany v urcity datum
SELECT *
FROM Person
WHERE Person.ID_PERSON IN (
    -- Zmena formatu datumu v TO_DATE
    SELECT Reservation.ID_PERSON
    FROM Reservation
    WHERE Reservation.DATEFROM <= TO_DATE('04/05/2024', 'DD/MM/YYYY') AND Reservation.DATETO >= TO_DATE('01/07/2024', 'DD/MM/YYYY')
);

-- Procedures
-- Main function that the customer will call when trying to find available dates from the website. Allows him to select custom parameters and leave some blank.
create or replace procedure showAvailableRooms (
   p_roomtypetype  in varchar default null,
   p_guestcount    in number default null,
   p_datefrom      in date default sysdate,
   p_dateto        in date default null,
   p_priceconstant in decimal default null,
   p_equipmentname in varchar default null
) as
    CURSOR availableRoomsCursor IS
        select R.id_room,
               Rt.roomTypeType as Room_type,
               R.guestCount as Housed,
               P.dateFrom    as Price_Period_From,
               P.dateTo      as Price_Period_To,
               P.priceConstant as Price
        from Room R
        inner join Room_type Rt on R.id_room_type = Rt.id_room_type
        inner join Price_in_date P on R.id_room_type = P.id_room_type
        LEFT join Includes Inc on R.id_room = Inc.id_room
        LEFT join Equipment Eq on Eq.id_equip = Inc.id_equip
        WHERE
            R.roomStatus IN ('Available', 'Cleaning')
            AND (p_roomTypeType is null or Rt.roomTypeType = p_roomTypeType)
            AND (p_guestCount IS NULL OR R.guestCount >= p_guestCount)
            AND (p_equipmentName IS NULL OR Eq.equipmentName = p_equipmentName)
            AND (p_priceConstant IS NULL OR P.priceConstant <= p_priceConstant)
            AND P.dateFrom <= NVL(p_dateTo, P.dateFrom)
            AND P.dateTo   >= NVL(p_dateFrom, P.dateTo)
            AND NOT EXISTS (
                SELECT 1
                FROM Reservation Res
                WHERE Res.id_room = R.id_room
                    AND Res.reservationStatus IN ('Confirmed', 'Pending')
                    AND Res.dateFrom <= NVL(p_dateTo, Res.dateFrom)
                    AND Res.dateTo   >= NVL(p_dateFrom, Res.dateTo)
                            )
        GROUP BY R.id_room, Rt.roomTypeType, R.guestCount, P.dateFrom, P.dateTo, P.priceConstant
        ORDER BY Rt.roomTypeType, R.id_room, P.dateFrom 
    ;

    -- Deklarácia premenných pre načítanie dát z kurzora
    v_room_id Room.id_room%TYPE;
    v_roomType Room_type.roomTypeType%TYPE;
    v_guestCount Room.guestCount%TYPE;
    v_priceFrom Date;
    v_priceTo Date;
    v_price Price_in_date.priceConstant%TYPE;

    v_dummy NUMBER;
    v_found_rows BOOLEAN := FALSE;


    -- Custom Exceptions 
    noRoomTypeAvailable EXCEPTION;
    PRAGMA EXCEPTION_INIT(noRoomTypeAvailable, -20001);
    noEquipmentNameAvailable EXCEPTION;
    PRAGMA EXCEPTION_INIT(noEquipmentNameAvailable, -20006);
    noAvailableRooms EXCEPTION;
    PRAGMA EXCEPTION_INIT(noAvailableRooms, -20007);

begin

    IF p_roomTypeType IS NOT NULL THEN
        SELECT COUNT(*) INTO v_dummy FROM Room_type WHERE roomTypeType = p_roomTypeType;
        IF v_dummy = 0 THEN
            RAISE noRoomTypeAvailable;
        END IF;
    END IF;

    IF p_equipmentName IS NOT NULL THEN
        SELECT COUNT(*) INTO v_dummy FROM Equipment WHERE equipmentName = p_equipmentName;
        IF v_dummy = 0 THEN
            RAISE noEquipmentNameAvailable;
        END IF;
    END IF;


    IF p_dateFrom IS NOT NULL AND p_dateTo IS NOT NULL AND p_dateFrom > p_dateTo THEN
        DBMS_OUTPUT.PUT_LINE('Chyba: Dátum "Od" (' || TO_CHAR(p_dateFrom, 'DD/MM/YYYY') || ') nesmie byť po dátume "Do" (' || TO_CHAR(p_dateTo, 'DD/MM/YYYY') || ').');
        RETURN;
    END IF;

    IF p_dateFrom IS NULL AND p_dateTo IS NOT NULL THEN
         DBMS_OUTPUT.PUT_LINE('Upozornenie: Zadaný dátum "Do" bez dátumu "Od". Hľadá sa od SYSDATE.');
    END IF;


    OPEN availableRoomsCursor;

    DBMS_OUTPUT.PUT_LINE(RPAD('ID Izby', 8) || RPAD('Typ izby', 20) || RPAD('Miesto', 10) || RPAD('Cena Od', 12) || RPAD('Cena Do', 12) || RPAD('Cena', 10));
    DBMS_OUTPUT.PUT_LINE(RPAD('-------', 8) || RPAD('---------------', 20) || RPAD('----------', 10) || RPAD('----------', 12) || RPAD('----------', 12) || RPAD('----------', 10));

    LOOP
        FETCH availableRoomsCursor INTO v_room_id, v_roomType, v_guestCount, v_priceFrom, v_priceTo, v_price;
        EXIT WHEN availableRoomsCursor%NOTFOUND;

        v_found_rows := TRUE;

        DBMS_OUTPUT.PUT_LINE(RPAD(v_room_id, 8) || RPAD(v_roomType, 20) || RPAD(v_guestCount, 10) || RPAD(TO_CHAR(v_priceFrom, 'DD/MM/YYYY'), 12)
        || RPAD(TO_CHAR(v_priceTo, 'DD/MM/YYYY'), 12) || RPAD(v_price, 10));
    END LOOP;

    CLOSE availableRoomsCursor;

    IF NOT v_found_rows THEN
        RAISE noAvailableRooms;
    END IF;

    EXCEPTION
    WHEN noRoomTypeAvailable THEN 
        DBMS_OUTPUT.PUT_LINE('Chyba parametra: Typ izby "' || p_roomTypeType || '" neexistuje.');
    WHEN noEquipmentNameAvailable THEN 
        DBMS_OUTPUT.PUT_LINE('Chyba parametra: Vybavenie "' || p_equipmentName || '" neexistuje.');
    WHEN noAvailableRooms THEN 
        DBMS_OUTPUT.PUT_LINE('Nenašli sa žiadne dostupné izby zodpovedajúce zadaným kritériám.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Vyskytla sa neočakávaná chyba: ' || SQLCODE || ' - ' || SQLERRM);
end;
/

-- p_priceConstant problem, nic s tym nerobime?

SET SERVEROUTPUT ON;

EXEC showAvailableRooms();
EXEC showAvailableRooms(p_roomTypeType => 'economy', p_equipmentName => 'TV');
EXEC showAvailableRooms(p_roomTypeType => 'standart');
EXEC showAvailableRooms(p_guestCount => 3);
EXEC showAvailableRooms(p_dateFrom => TO_DATE('01/05/2025', 'DD/MM/YYYY'), p_dateTo => TO_DATE('05/05/2025', 'DD/MM/YYYY'));
EXEC showAvailableRooms(p_equipmentName => 'TV');
EXEC showAvailableRooms(p_dateFrom => TO_DATE('10/07/2024', 'DD/MM/YYYY'), p_dateTo => TO_DATE('20/07/2024', 'DD/MM/YYYY'));
EXEC showAvailableRooms(p_roomTypeType => 'executive suite', p_dateFrom => TO_DATE('01/09/2024', 'DD/MM/YYYY'), p_dateTo => TO_DATE('10/09/2024', 'DD/MM/YYYY'));
EXEC showAvailableRooms(p_roomTypeType => 'presidential suite');
EXEC showAvailableRooms(p_equipmentName => 'Sauna');


create or replace procedure showRoomsWithEmployeesHistory (
    p_lastName      in varchar default null,
    p_firstName     in varchar default null,
    p_roomtypetype  in varchar default null,
    p_datefrom      in date default null,
    p_dateto        in date default null
)
as
    -- Deklaracia kurzora
    CURSOR roomsWithEmployeesHistory IS
        select
            R.id_room,
            R.roomNumber,
            Rt.roomTypeType,
            Per.lastName,
            Per.firstName,
            M.timeAccessed,
            Pos.posType,
            Pos.responsibilities,
            M.managedByDescription     -- Z Managed_by (VARCHAR)
        from Managed_by M -- Zacina od tabulky Managed_by
        inner join Room R on M.id_room = R.id_room -- Spojenie na Room
        inner join Room_type Rt on R.id_room_type = Rt.id_room_type -- Spojenie na Room_type
        inner join Person Per on M.id_person = Per.id_person -- Spojenie na Person (zamestnanca/admina)
        left join PositionType Pos on Per.id_posType = Pos.id_posType -- Spojenie na PositionType (LEFT JOIN pre pripad, ze Per.id_posType je NULL)
        where
            Per.personType IN ('employee','administrator') -- Filter na typ osoby
            and (p_lastName is null or Per.lastName = p_lastName)
            and (p_firstName is null or Per.firstName = p_firstName)
            and (p_roomtypetype is null or Rt.roomTypeType = p_roomtypetype) -- Opraveny alias Rt.roomTypeType
            -- Datumovy filter na timeAccessed (TIMESTAMP) vs zadane datumy (DATE)
            -- Prevedieme TIMESTAMP na DATE pomocou TRUNC() pre porovnanie
            AND (p_datefrom IS NULL OR TRUNC(M.timeAccessed) >= p_datefrom)
            AND (p_dateto IS NULL OR TRUNC(M.timeAccessed) <= p_dateto)
        -- Bez GROUP BY - chceme kazdy zaznam z Managed_by
        ORDER BY M.timeAccessed DESC, R.roomNumber, Per.lastName;

    -- Deklaracia premennych pre nacitanie dat Z KURZORA - musia presne zodpovedat SELECT listu kurzora
    v_room_id           Room.id_room%TYPE;
    v_room_number       Room.roomNumber%TYPE;
    v_roomType          Room_type.roomTypeType%TYPE;
    v_employee_lastName Person.lastName%TYPE; -- Zmena nazvu kvoli prehladnosti
    v_employee_firstName Person.firstName%TYPE; -- Zmena nazvu kvoli prehladnosti
    v_management_time   TIMESTAMP; -- Typ TIMESTAMP pre timeAccessed
    v_position_type     PositionType.posType%TYPE; -- Zmena nazvu kvoli prehladnosti
    v_responsibilities  PositionType.responsibilities%TYPE; -- Zmena nazvu kvoli prehladnosti
    v_managed_desc      Managed_by.managedByDescription%TYPE;

    v_dummy NUMBER; -- pre kontrolu existencie parametrov
    v_found_rows BOOLEAN := FALSE; -- Príznak, či sa našiel aspoň jeden výsledok

    -- Custom Exceptions - premenovane pre jasnost a konzistentnost
    invalidRoomTypeParameter EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalidRoomTypeParameter, -20001);
    invalidPersonNameParameter EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalidPersonNameParameter, -20002);
    invalidDateRangeParameter EXCEPTION; -- Pre chybu p_dateFrom > p_dateTo
    PRAGMA EXCEPTION_INIT(invalidDateRangeParameter, -20003);
    noHistoryFound EXCEPTION; -- Ak kurzor nenajde ziadne zaznamy
    PRAGMA EXCEPTION_INIT(noHistoryFound, -20007);


begin

    -- Overenie existencie zadaných hodnot parametrov pred spustenim kurzora
    IF p_roomTypeType IS NOT NULL THEN
        SELECT COUNT(*) INTO v_dummy FROM Room_type WHERE roomTypeType = p_roomTypeType;
        IF v_dummy = 0 THEN
            RAISE invalidRoomTypeParameter; -- Vyvolanie novej vynimky
        END IF;
    END IF;

    IF p_lastName IS NOT NULL OR p_firstName IS NOT NULL THEN
        -- Kontrola, ci osoba so zadanym menom/priezviskom existuje
        SELECT COUNT(*) INTO v_dummy FROM Person
        WHERE (p_lastName IS NULL OR lastName = p_lastName)
          AND (p_firstName IS NULL OR firstName = p_firstName)
          AND personType IN ('employee', 'administrator'); -- Kontrola existencie len medzi relevantnymi typmi osob

        IF v_dummy = 0 THEN
            RAISE invalidPersonNameParameter; -- Vyvolanie novej vynimky
        END IF;
    END IF;

    -- Validácia dátumov
    IF p_dateFrom IS NOT NULL AND p_dateTo IS NOT NULL AND p_dateFrom > p_dateTo THEN
        RAISE invalidDateRangeParameter; -- Vyvolanie novej vynimky
    END IF;


    -- Otvorenie kurzora - pouziva sa NAZOV KURZORA
    OPEN roomsWithEmployeesHistory;

    -- Výpis hlavičky
    DBMS_OUTPUT.PUT_LINE(RPAD('ID Izby', 8) || RPAD('Cislo Izby', 12) || RPAD('Typ izby', 15) || RPAD('Priezvisko', 15) || RPAD('Meno', 12) || RPAD('Datum Cinnosti', 15) || RPAD('Cas', 10) || RPAD('Pozicia', 15) || RPAD('Popis Cinnosti', 30));
    DBMS_OUTPUT.PUT_LINE(RPAD('-------', 8) || RPAD('------------', 12) || RPAD('---------------', 15) || RPAD('---------------', 15) || RPAD('----------', 12) || RPAD('--------------', 15) || RPAD('----------', 10) || RPAD('---------------', 15) || RPAD('----------------', 30));

    -- Prechádzanie výsledkov kurzora a ich výpis - pouziva sa NAZOV KURZORA
    LOOP
        FETCH roomsWithEmployeesHistory INTO v_room_id, v_room_number, v_roomType, v_employee_lastName, v_employee_firstName, v_management_time, v_position_type, v_responsibilities, v_managed_desc;
        EXIT WHEN roomsWithEmployeesHistory%notfound;

        v_found_rows := TRUE; -- Ak sme načítali riadok, nastavíme príznak

        -- Výpis dát - formatujeme TIMESTAMP na DATE a CAS
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_room_id, 8) ||
            RPAD(v_room_number, 12) ||
            RPAD(v_roomType, 15) ||
            RPAD(v_employee_lastName, 15) ||
            RPAD(v_employee_firstName, 12) ||
            RPAD(TO_CHAR(v_management_time, 'DD/MM/YYYY'), 15) || -- Format datumu
            RPAD(TO_CHAR(v_management_time, 'HH24:MI:SS'), 10) || -- Format casu
            RPAD(NVL(v_position_type, 'Nezname'), 15) || -- Pouzitie NVL ak posType je NULL (pre LEFT JOIN)
            NVL(v_managed_desc, 'Bez popisu') -- Pouzitie NVL ak managedByDescription je NULL
        );
    END LOOP;

    -- Zatvorenie kurzora - pouziva sa NAZOV KURZORA
    CLOSE roomsWithEmployeesHistory;

    -- Kontrola, či sa našli nejaké riadky AŽ PO prechode celým kurzorom
    IF NOT v_found_rows THEN
        RAISE noHistoryFound; -- Vyvolanie novej vynimky
    END IF;

    EXCEPTION
    -- Ošetrovače pre nové výnimky
    WHEN invalidRoomTypeParameter THEN
        DBMS_OUTPUT.PUT_LINE('Chyba parametra: Typ izby "' || p_roomTypeType || '" neexistuje.');
    WHEN invalidPersonNameParameter THEN
        DBMS_OUTPUT.PUT_LINE('Chyba parametra: Osoba s menom "' || NVL(p_firstName, 'Nezname') || '" a priezviskom "' || NVL(p_lastName, 'Nezname') || '" (zamestnanec/admin) nebola najdena.');
    WHEN invalidDateRangeParameter THEN
        DBMS_OUTPUT.PUT_LINE('Chyba parametra: Dátum "Od" (' || TO_CHAR(p_dateFrom, 'DD/MM/YYYY') || ') nesmie byť po dátume "Do" (' || TO_CHAR(p_dateto, 'DD/MM/YYYY') || ').');
    WHEN noHistoryFound THEN
        DBMS_OUTPUT.PUT_LINE('Nenašli sa žiadne záznamy o činnosti zamestnancov/adminov zodpovedajúce zadaným kritériám.');
    WHEN OTHERS THEN
        -- Vypísať viac detailov o neočakávanej chybe
        DBMS_OUTPUT.PUT_LINE('Vyskytla sa neočakávaná chyba: ' || SQLCODE || ' - ' || SQLERRM);
end;
/

-- Príklady volaní procedúry s DD/MM/YYYY formátom v TO_DATE
SET SERVEROUTPUT ON;

EXEC showRoomsWithEmployeesHistory();


COMMIT;