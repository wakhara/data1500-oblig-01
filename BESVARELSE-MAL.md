# Besvarelse - Refleksjon og Analyse

**Student:** [Warda Khalid Rajput]

**Studentnummer:** [376367]

**Dato:** [01.03.2026]

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**

[- 1. Kunde
En person som registrerer seg og kan leie sykkel.
- Attributter:
* kunde_id (unik ID)
* mobilnummer
* epost
* fornavn
* etternavn
---
Vi må vite hvem som leier sykkelen og hvem som skal betale.


- 2. Sykkel
En fysisk sykkel i systemet.
- Attributter:
* sykkel_id (unik ID)
* stasjon_id (hvor den står – NULL hvis utleid)
* lås_id (hvilken lås den står i – NULL hvis utleid)
---
Vi må vite hvor sykkelen er, eller om den er leid ut.


- 3. Stasjon
Et sted der sykler kan hentes og leveres.
- Attributter:
* stasjon_id
* navn
* adresse
---
Systemet må vite hvor syklene står.


- 4. Lås
En lås på en stasjon.
- Attributter:
* lås_id
* stasjon_id
---
En stasjon har mange låser. En sykkel festes i én lås.


- 5. Utleie
En registrering av at en kunde leier en sykkel.
- Attributter:
* utleie_id
* kunde_id
* sykkel_id
* utlevert_tidspunkt
* innlevert_tidspunkt (NULL hvis ikke levert ennå)
* leiebeløp
--- 
Vi må lagre når sykkelen ble hentet, når den ble levert, og hvor mye kunden skal betale.]

**Attributter for hver entitet:**

[Skriv ditt svar her - list opp attributtene for hver entitet]

---

### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

[Datatyper:
- ID-er → SERIAL (unik, automatisk)
- Navn, adresse, mobil, epost → VARCHAR
- Tidspunkt → TIMESTAMP
- Beløp → NUMERIC(10,2)
- Koordinater → NUMERIC(9,6)
- Fremmednøkler → INT



**`CHECK`-constraints:**

[CHECK-constraints:
- Mobilnummer: 8 siffer → CHECK (mobilnummer ~ '^[0-9]{8}$')
- Epost: må inneholde @ → CHECK (epost ~ '^[^@]+@[^@]+\.[^@]+$')
- Leiebeløp ≥ 0 → CHECK (leiebelop >= 0)]
]

**ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

---

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

- En stasjon har mange låser → 1:N
- En stasjon har mange sykler → 1:N
- En lås kan holde én sykkel om gangen → 1:0..1
- En kunde kan ha mange utleier → 1:N
- En sykkel kan være med i mange utleier over tid → 1:N


**Fremmednøkler:**

- laas.stasjon_id → refererer til stasjon.stasjon_id (binder lås til stasjon)
- sykkel.stasjon_id → refererer til stasjon.stasjon_id (hvilken stasjon sykkel står på)
- sykkel.laas_id → refererer til laas.laas_id (hvilken lås sykkel er låst i)
- utleie.kunde_id → refererer til kunde.kunde_id (hvilken kunde leier sykkel)
- utleie.sykkel_id → refererer til sykkel.sykkel_id (hvilken sykkel leies)


**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

- Alle tabeller har enkle verdier (ingen lister i ett felt), og hver rad har en unik ID.

**Vurdering av 2. normalform (2NF):**

- Alle kolonner i en tabell henger helt sammen med ID-en.  og det er ingen delvise avhengigheter.

**Vurdering av 3. normalform (3NF):**

- Ingen kolonner avhenger av andre kolonner og alt henger bare på ID-en.

**Eventuelle justeringer:**

- Ingen justeringer var nødvendig, modellen er allerede ryddig og følger 3. normalform (3NF).

---


---

### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**



**Spørring mot systemkatalogen:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultat:**

```
[-- Kunder
INSERT INTO kunde (mobilnummer, epost, fornavn, etternavn) VALUES
('90000001','ola@norge.no','Ola','Nordmann'),
('90000002','kari@norge.no','Kari','Nordmann');

-- Stasjoner
INSERT INTO stasjon (navn, adresse) VALUES
('Sentrum', 'Storgata 1'),
('Vest', 'Vestveien 5');

-- Låser
INSERT INTO laas (stasjon_id) VALUES
(1),(1),(2),(2);

-- Sykler
INSERT INTO sykkel (stasjon_id, laas_id) VALUES
(1,1),(1,2),(2,3),(2,4);

-- Utleier
INSERT INTO utleie (kunde_id, sykkel_id, utlevert_tidspunkt, innlevert_tidspunkt, leiebelop) VALUES
(1,1,'2026-03-01 08:00:00', '2026-03-01 09:00:00', 30.00),
(2,3,'2026-03-01 09:30:00', NULL, 50.00); -- aktiv leie
```

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql
[CREATE ROLE kunde;]
```

**SQL for å opprette bruker:**

```sql
[CREATE USER kunde_1 WITH PASSWORD 'passord123';
GRANT kunde TO kunde_1;]
```

**SQL for å tildele rettigheter:**

```sql
[GRANT SELECT, INSERT, UPDATE ON kunde TO kunde;
GRANT SELECT, INSERT, UPDATE ON sykkel TO kunde;
GRANT SELECT, INSERT, UPDATE ON utleie TO kunde;]
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
[CREATE VIEW kunde_utleie_view AS
SELECT u.utleie_id, u.sykkel_id, u.utlevert_tidspunkt, u.innlevert_tidspunkt, u.leiebelop
FROM utleie u
JOIN kunde k ON u.kunde_id = k.kunde_id
WHERE k.kunde_id = current_setting('app.current_kunde_id')::int;]
```

**Ulempe med VIEW vs. POLICIES:**

- VIEW: Skjuler data, men kunden kan fortsatt prøve å endre andre rader hvis rettighetene ikke er strenge.
- POLICIES (RLS): Stopper kunden fra å se eller endre andres data helt.

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

- Høysesong (mai-september, 5 måneder): 5 × 20 000 = 100 000
- Mellomsesong (mars, april, oktober, november, 4 måneder): 4 × 5 000 = 20 000
- Lavsesong (des, jan, feb, 3 måneder): 3 × 500 = 1 500
* Totalt per år:
- 100 000 + 20 000 + 1 500 = 121 500 utleier/år

**Estimat for lagringskapasitet:**

- Kunder: 1000 × 200 B = 0,2 MB
- Stasjoner: 20 × 150 B = 0,003 MB
- Låser: 100 × 50 B = 0,005 MB
- Sykler: 200 × 100 B = 0,02 MB
- Utleier: 121 500 × 200 B = 24,3 M
  
**Totalt for første år:**

- 0,2 + 0,003 + 0,005 + 0,02 + 24,3 ≈ 24,5 MB

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

[- Info som kunde, stasjon og sykkel gjentas i hver rad i CSV.

**Problem 2: Inkonsistens**

[Hvis en stasjon endrer adresse, må alle rader oppdateres ellers blir noen feil.

**Problem 3: Oppdateringsanomalier**

- Slette: Sletter vi siste utleie, mister vi kundedata.
- Innsetting: Ny kunde krever en utleie først.
- Oppdatering: Må endre mange rader samtidig.
- 
**Fordeler med en indeks:**

- Finner data raskere uten å lese hele tabellen.

**Case 1: Indeks passer i RAM**

- Indeksen ligger i minnet og søk skjer raskt.

**Case 2: Indeks passer ikke i RAM**

[Skriv ditt svar her - forklar hvordan flettesortering kan brukes]

**Datastrukturer i DBMS:**

[Skriv ditt svar her - diskuter B+-tre og hash-indekser]

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

- LSM-tree (Log-Structured Merge Tree)

**Begrunnelse:**

**Skrive-operasjoner:**

Passer godt når vi skriver mye, fordi nye data først lagres i minnet og så på disk.

**Lese-operasjoner:**

Lesing skjer sjeldent, og datastrukturen finner data selv om de ligger på forskjellige nivåer på disk.
Kort sagt: LSM-tree er bra for logging og skriver mye, leser lite.
---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

Validering bør gjøres i flere lag: nettleser, applikasjon og database for best sikkerhet og brukeropplevelse.
**Validering i nettleseren:**

Fordeler: Rask tilbakemelding til brukeren, enklere å rette feil.
Ulemper: Kan manipuleres eller hoppes over → ikke sikkert alene.

**Validering i applikasjonslaget:**

Fordeler: Kontrollerer logikk før data går til databasen, beskytter mot feil input.
Ulemper: Må gjøres korrekt, ellers kan feil fortsatt komme gjennom.

**Validering i databasen:**

ordeler: Sikrer at alle data som lagres er gyldige, beskytter mot feil eller ondsinnet input.
Ulemper: Kan være mindre fleksibel og gi dårligere tilbakemelding til bruker

**Konklusjon:**

Validering bør gjøres i alle lag:
- Nettleser → rask tilbakemelding til brukeren
- Applikasjon → sjekker logikk og regler
- Database → sikrer at kun gyldige data lagres
På denne måten får man både sikkerhet, korrekthet og god brukeropplevelse.

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

Jeg har lært om datamodellering, normalisering, SQL, indekser, roller og tilgangskontroll.
Jeg har også forstått hvorfor det er viktig med strukturert og sikker lagring av data.
**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

Oppgaven har hjulpet meg å bruke teori i praksis, lage tabeller, definere relasjoner og skrive SQL. Jeg har øvd på database-integritet, sikkerhet og analyse som er sentrale læringsmål.

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

Å designe forholdene og normalisere tabellene slik at alt ble riktig i 3NF. og å forstå validering og tilgangskontroll på flere lag var litt vanskelig.

**Hva har du lært om databasedesign:**

Viktigheten av å starte med en klar datamodell før man lager tabeller. og vordan man kan redusere feil, redundans og inkonsistens med normalisering og riktige nøkkelrelasjoner. At planlegging og refleksjon gjør det mye enklere å bygge en database som fungerer i praksis.

---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

ja

**Eventuelle feil og rettelser:**

var det ofte fordi tabell- eller kolonnenavn ikke stemte.
Dette ble rettet ved å korrigere navnene i spørringene.
Noen feil kom av NULL-verdier, som vi håndterte med IS NULL eller COALESCE.

---

## Del 6: Bonusoppgaver (Valgfri)

### Oppgave 6.1: Trigger for lagerbeholdning

**SQL for trigger:**

```sql
[Skriv din SQL-kode for trigger her, hvis du har løst denne oppgaven]
```

**Forklaring:**

[Skriv ditt svar her - forklar hvordan triggeren fungerer]

**Testing:**

[Skriv ditt svar her - vis hvordan du har testet at triggeren fungerer som forventet]

---

### Oppgave 6.2: Presentasjon

**Lenke til presentasjon:**

[Legg inn lenke til video eller presentasjonsfiler her, hvis du har løst denne oppgaven]

**Hovedpunkter i presentasjonen:**

[Skriv ditt svar her - oppsummer de viktigste punktene du dekket i presentasjonen]

---

**Slutt på besvarelse**
