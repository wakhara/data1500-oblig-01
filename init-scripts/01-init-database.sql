-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller

CREATE TABLE kunde (
    kunde_id SERIAL PRIMARY KEY,
    mobilnummer VARCHAR(15) UNIQUE CHECK (mobilnummer ~ '^[0-9]{8}$'),
    epost VARCHAR(255) UNIQUE CHECK (epost ~ '^[^@]+@[^@]+\.[^@]+$'),
    fornavn VARCHAR(100),
    etternavn VARCHAR(100)
);

CREATE TABLE stasjon (
    stasjon_id SERIAL PRIMARY KEY,
    navn VARCHAR(100),
    adresse VARCHAR(255)
);

CREATE TABLE laas (
    laas_id SERIAL PRIMARY KEY,
    stasjon_id INT REFERENCES stasjon(stasjon_id)
);

CREATE TABLE sykkel (
    sykkel_id SERIAL PRIMARY KEY,
    stasjon_id INT REFERENCES stasjon(stasjon_id),
    laas_id INT REFERENCES laas(laas_id)
);

CREATE TABLE utleie (
    utleie_id SERIAL PRIMARY KEY,
    kunde_id INT REFERENCES kunde(kunde_id),
    sykkel_id INT REFERENCES sykkel(sykkel_id),
    utlevert_tidspunkt TIMESTAMP,
    innlevert_tidspunkt TIMESTAMP,
    leiebelop NUMERIC(10,2) CHECK (leiebelop >= 0)
);


-- Sett inn testdata
INSERT INTO kunde (mobilnummer, epost, fornavn, etternavn) VALUES
('90000001','ola@norge.no','Ola','Nordmann'),
('90000002','kari@norge.no','Kari','Nordmann');

INSERT INTO stasjon (navn, adresse) VALUES
('Sentrum', 'Storgata 1'),
('Vest', 'Vestveien 5');

INSERT INTO laas (stasjon_id) VALUES
(1),(1),(2),(2);

INSERT INTO sykkel (stasjon_id, laas_id) VALUES
(1,1),(1,2),(2,3),(2,4);

INSERT INTO utleie (kunde_id, sykkel_id, utlevert_tidspunkt, innlevert_tidspunkt, leiebelop) VALUES
(1,1,'2026-03-01 08:00:00','2026-03-01 09:00:00',30.00),
(2,3,'2026-03-01 09:30:00',NULL,50.00); 

-- DBA setninger (rolle: kunde, bruker: kunde_1)

CREATE ROLE kunde;
CREATE USER kunde_1 WITH PASSWORD 'passord123';
GRANT kunde TO kunde_1;

GRANT SELECT, INSERT, UPDATE ON kunde TO kunde;
GRANT SELECT, INSERT, UPDATE ON sykkel TO kunde;
GRANT SELECT, INSERT, UPDATE ON utleie TO kunde;


-- Eventuelt: Opprett indekser for ytelse

CREATE INDEX idx_utleie_kunde ON utleie(kunde_id);
CREATE INDEX idx_utleie_sykkel ON utleie(sykkel_id);

-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;
