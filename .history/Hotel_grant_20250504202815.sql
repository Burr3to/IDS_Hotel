-- SQLBook: Code
-- Skript pre vytvorenie objektov v schéme druhého používateľa (xbockaa00)
-- Využíva práva SELECT udelené prvým používateľom (xfiloja00)

-- POZNAMKA: Prikazy GRANT SELECT ON ... TO xbockaa00;
-- musia byť vykonané používateľom xfiloja00 (vlastníkom tabuliek)
-- pred spustením tohto skriptu používateľom xbockaa00.


-- Pripojiť sa ako používateľ xbockaa00
-- (Toto je konceptuálne, skutočné pripojenie závisí od nástroja - SQL*Plus, SQL Developer, atď.)
-- CONNECT xbockaa00/heslo;

-- Nastavenia pre session (ak sú potrebné, napr. format dátumu)
-- ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';


-- ---------------------------------------------------------
----------- MATERIALIZED VIEW v schéme xbockaa00 -----------
---------------------------------------------------------

DROP MATERIALIZED VIEW mv_customer_loyalty;

-- Vytvorenie materializovaného pohlǎdu v schéme xbockaa00
-- Dopytuje sa na tabuľky v schéme xfiloja00, preto je potreba prefix xfiloja00.
CREATE MATERIALIZED VIEW mv_customer_loyalty
REFRESH COMPLETE ON DEMAND
AS
SELECT
    P.id_person,
    P.firstName,
    P.lastName,
    COUNT(R.id_reser) AS TotalReservations,
    SUM(Pay.totalPrice) AS TotalSpent,
    MIN(R.dateFrom) AS FirstVisitDate,
    MAX(R.dateTo) AS LastVisitDate
FROM xfiloja00.Person P       -- Pristup k tabuľke xfiloja00.Person
INNER JOIN xfiloja00.Reservation R ON P.id_person = R.id_person -- Pristup k tabuľke xfiloja00.Reservation
LEFT JOIN xfiloja00.Payment Pay ON R.id_reser = Pay.id_reser   -- Pristup k tabuľke xfiloja00.Payment
WHERE P.personType = 'customer'
GROUP BY P.id_person, P.firstName, P.lastName;
/

-- Obnovenie materializovaného pohlǎdu po vytvorení
BEGIN
  DBMS_MVIEW.REFRESH('mv_customer_loyalty', 'C');
END;
/

-----------------------------------------------------------
----------- ACCESS / MATERIALIZED VIEW --------------------
-----------------------------------------------------------

-- Zobrazenie vernostného statusu zákazníkov z MV
SELECT
    id_person,
    firstName,
    lastName,
    TotalReservations,
    NVL(TotalSpent, 0) AS TotalSpent,
    FirstVisitDate,
    LastVisitDate,
    CASE
        WHEN TotalReservations >= 40 OR NVL(TotalSpent, 0) >= 10000 THEN 'Obsidian Tier'
        WHEN TotalReservations >= 25 OR NVL(TotalSpent, 0) >= 5000 THEN 'Diamond Tier'
        WHEN TotalReservations >= 15 OR NVL(TotalSpent, 0) >= 2500 THEN 'Platinum Tier'
        WHEN TotalReservations >= 7 OR NVL(TotalSpent, 0) >= 1600 THEN 'Gold Tier'
        WHEN TotalReservations >= 4 OR NVL(TotalSpent, 0) >= 700 THEN 'Silver Tier'
        WHEN TotalReservations >= 1 THEN 'Bronze Tier'
        ELSE 'Unknown Tier'
    END AS LoyaltyStatus
FROM mv_customer_loyalty -- Pristup k MV v vlastnej schéme (prefix xbockaa00. je volitelný)
ORDER BY
    NVL(TotalSpent, 0) DESC,
    TotalReservations DESC,
    lastName,
    firstName;
/

-- ---------------------------------------------------------
----------- Priame dopyty na tabuľky xfiloja00 -------------
------------------------------------------------------------

-- Priklad dopytu na tabuľku Room používateľa xfiloja00
SELECT roomNumber, guestCount, roomStatus
FROM xfiloja00.Room
WHERE roomStatus = 'Available';
/

-- Priklad dopytu na tabuľku Person používateľa xfiloja00 (len zákazníci)
SELECT firstName, lastName, mail
FROM xfiloja00.Person
WHERE personType = 'customer';
/

COMMIT;
/