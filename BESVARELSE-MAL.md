# Besvarelse - Refleksjon og Analyse

**Student:** [Warda Khalid Rajput]

**Studentnummer:** [376367]

**Dato:** [01.03.2026]

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**

Kunde
Sykkel
Sykkelstasjon
Lås
Utleie

**Attributter for hver entitet:**

Kunde: mobilnummer, epost, fornavn, etternavn
Sykkel: sykkel-ID, stasjon-ID, lås-ID
Sykkelstasjon: stasjon-ID, navn, adresse
Lås: lås-ID, stasjon-ID
Utleie: utleie-ID, kunde-ID, sykkel-ID, utlevert-tidspunkt, innlevert-tidspunkt, leiebeløp

---

### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

Kunde:
mobilnummer → VARCHAR(15) (holder norske mobilnummer)
epost → VARCHAR(255) (holder epost)
fornavn, etternavn → VARCHAR(100)


Sykkel:
sykkel_id → SERIAL (unik ID)
stasjon_id, laas_id → INT (fremmednøkkel)
Sykkelstasjon:
stasjon_id → SERIAL
navn, adresse → VARCHAR(255)


Lås:
laas_id → SERIAL
stasjon_id → INT


Utleie:
utleie_id → SERIAL
kunde_id, sykkel_id → INT
utlevert_tidspunkt, innlevert_tidspunkt → TIMESTAMP
leiebelop → NUMERIC(10,2)


**`CHECK`-constraints:**

mobilnummer → CHECK (mobilnummer ~ '^[0-9]{8}$')
Sikrer at mobilnummer har 8 siffer.
epost → CHECK (epost ~ '^[^@]+@[^@]+\.[^@]+$')
Sikrer at epost har riktig format.
leiebelop → CHECK (leiebelop >= 0)
Sikrer at leiebeløp ikke er negativt.

**ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.3: Primærnøkler

**Valgte primærnøkler og begrunnelser:**

Kunde: kunde_id → unik identifikator for hver kunde
Sykkel: sykkel_id → unik ID for hver sykkel
Sykkelstasjon: stasjon_id → unik ID for hver stasjon
Lås: laas_id → unik ID for hver lås
Utleie: utleie_id → unik ID for hver utleie


**Naturlige vs. surrogatnøkler:**

Vi har brukt surrogatnøkler (SERIAL ID-er) for alle tabeller.
det er lettere å håndtere, unngår problemer med naturlige attributter som kan endres (f.eks. navn, mobilnummer).

**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

Kunde – Utleie: én kunde kan ha mange utleier → 1:N
Sykkel – Utleie: én sykkel kan ha mange utleier over tid → 1:N
Stasjon – Sykkel: én stasjon kan ha mange sykler → 1:N
Stasjon – Lås: én stasjon kan ha mange låser → 1:N
Lås – Sykkel: én lås kan brukes av én sykkel om gangen → 1:1


**Fremmednøkler:**

utleie.kunde_id → peker til kunde.kunde_id
utleie.sykkel_id → peker til sykkel.sykkel_id
sykkel.stasjon_id → peker til stasjon.stasjon_id
sykkel.laas_id → peker til laas.laas_id
laas.stasjon_id → peker til stasjon.stasjon_id

**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

Datamodellen tilfredsstiller 1NF fordi alle kolonner har enkle (atomære) verdier, og hver rad har en unik primærnøkkel.

**Vurdering av 2. normalform (2NF):**

Modellen tilfredsstiller 2NF fordi alle ikke-nøkkelattributter er fullstendig avhengige av primærnøkkelen i sin tabell

**Vurdering av 3. normalform (3NF):**

Modellen tilfredsstiller 3NF fordi ingen ikke-nøkkelattributter avhenger av andre ikke-nøkkelattributter.

**Eventuelle justeringer:**

ingen store justeringer trengs, modellen er allerede på 3NF.

---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

Skriptet er lagt i: init-scripts/01-init-database.sql

**Antall testdata:**

- Kunder: [2]
- Sykler: [4]
- Sykkelstasjoner: [2]
- Låser: [4]
- Utleier: [2]

---

### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**

[Skriv ditt svar her - f.eks. skjermbilder eller output fra terminalen som viser at databasen ble opprettet uten feil]

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
Resultatet viser at alle tabellene ble opprettet, f.eks.:
kunde
laas
stasjon
sykkel
utleie

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql
CREATE ROLE kunde;
```

**SQL for å opprette bruker:**

```sql
CREATE USER kunde_1 WITH PASSWORD 'passord123';
GRANT kunde TO kunde_1;
```

**SQL for å tildele rettigheter:**

```sql
GRANT SELECT, INSERT, UPDATE ON kunde TO kunde;
GRANT SELECT, INSERT, UPDATE ON sykkel TO kunde;
GRANT SELECT, INSERT, UPDATE ON utleie TO kunde;
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
CREATE VIEW kunde_utleie_view AS
SELECT u.utleie_id, u.sykkel_id, u.utlevert_tidspunkt, u.innlevert_tidspunkt, u.leiebelop
FROM utleie u
JOIN kunde k ON u.kunde_id = k.kunde_id
WHERE k.kunde_id = current_setting('app.current_kunde')::int;
```

**Ulempe med VIEW vs. POLICIES:**

- VIEW filtrerer bare hva man ser, men brukeren kan fortsatt prøve å oppdatere andre tabeller hvis rettigheter ikke er strengt satt.

- POLICIES (Row-Level Security) sikrer på databasenivå at kunden aldri får tilgang til andres data, uansett hvilken spørring som kjøres.

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

Høysesong (5 måneder × 20 000) = 100 000
Mellomsesong (4 måneder × 5 000) = 20 000
Lavsesong (3 måneder × 500) = 1 500

Totalt: 100 000 + 20 000 + 1 500 = 121 500 utleier per år 

**Estimat for lagringskapasitet:**

Kunde: 2–10 KB per rad × antall kunder (liten)
Sykkel: 1–2 KB per rad × antall sykler (få rader)
Sykkelstasjon: 1 KB per rad × antall stasjoner (svært liten)
Lås: 1 KB per rad × antall låser (svært liten)
Utleie: 1–2 KB per rad × 121 500 utleier ≈ 150–250 MB

**Totalt for første år:**

Mest plass går til utleie-tabellen, ca. 150–250 MB.

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

I CSV-filen gjentas kundeinformasjon for hver utleie.

**Problem 2: Inkonsistens**

Hvis et mobilnummer eller navn endres i én rad, men ikke i andre, blir data inkonsistente.

**Problem 3: Oppdateringsanomalier**

Slette-anomali: Sletter man siste utleie for en kunde, mister man også kundeinfo.
Innsettings-anomali: Kan ikke legge inn ny kunde uten utleie.
Oppdaterings-anomali: Må oppdatere samme informasjon på flere rader.
**Fordeler med en indeks:**

Gjør søk raskere, spesielt når man leter etter spesifikke kunder eller utleier.

**Case 1: Indeks passer i RAM**

Hele indeksen ligger i minnet → spørringer går svært raskt.

**Case 2: Indeks passer ikke i RAM**

Indeksen deles opp og flettesorteres fra disk → litt tregere, men fortsatt effektivt.

**Datastrukturer i DBMS:**

[Skriv ditt svar her - diskuter B+-tre og hash-indekser]

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

LSM-tree (Log-Structured Merge Tree)

**Begrunnelse:**

**Skrive-operasjoner:**
Nye logger skrives først til minnebuffer, deretter batch-lagres til disk → veldig raskt for mange innskrivinger.

**Lese-operasjoner:**

Når man leser sjeldent, slår systemet sammen data fra minne og disk → fortsatt effektivt, men litt tregere enn ved hyppige lesinger.

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

Best å gjøre validering i alle lag: nettleser, applikasjon og database.

**Validering i nettleseren:**

Fordel: rask tilbakemelding til brukeren.
Ulempe: kan omgås av brukeren → ikke sikkerhet alene

**Validering i applikasjonslaget:**

Fordel: sentral kontroll av regler og logikk.
Ulempe: må alltid sjekkes for hver operasjon → kan gi ekstra arbeid.

**Validering i databasen:**

Fordel: sikrer data på laveste nivå, uansett hvem som skriver til databasen.
Ulempe: mindre fleksibelt og kan være tregere for enkelte sjekker.

**Konklusjon:**

Validering bør gjøres i alle lag samtidig:
Nettleser → brukervennlighet
Applikasjon → forretningslogikk
Database → sikkerhet og dataintegritet

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

Jeg har lært om datamodellering, normalisering, SQL, roller og rettigheter, indekser og RLS. Jeg forstår bedre hvordan en database bygges og holdes ryddig.

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

Oppgaven har hjulpet meg å sette teori ut i praksis.
Jeg har øvd på å lage tabeller, relasjoner, constraints og tester, som er sentrale læringsmål.

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

Å lage et godt ER-diagram med riktige fremmednøkler.
Å forstå hvordan roller, rettigheter og RLS fungerer i praksis.

**Hva har du lært om databasedesign:**

Viktigheten av normalisering og å planlegge tabeller før man lager databasen.
---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

SQL-spørringene ligger i test-scripts/queries.sql


**Eventuelle feil og rettelser:**

Feil oppstod ofte pga. feil tabell- eller kolonnenavn.
Rettet ved å korrigere navnene i spørringene slik at de matcher databasen.

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
