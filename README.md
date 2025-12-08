# NovinskiPortal

NovinskiPortal je informacioni sistem za online novinski portal koji omogućava upravljanje člancima, kategorijama i potkategorijama, statistikom čitanosti, komentarima, favoritima i prijavama vijesti.
Sistem obuhvata desktop administratorsku aplikaciju, mobilnu korisničku aplikaciju i backend razvijen u ASP.NET Core.

---

## Upute za pokretanje

### Backend (API + Worker + SQL + RabbitMQ)

1. Klonirati repozitorij `NovinskiPortal`.
2. Provjeriti da su instalirani:
   - Docker Desktop
   - Docker Compose
3. U root folderu rješenja, gdje se nalazi `docker-compose.yml`, otvoriti terminal i pokrenuti:

   ```bash
   docker compose up --build
   ```

Docker će pokrenuti sljedeće servise:

- `db` – SQL Server
- `rabbitmq` – RabbitMQ message broker
- `api` – `NovinskiPortal.API` (glavni Web API)
- `worker` – `NovinskiPortal.Workers.Statistics` (background worker za statistiku čitanosti)

Pri prvom pokretanju:

- automatski se izvršavaju EF Core migracije
- kreira se baza i seedaju početni podaci (kategorije, korisnici, test članci)

API je dostupan na:

- računaru: `http://localhost:5000`
- Android emulatoru (AVD): `http://10.0.2.2:5000`

---

## Pristup bazi (SQL Server)

SQL Server radi u Docker kontejneru.

Parametri za spajanje iz SQL Server Management Studio:

- Server: `localhost,1433`
- Authentication: `SQL Server Authentication`
- Login: `sa`
- Password: `NovinskiPortal2025`
- Naziv baze: `Database=210053`

---

## Frontend aplikacije

Nakon ekstrakcije arhive `fit-build-2025-12-08.zip` dobiju se dva foldera: `Release` i `flutter-apk`.

### Desktop aplikacija (admin)

U folderu `Release` pokrenuti:

- `novinskiportal_desktop.exe`

Desktop aplikacija je namijenjena administratorima i urednicima portala,
upravljanju člancima, kategorijama, korisnicima, dashboardom i izvještajima.

### Mobilna aplikacija (krajnji korisnici)

U folderu `flutter-apk` nalazi se:

- `app-release.apk`

Potrebno je:

1. Prenijeti `app-release.apk` na Android emulator.
2. Deinstalirati staru verziju aplikacije ako je već instalirana.
3. Instalirati novu verziju i pokrenuti aplikaciju.

Mobilna aplikacija koristi adresu API-ja:

- na emulatoru: `http://10.0.2.2:5000`

---

## Test korisnici

Za potrebe testiranja postoje tri korisnika:

### Desktop (admin / urednik)

Koristi se u desktop aplikaciji.

- Username: `desktop`
- Lozinka: `test`

### Mobilni korisnici

Koriste se u mobilnoj aplikaciji.

Korisnik 1:

- Username: `mobile`
- Lozinka: `test`

Korisnik 2 (za testiranje komentarisanja, lajkova i interakcija):

- Username: `mobile2`
- Lozinka: `test`

Konkretni korisnici i njihove role definisani su u seed podacima (`DbSeeder.SeedAsync`).

---

## Mikroservisne funkcionalnosti

Sistem koristi RabbitMQ i odvojeni worker servis za asinhrone zadatke:

- **NovinskiPortal.API**
  - šalje poruke u RabbitMQ kada se članak pročita
  - koristi te podatke za statistiku i personalizovane preporuke

- **NovinskiPortal.Workers.Statistics**
  - sluša poruke iz RabbitMQ-a
  - upisuje statistiku čitanosti u bazu (ArticleStatistics, logovi pregleda)
  - omogućava generisanje dashboarda i izvještaja
    (najčitaniji članci, pregledi po kategorijama itd.)

Na ovaj način ispunjen je zahtjev mikroservisne arhitekture:
- glavni API servis
- pomoćni worker servis u posebnom kontejneru
- RabbitMQ kao message broker.

---

## Tehnologije

**Backend:**

- ASP.NET Core (.NET 8, C#)
- Entity Framework Core (Code First, migracije, seeding)
- JWT autentifikacija i autorizacija
- Mapster za mapiranje entiteta u DTO-ove
- QuestPDF za generisanje PDF izvještaja

**Mikroservisi:**

- RabbitMQ (message broker)
- `NovinskiPortal.Workers.Statistics` (background worker)

**Frontend:**

- Flutter desktop aplikacija (`novinskiportal_desktop`) – administracija portala
- Flutter mobilna aplikacija (`novinskiportal_mobile`) – krajnji korisnici

**Baza podataka:**

- SQL Server (u Docker kontejneru)

**Containerization:**

- Docker
- Docker Compose (API, worker, SQL Server i RabbitMQ u jednoj mreži)

---

📌 Projekat je razvijen u sklopu predmeta Razvoj softvera 2 na Fakultetu informacijskih tehnologija Mostar.
