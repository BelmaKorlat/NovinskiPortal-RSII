using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Commom.PasswordService;
using Microsoft.Extensions.DependencyInjection;
using NovinskiPortal.Services.Database.Entities;

namespace NovinskiPortal.Services.Seeding
{
    public static class DbSeeder
    {
        public static async Task SeedAsync(IServiceProvider services)
        {
            using var scope = services.CreateScope();
            var provider = scope.ServiceProvider;

            var context = provider.GetRequiredService<NovinskiPortalDbContext>();
            var passwordService = provider.GetRequiredService<IPasswordService>();

            await context.Database.MigrateAsync();

            await SeedCategoriesAsync(context);
            await SeedSubcategoriesAsync(context);
            await SeedUsersAsync(context, passwordService);
            await SeedArticlesAsync(context);
            await SeedArticlePhotosAsync(context);
        }

        private static async Task SeedCategoriesAsync(NovinskiPortalDbContext context)
        {
            if (await context.Categories.AnyAsync())
                return;

            var categories = new List<Category>
        {
            new Category
            {
                Name = "Vijesti",
                OrdinalNumber = 1,
                Color = "#3E77E8",
                Active = true
            },
            new Category
            {
                Name = "Sport",
                OrdinalNumber = 2,
                Color = "#2BE853",
                Active = true
            },
            new Category
            {
                Name = "Biznis",
                OrdinalNumber = 3,
                Color = "#FBC02D",
                Active = true
            },
            new Category
            {
                Name = "Lifestyle",
                OrdinalNumber = 4,
                Color = "#DD47EA",
                Active = true
            },

            new Category
            {
                Name = "Scitech",
                OrdinalNumber = 5,
                Color = "#50B5EA",
                Active = true
            }
        };

            await context.Categories.AddRangeAsync(categories);
            await context.SaveChangesAsync();
        }

        private static async Task SeedSubcategoriesAsync(NovinskiPortalDbContext context)
        {
            if (await context.Subcategories.AnyAsync())
                return;

            var vijesti = await context.Categories.FirstAsync(c => c.Name == "Vijesti");
            var sport = await context.Categories.FirstAsync(c => c.Name == "Sport");
            var biznis = await context.Categories.FirstAsync(c => c.Name == "Biznis");
            var lifestyle = await context.Categories.FirstAsync(c => c.Name == "Lifestyle");
            var scitech = await context.Categories.FirstAsync(c => c.Name == "Scitech");

            var subs = new List<Subcategory>
        {
            new Subcategory
            {
                Name = "BiH",
                OrdinalNumber = 1,
                Active = true,
                CategoryId = vijesti.Id
            },
            new Subcategory
            {
                Name = "Svijet",
                OrdinalNumber = 2,
                Active = true,
                CategoryId = vijesti.Id
            },
            new Subcategory
            {
                Name = "Fudbal",
                OrdinalNumber = 1,
                Active = true,
                CategoryId = sport.Id
            },
            new Subcategory
            {
                Name = "Košarka",
                OrdinalNumber = 2,
                Active = true,
                CategoryId = sport.Id
            },
            new Subcategory
            {
                Name = "Privreda",
                OrdinalNumber = 1,
                Active = true,
                CategoryId = biznis.Id
            },
            new Subcategory
            {
                Name = "Tehnologija",
                OrdinalNumber = 2,
                Active = true,
                CategoryId = scitech.Id
            },
            new Subcategory
            {
                Name = "Nauka",
                OrdinalNumber = 2,
                Active = true,
                CategoryId = scitech.Id
            },
            new Subcategory
            {
                Name = "Zdravlje",
                OrdinalNumber = 1,
                Active = true,
                CategoryId = lifestyle.Id
            },
            new Subcategory
            {
                Name = "Putovanja",
                OrdinalNumber = 2,
                Active = true,
                CategoryId = lifestyle.Id
            }
        };

            await context.Subcategories.AddRangeAsync(subs);
            await context.SaveChangesAsync();
        }

        private static async Task SeedUsersAsync(
            NovinskiPortalDbContext context,
            IPasswordService passwordService)
        {
            if (await context.Users.AnyAsync())
                return;

            var now = DateTime.UtcNow;

            const string initialPassword = "test";

            var adminSalt = passwordService.GenerateSalt();
            var adminHash = passwordService.HashPassword(initialPassword, adminSalt);

            var admin = new User
            {
                FirstName = "Desktop",
                LastName = "User",
                Nick = "Admin",
                Username = "desktop",
                Email = "desktop.user@novinskiportal.ba",
                PasswordSalt = adminSalt,
                PasswordHash = adminHash,
                RoleId = 1,
                Active = true,
                CreatedAt = now,
                IsDeleted = false,
                LastLoginAt = null,
                CommentBanReason = null,
                CommentBanUntil = null
            };

            var user1Salt = passwordService.GenerateSalt();
            var user1Hash = passwordService.HashPassword(initialPassword, user1Salt);

            var user1 = new User
            {
                FirstName = "Mobile",
                LastName = "User",
                Nick = "M.U.",
                Username = "mobile",
                Email = "mobile.user@novinskiportal.ba",
                PasswordSalt = user1Salt,
                PasswordHash = user1Hash,
                RoleId = 2,
                Active = true,
                CreatedAt = now,
                IsDeleted = false,
                LastLoginAt = null,
                CommentBanReason = null,
                CommentBanUntil = null
            };

            var user2Salt = passwordService.GenerateSalt();
            var user2Hash = passwordService.HashPassword(initialPassword, user2Salt);

            var user2 = new User
            {
                FirstName = "Mobile",
                LastName = "User 2",
                Nick = "M.U.",
                Username = "mobile2",
                Email = "mobile.user2@novinskiportal.ba",
                PasswordSalt = user2Salt,
                PasswordHash = user2Hash,
                RoleId = 2,
                Active = true,
                CreatedAt = now,
                IsDeleted = false,
                LastLoginAt = null,
                CommentBanReason = null,
                CommentBanUntil = null
            };

            await context.Users.AddRangeAsync(admin, user1, user2);
            await context.SaveChangesAsync();
        }

        private static async Task SeedArticlesAsync(NovinskiPortalDbContext context)
        {
            if (await context.Articles.AnyAsync())
                return;

            var now = DateTime.UtcNow;

            var vijesti = await context.Categories.FirstAsync(c => c.Name == "Vijesti");
            var sport = await context.Categories.FirstAsync(c => c.Name == "Sport");
            var biznis = await context.Categories.FirstAsync(c => c.Name == "Biznis");
            var lifestyle = await context.Categories.FirstAsync(c => c.Name == "Lifestyle");
            var scitech = await context.Categories.FirstAsync(c => c.Name == "Scitech");

            var bih = await context.Subcategories.FirstAsync(s => s.Name == "BiH");
            var svijet = await context.Subcategories.FirstAsync(s => s.Name == "Svijet");
            var fudbal = await context.Subcategories.FirstAsync(s => s.Name == "Fudbal");
            var košarka = await context.Subcategories.FirstAsync(s => s.Name == "Košarka");
            var privreda = await context.Subcategories.FirstAsync(s => s.Name == "Privreda");
            var tehnologija = await context.Subcategories.FirstAsync(s => s.Name == "Tehnologija");
            var nauka = await context.Subcategories.FirstAsync(s => s.Name == "Nauka");
            var zdravlje = await context.Subcategories.FirstAsync(s => s.Name == "Zdravlje");
            var putovanja = await context.Subcategories.FirstAsync(s => s.Name == "Putovanja");

            var admin = await context.Users.FirstAsync(u => u.Username == "desktop");

            var articles = new List<Article>
        {
            new Article
            {
                Headline = "Nova sezona, stari problemi: Dio Tuzle ponovo bez grijanja",
                Subheadline = "Građani ogorčeni",
                ShortText = "Nova sezona daljinskog grijanja na području Tuzle sa sobom je donijela stare probleme te se unazad mjesec dana izuzetno često bilježe prekidi u snabdijevanju toplinskom energijom. Ranija obećanja nadležnih su suprotna od realne slike, na što su ukazali građani.",
                Text = "Stanovnici prigradskog naselja Šićki Brod ovaj petak provode uz hladne radijatore, s obzirom da je ponovo uslijedio prekid u snabdijevanju toplinskom energijom." +
                "Naime, Centralno grijanje d.d. Tuzla obavijestilo je korisnike da je zbog kvara na vrelovodnoj mreži prema Lukavci došlo do prekida u isporuci toplinske energije za naselje Šićki Brod." +
                "Ekipe preduzeća su na terenu i rade na pripremi sistema kako bi se nakon saniranja kvara u što kraćem roku uspostavila redovna isporuka. Korisnici će biti blagovremeno informirani o svim promjenama putem službene stranice\", kazali su iz Centralnog grijanja." +
                "Građane su pozvali na strpljenje uz poruku da se kvar otklanja u najkraćem mogućem roku. Međutim, građani tokom ovoga dana iskazuju svoje nezadovoljstvo, navodeći da se dosadašnji dio sezone pokazao kao i ona prethodna, u kojoj su im nerijetko bivali prekidi u isporuci toplinske energije.",
                CreatedAt = now.AddDays(-15),
                PublishedAt = now.AddDays(-15),
                Active = true,
                MainPhotoPath = "/Photos/article-1-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Goražde: Stari pješački most u Vitkovićima \"visi o koncu\", podloga je nestabilna",
                Subheadline = "Katastrofalno stanje",
                ShortText = "Stari pješački most u Vitkovićima, nekada ponos radnika Azotare i simbol života ovog dijela Goražda, nalazi se u katastrofalnom stanju.",
                Text = "ako je inspekcija zvanično zabranila prelazak, a znak \"zabranjen prolaz pješacima\" postavljen na ulazu, stanovnici ga i dalje svakodnevno koriste na vlastitu odgovornost.\r\n\r\nMost je, prema dojavama mještana, već dugo u lošem stanju." +
                "Drvene daske su popucale, podloga je nestabilna, a metalna konstrukcija načeta vremenom i vlagom. No, to nije spriječilo ljude da preko njega pređu do imanja, izvora pitke vode, da ga koriste tokom šetnje ili za ribolov." +
                "Iz Savjeta Mjesne zajednice Vitkovići poručuju da su na vrijeme alarmirali nadležne.\r\n\r\n\"Reagovali smo i sve što smo dobili je da je most zatvoren. I dalje niko ništa ne rješava\", kaže Elvir Forto, predsjednik Savjeta MZ Vitkovići." +
                "Dodaje da postavljeni znak i traka nisu dovoljni.\r\n\r\n\"Treba ga fizički zatvoriti dok se ne steknu uslovi za potpunu rekonstrukciju, kako ne bi bilo neželjenih dešavanja\", ističe Forto." +
                "Most je, podsjeća, star više od 70 godina i trebao bi ozbiljniju, željeznu rekonstrukciju, a ne samo zamjenu dasaka. Sličnog mišljenja je i Sedin Jusufović, predsjednik Savjeta MZ Zupčići. Napominje da je most za ovo područje vrijedan i znači više od same prečice do odredišta." +
                "\"Treba prvo stručno mišljenje o nosivosti, ali i početi s rekonstrukcijom što prije. Potreba je ogromna, ljudi tu šetaju, dolaze po vodu, obrađuju vrtove. Most je dio našeg svakodnevnog života\", kaže Jusufović." +
                "U nedostatku bilo kakvih rješenja građani i dalje prelaze most, često i djeca, što dodatno brine mještane." +
                "\"Znak zabrane prelaska postavljen je kao formalno upozorenje, ali ne predstavlja nikakvu stvarnu zaštitu, posebno ne za djecu. Svi znamo koliko su djeca radoznala i sklona dokazivanju hrabrosti. Most svakodnevno koriste sportski ribolovci, omladina, rekreativci i komšije sa obje strane Drine. Moj dojam je da je znak postavljen prvenstveno da bi se nadležne institucije 'ogradile' u slučaju eventualne nesreće\", kaže Esma Drkenda jedna od stanovnica Vitkovića." +
                "Ona podsjeća da je i u vrijeme rata most bio \"linija spasa\" za stanovnike Zupčića što mu daje dodatnu vrijednost, simboličku i historijsku." +
                "\"Možda našim političarima ne znači mnogo, ali nama je dio života. U ratu su ljudi preko njega bježali od smrti. Niti jedan novi, moderni most pa ni onaj izgrađen oko kilometar uzvodno, ne može zamijeniti ono što ovaj most predstavlja.Umjesto prijedloga da se most potpuno zatvori, rješenje treba biti suprotno, možda privremeno zatvoriti i iskoristiti vrijeme da se pronađu donatori i stručnjaci koji će omogućiti sanaciju. Umjesto dotrajalih dasaka, mogle bi se postaviti željezne ploče sa šarom, naravno uz stručni nadzor i preciznu procjenu stanja konstrukcije. Vjerujem da bi se u industrijskoj zoni Vitkovići pronašlo zainteresovanih donatora, ali i u Ministarstvu za urbanizam, prostorno uređenje i zaštitu okoline BPK Goražde, te među brojnim međunarodnim organizacijama\", zaključuje Drkenda." ,
                CreatedAt =  now.AddDays(-14),
                PublishedAt =  now.AddDays(-14),
                Active = true,
                MainPhotoPath = "/Photos/article-2-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Islamska zajednica u BiH: Pokrenuta je sistematska islamofobična kampanja, targetiraju se Bošnjaci",
                Subheadline = "U javnim nastupima",
                ShortText = "Islamska zajednica u Bosni i Hercegovini izdala je saopćenje u kojem, kako kažu, upozoravaju domaću i međunarodnu javnost da je u posljednjim danima očito pokrenuta sistematska islamofobična kampanja kojom se targetiraju Bošnjaci i Bosna i Hercegovina.",
                Text = "\"U javnim nastupima radikalno desničarskih političara iz domovine, okruženja i svijeta te kvazinaučnim tekstovima pokušava se iskonstruisati imaginarna 'islamska opasnost', a samo zbog činjenice da se znatan dio građana Bosne i Hercegovine izjašnjavaju kao muslimani. Islam u političkom, javnom i kulturnom životu Bošnjaka, pa time i Bosne i Hercegovine, ima onu ulogu koju kršćanstvo u svojim različitim sljedbama, uz manje posebnosti, ima kod drugih bosanskohercegovačkih naroda, ali i u drugim regionalnim i evropskim sekularnim državama i društvima\", navodi se u saopćenju Ureda za odnose s javnošću Rijaseta Islamske zajednice u BiH." +
                "Dodaje kako je sramotno danas za \"demografski oportunizam\" optuživati narod koji je preživio genocid i koji je više od četiri godine bio izložen sistematskim i organizovanim zločinima istrebljenja i čija biološka supstanca je uništena na velikom dijelu zemlje u kojoj je stoljećima živio.",
                CreatedAt = now.AddDays(-14),
                PublishedAt = now.AddDays(-14),
                Active = true,
                MainPhotoPath = "/Photos/article-3-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Udruženje \"Daun sindrom centar\" Banja Luka posthumno uručilo zahvalnicu Halidu Bešliću",
                Subheadline = "Objavio Đajić",
                ShortText = "Bivši direktor Univerzitetskog kliničkog centra Republike Srpske (UKC RS) Vlado Đajić naveo je da će posebnu zahvalnicu povodom 15 godina od osnivanja Udruženja \"Daun sindrom centar\" Banja Luka posthumno dobiti Halid Bešlić.",
                Text = "Kako je naveo Đajić, priznanje će biti uručeno Halidovom sinu Dini, koji zbog ranije preuzetih obaveza nije mogao prisustvovati obilježavanju velikog jubileja, ali je, kako je naveo, obećao da će u narednom periodu doći u Banja Luku.\r\n\r\n\"Želim još jednom da se prisjetimo posebne slike 'Drvo života', koju su mu izradili moji drugari iz Daun sindrom centra, a koju je Halid čuvao do posljednjeg dana u bolesničkoj sobi. Sa posebnim emocijama prisjećamo se i jedne od naših posljednjih prepiski, koje danas imaju još veću težinu. Počivaj u miru, prijatelju. Tvoje pjesme, tvoja dobrota i tvoj duh živjeće zauvijek sa nama\", naveo je Đajić.\r\n\r\n" +
                "Udruženje \"Daun sindrom centar\" Banja Luka osnovano je 2010. godine, a Đajić je dugogodišnji saradnik Udruženja i njihov ambasador." +
                "Halid Bešlić je preminuo 7. oktobra u 72. godini nakon kratke borbe s teškom bolešću.",
                CreatedAt = now.AddDays(-10),
                PublishedAt = now.AddDays(-10),
                Active = true,
                MainPhotoPath = "/Photos/article-4-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Novi incident u Louvreu: Oštećeno oko 400 rijetkih knjiga, otkriveni i novi propusti u muzeju",
                Subheadline = "Francuska",
                ShortText = "U najpoznatijem muzeju na svijetu, Louvreu, dogodio se novi incident nakon smjele pljačke dragulja koja je otkrila sigurnosne propuste.",
                Text = "Naime, otkriveno je da je prošlog mjeseca curenje vode oštetilo stotine knjiga u odjelu za egipatske starine u ovom pariškom muzeju, što je ukazalo na nove probleme u održavanju najposjećenijeg muzeja na svijetu." +
                "Prema web stranici La Tribune de l'Art, pogođeno je oko 400 rijetkih knjiga zbog lošeg stanja cijevi, dok odjel već godinama traži sredstva za zaštitu kolekcije." +
                "Zamjenik administratora Louvrea, Francis Steinbock, rekao je za BFM TV da je curenje zahvatilo jednu od tri prostorije biblioteke i da su oštećena djela uglavnom ona koja koriste egiptolozi, dok dragocjene knjige nisu pogođene." +
                "Popravke su planirane za septembar 2026. godine.\r\n\r\nOvaj incident dolazi samo nekoliko sedmica nakon velike pljačke dragulja u muzeju u oktobru, kada su četvorica provalnika ukrala dragulje vrijedne 102 miliona dolara, otkrivajući ozbiljne sigurnosne propuste." +
                "Iako je nekoliko osoba uhapšeno u toku istrage o čuvenoj pljački, nakit još uvijek nije pronađen." +
                "U novembru su strukturne slabosti dovele i do djelomičnog zatvaranja galerije s grčkim vazama.",
                CreatedAt = now.AddHours(-6),
                PublishedAt = now.AddHours(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-5-main.jpg",
                HideFullName = false,
                BreakingNews = true,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = svijet.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Amerikanci tvrde da je mir u Ukrajini vrlo blizu, ostala da se riješe još dva pitanja",
                Subheadline = "Dogovor na pomolu",
                ShortText = "Odlazeći izaslanik američkog predsjednika za Ukrajinu Keith Kellogg izjavio je da su pregovarači \"vrlo blizu\" postizanju dogovora o okončanju rata u Ukrajini.\r\n",
                Text = "Prema njegovim riječima, ostalo je riješiti samo dva preostala pitanja, a to su budućnost Donbasa i Zaporiške nuklearne elektrane. Kazao je to u subotu na Reaganovom odbrambenom forumu, prenosi agencija Reuters." +
                "\"Ako uspijemo riješiti ova dva pitanja, mislim da će ostale stvari funkcionirati sasvim dobro\", naveo je Kellogg." +
                "\"Već smo skoro tamo. Stvarno, stvarno smo blizu\", naglasio je. Pregovore o američkom mirovnom planu uporedio je s trkom, uz napomenu da se trenutno nalaze u posljednjih deset metara te trke, koji su, prema njegovim riječima, uvijek najteži." +
                "Rusija trenutno okupira skoro petinu ukrajinske teritorije, uključujući cijelu Lugansku oblast i veliki dio Donjecke oblasti, koje zajedno čine Donbas. Rusija diplomatsko rješenje sukoba uslovljava povlačenjem Ukrajinaca iz tog regiona." +
                "Sjedinjene Američke Države u svom mirovnom planu predložile su Ukrajini da Rusiji preda teritorije koje trenutno nisu pod njenom kontrolom, kao i ostatak Donbasa. Dio Donjecke oblasti iz kojeg bi se Ukrajina povukla postao bi demilitarizirana zona." +
                "Rusija od početka sveobuhvatne invazije na Ukrajinu okupira i Zaporišku nuklearnu elektranu.",
                CreatedAt = now.AddDays(-10),
                PublishedAt = now.AddDays(-10),
                Active = true,
                MainPhotoPath = "/Photos/article-6-main.png",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = svijet.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Da li je IDDEEA pred finansijskim kolapsom: \"Ako državi ne trebaju lični dokumenti, to nije naša odluka\"",
                Subheadline = "Ko je izmijenio stavku?",
                ShortText = "Agencija za identifikacione dokumente, evidenciju i razmjenu podataka Bosne i Hercegovine (IDDEEA) je u usvojenom budžetu za 2025. godinu dobila sredstva umanjena za 4,64 miliona KM u odnosu na prethodni budžet.",
                Text = "Iz ove agencije su se oglasili te poručili da su kao budžetski korisnik uredno i pravovremeno dostavili Ministarstvu finansija i trezora Bosne i Hercegovine svoj prijedlog budžeta koji je zasnovan na stvarnoj potrošnji, važećim ugovorima i obavezama prema građanima i institucijama." +
                "Kroz dalji proces izrade i usvajanja budžeta, koji uključuje više institucija državnog nivoa, došlo je do izmjena i umanjenja pojedinih budžetskih stavki, navodi IDDEEA te dodaju da nemaju uvid u to u kojoj fazi i od koje institucije su te izmjene izvršene." +
                "\"Zbog toga je, u trenutku konačnog usvajanja budžeta, IDDEEA već bila dovedena u finansijski minus. Agencija ne donosi budžet i ne može mijenjati odluke koje su joj nametnute, niti utječe na odluke tijela nadležnih za budžetski proces. Kako bismo osigurali minimalne uslove za funkcionisanje, IDDEEA je već podnijela zahtjev za restrukturiranje vlastitog budžeta, kao i zahtjev za odvajanje dodatnih sredstava iz budžetske rezerve BiH. Time je Agencija iscrpila sve mogućnosti koje joj zakon daje. Dalje odluke su u isključivoj nadležnosti Vijeća ministara BiH\", saopćeno je." +
                "Smatraju da će doći u situaciju da neće biti moguće pravovremeno izmiriti obaveze prema dobavljačima, iako je IDDEEA u potpunosti izvršila sve svoje obaveze kao \"posljedica nametnutog budžetskog okvira\"." +
                "\"Ako neko smatra da državi više nisu potrebni lični dokumenti, pasoši, registarske tablice, vozačke dozvole ili održavanje informacionih mreža, onda je to odluka institucija koje kreiraju i usvajaju budžet, a ne Agencije. Stoga, ovaj problem nije problem IDDEEA-e, nego problem budžetskog planiranja na nivou države. Posljedice takvih odluka direktno pogađaju građane BiH i sve institucije kojima IDDEEA pruža usluge. Istovremeno, želimo jasno poručiti da IDDEEA neće preduzimati ništa što je izvan zakonskih ovlaštenja. Postupaćemo isključivo u skladu sa zakonom i po instrukcijama Vijeća ministara BiH, koje je odgovorno za kreiranje finansijskog i operativnog okvira u kojem Agencija radi\", navode." +
                "Kažu da će i dalje profesionalno obavljati sve poslove iz svoje nadležnosti, ali i da građani i institucije moraju znati da Agencija snosi posljedice budžeta koji joj je dodijeljen, a ne onog koji je tražila i jasno obrazložila." +
                "\"Još jednom naglašavamo da je IDDEEA svoj zakonski posao obavila: prijedlog budžeta smo dostavili Ministarstvu finansija BiH u skladu sa svim procedurama. Ko je, u daljem lancu odlučivanja - Ministarstvo finansija BiH, Vijeće ministara BiH, Predsjedništvo BiH, Predstavnički dom BiH ili Dom naroda BiH, izmijenio te stavke, mi ne znamo\", navode u saopćenju." ,
                CreatedAt = now.AddDays(-10),
                PublishedAt = now.AddDays(-10),
                Active = true,
                MainPhotoPath = "/Photos/article-7-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Čović: Državna imovina je postala prepreka investiranju u BiH, to pitanje treba riješiti",
                Subheadline = "O sjednici s ambasadorima",
                ShortText = "Predsjednik HDZ-a Dragan Čović komentarisao je održanu sjednicu Vijeća za implementaciju mira (PIC) te je ocijenio kako je poslana važna poruka ohrabrenja domaćim akterima da završe svoj dio posla do kraja godine.",
                Text = "Čović je kazao kako vjeruje da će se uprkos različitim pogledima na pojedine zakone, poput Zakona o VSTV-u, Zakona o sudu ili imenovanju pregovarača, ipak postići političko jedinstvo." +
                "\"Nemamo što drugo kazati nego da pokušamo u zajedništvu svu ljepotu naše domovine Bosne i Hercegovine ne razdijeliti između sebe, nego zajednički graditi na evropskom putu integrisanja\", rekao je Čović za RTV HB." +
                "Uvjeren je da će vlast u Bosni i Hercegovini biti, kako kaže, dovoljno mudra da pozitivno odgovori na poziv koji je došao iz Brisela." +
                "Govoreći o državnoj imovini, Čović je stava da je to pitanje postalo dio političkih prijepora, ali i ozbiljna prepreka razvoju." +
                "\"Državnu imovinu treba hitno riješiti. Ona je postala prepreka normalnom investiranju u Bosni i Hercegovini\", kaže Čović." +
                "Pozvao je domaće političare da preuzmu odgovornost i sami donesu potrebne zakone. Ako to ne bude moguće, smatra da oni koji su ranije nametali rješenja trebaju ta rješenja prilagoditi realnim potrebama.\r\n\r\n" +
                "\"Državna imovina ne smije biti prepreka bilo kakvoj javnoj investiciji u Bosni i Hercegovini\", zaključio je Čović.",
                CreatedAt = now.AddHours(-8),
                PublishedAt = now.AddHours(-8),
                Active = true,
                MainPhotoPath = "/Photos/article-8-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Uk: Usvojen je Nacrt zakona o legalizaciji bespravno izgrađenih objekata, pravimo iskorak",
                Subheadline = "Ide u Skupštinu KS",
                ShortText = "Vlada Kantona Sarajevo usvojila je Nacrt zakona o legalizaciji bespravno izgrađenih objekata i uputila ga u skupštinsku proceduru.",
                Text ="Premijer Kantona Sarajevo Nihad Uk kaže da je ovo prvi i ključni korak ka rješenju problema koji decenijama stvara pravnu nesigurnost za hiljade građana.\n\n" +
                "\"Ovaj Nacrt po prvi put donosi jasan, precizan i pravedan pravni okvir za rješavanje statusa objekata izgrađenih bez dozvole ili uz odstupanja od dokumentacije. Naš cilj je omogućiti građanima ono što im pripada: pravnu sigurnost, uredan upis u zemljišne knjige i nesmetano raspolaganje vlastitom imovinom\", kazao je Uk.\n\n" +
                "Dodaje da je Vlada KS svjesna da predstoji još posla te su tokom javne rasprave i skupštinske procedure otvoreni za sve argumentovane prijedloge i konstruktivne korekcije.\n\n" +
                "Šta Nacrt zakona donosi građanima?\n\n" +
                "• Pouzdanu evidenciju stanja u prostoru, uz ortofoto snimanje kompletnog kantona. To je neophodan temelj za sva buduća planiranja, investicije i odgovorno upravljanje prostorom.\n" +
                "• Konačno rješavanje dugogodišnjeg pravnog vakuuma za objekte bez adekvatne dokumentacije.\n" +
                "• Mogućnost priključenja na osnovne komunalne usluge, uključujući i plin (što će doprinijeti smanjenju zagađenja zraka).\n" +
                "• Uklanjanje prepreka za prodaju, nasljeđivanje i upis nekretnina, čime imovina konačno dobija punu pravnu vrijednost.\n",
                CreatedAt = now.AddHours(-8),
                PublishedAt = now.AddHours(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-9-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Sarajevo: Studenti na Bjelavama s porodicama i radnicima održali proteste, ovo su njihovi zahtjevi",
                Subheadline = "Problemi s uslovima",
                ShortText = "Veći broj studenata okupio se večeras ispred Studentskog doma na Bjelavama sa porodicama i radnicima u znak protesta zbog loših uslova u ovoj ustanovi.",
                Text = "Loši uslovi su problem na koji studenti raznih generacija upozoravaju kad je Dom na Bjelavama u pitanju već godinama.\r\n\r\nIpak, situacija je postala daleko ozbiljnija jučer kada je u domu počeo da curi plin. Zbog toga su studenti u srijedu navečer izašli na spontane proteste ispred doma, da bi danas uslijedili nešto brojniji." +
                "Prisutnima se večeras obratio Aldin Mešan, predsjednik Upravnog odbora Udruženja studenata Studentski centar Sarajevo." +
                "\"Večeras smo se okupili u lijepom broju, mnogi su nas podržali. Povodom jučerašnje situacije na Bjelavama, odnosno curenja plina u kotlovnici koja zagrijava samo naselje, to je predstavilo veliku nesigurnost po studente. Upravo je to ono o čemu mi govorimo kroz medije i pričamo nadležnima. Jučerašnja situacija je bila prilika da se konačno situacija riješi do kraja. Mi više nemamo vremena da čekamo obećanja. I ovo današnje obraćanje ministarstva je upravo ono što smo mi slušali i ranije\", rekao je." +
                "Kazao je da studenti imaju deset zahtjeva, a nabrojao je nekoliko ključnih." +
                "\"Poštivanje osnivačkog akta što kulminira svim problemima unutar Studentskog centra, zatim hitnu sanaciju kotlovnice u Studentskom naselju Bjelave. To nije nešto što treba da se planira u budžetu naredne godine, već da se odmah uradi. Jedan od zahtjeva je i sanacija kotlovnice u Studentskom domu Nedžarići. Imamo problem i izostanka direktora same ustanove i nadzornih organa\", rekao je.",
                CreatedAt = now.AddDays(-8),
                PublishedAt = now.AddDays(-8),
                Active = true,
                MainPhotoPath = "/Photos/article-10-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Kolekcija knjiga Jamesa Colliera svečano uručena biblioteci Filozofskog fakulteta u Sarajevu",
                Subheadline = "Vrijedna donacija",
                ShortText = "Biblioteci Univerziteta u Sarajevu - Filozofskog fakulteta danas je svečano uručena značajna kolekcija knjiga iz privatne biblioteke profesora Jamesa Colliera (1943-2015), istaknutog nizozemsko-američkog historičara umjetnosti, umjetnika i pedagoga.",
                Text = "Donacija je ostvarena zahvaljujući inicijativi njegove supruge Carole Anne Collier, a uz podršku prijatelja i institucija iz više zemalja.\r\n\r\nKolekcija teška skoro 900 kilograma transportovana je u 160 kutija iz Amsterdama u Sarajevo uz podršku Ambasade Kraljevine Nizozemske u Bosni i Hercegovini i kontigenta Nizozemske pri misiji Eufor Althea te će od danas krasiti oko 45 metara površine na policama biblioteke." +
                "Primopredaji su, uz Carole Anne Collier, prisustvovali Ambasador Kraljevine Nizozemske u Bosni i Hercegovini Henk van den Dool, prodekanesa za naučnoistraživački rad, međunarodnu akademsku saradnju i izdavaštvo Univerziteta u Sarajevu - Filozofskog fakulteta Minka Džanko, OF-4 Dick de Heus misije Eufor Althea, šef Katedre za historiju umjetnosti Filozofskog fakulteta Haris Dervišević te šefica Biblioteke Filozofskog fakulteta mr. sc. Nadina Grebović- Lendo." +
                "\"Emocionalno me pogodila činjenica da je prekrasna Vijećnica, prvobitno dom Nacionalne biblioteke BiH - zajedno sa kolekcijom od više od 2 miliona knjiga značajnih za Bosnu i Hercegovinu, uništena tokom agresije '90-ih. Tada sam shvatila da kolekcija umjetničkih knjiga mog muža treba pronaći svoj novi život upravo ovdje, u Sarajevu\", napisala je Carole Anne Collier u svom prvom dopisu Ambasadi Kraljevine Nizozemske u Bosni i Hercegovini." +
                "Ambasador Kraljevine Nizozemske Henk van den Dool je još tokom ljeta 2024. godine počeo tragati za načinima da se ova glomazna kolekcija dostavi u Sarajevo. Zahvaljujući kontinuiranoj posvećenosti Nizozemske očuvanju mira u Bosni i Hercegovini, holandski kontigent misije Eufor Althea pristao je na prijedlog ambasadora Van den Doola da upravo oni izvrše ovaj transport kada se za to ukaže prilika." +
                "\"Sama činjenica da neko, ko ranije nije bio u Bosni i Hercegovini, želi pokloniti ovu vrijednu kolekciju studentima nekada duboko ranjenog društva nas je inspirisala. Nažalost, zbog opasnih sistematskih izazova sa kojima se suočavaju bh. institucije kulture, kolekcija nije mogla biti uručena Nacionalnoj biblioteci BiH – što je bila inicijalna namjera. Srećom, uposlenici Filozofskog fakulteta u Sarajevu uspjeli su ispuniti želju gospođe Collier i omogućiti studentima i studenticama Univerziteta u Sarajevu da svoje obrazovanje grade na svjetskim knjigama o historiji umjetnosti, vodičima za muzeje u više od 80 zemalja i radovima o najvažnijim svjetskim umjetnicima\", izjavio je danas Henk van den Dool.Profesorica Minka Džanko sa Filozofskog fakulteta naglasila je da su \"sa zadovoljstvom preuzeli kolekciju knjiga iz privatne biblioteke prof. dr. Jamesa Colliera jer smatraju da će ona imati veliku vrijednost, posebno za studente i akademsko osoblje Katedre za historiju umjetnosti, te da donacija ima i poseban simbolički značaj za Sarajevo i Filozofski fakultet i predstavlja čin humanizma, prijateljstva i vjere u univerzalnu vrijednost znanja.\"" +
                "Današnje uručenje kolekcije knjiga profesora Jamesa Colliera, prvenstveno zahvaljujući Carole Anne Collier, predstavlja još jedan primjer saradnje i kontinuirane podrške između Kraljevine Nizozemske i Bosne i Hercegovine u oblasti kulture i umjetnosti, te potvrđuje uspješne bilateralne odnose ove dvije države." +
                "Ambasada Kraljevine Nizozemske ostaje predana osnaživanju Bosne i Hercegovine na putu ka evropskim integracijama, pri čemu je jačanje društva kroz kulturu i umjetnost samo jedan od načina za postizanje tog cilja.",
                CreatedAt = now.AddDays(-6),
                PublishedAt = now.AddDays(-6),
                Active = true,
                MainPhotoPath = "/Photos/article-11-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Evropska komisija zvanično odobrila Reformsku agendu Bosne i Hercegovine",
                Subheadline = "Pozitivne vijesti",
                ShortText = "Evropska komisija službeno je odobrila Reformsku agendu Bosne i Hercegovine, čime je potvrđeno da dokument ispunjava ključne uslove za korištenje 976,6 miliona eura iz Instrumenta EU za reforme i rast.",
                Text = "Ova odluka predstavlja jedan od najvažnijih koraka BiH na putu ka dubljoj ekonomskoj integraciji s Evropskom unijom.\r\nReformska agenda, koju su vlasti BiH dostavile 30. septembra 2025. godine, prema ocjeni Komisije ispunjava ciljeve Uredbe o Instrumentu za rast. Dokument definiše niz prioritetnih reformi usmjerenih na ubrzanje zelene i digitalne tranzicije, jačanje privatnog sektora, zadržavanje mladih i kvalificiranih kadrova, te unapređenje temeljnih prava i vladavine prava." +
                "Nakon pozitivne ocjene, preostaje da BiH potpiše i ratifikuje Sporazum o instrumentu i Kreditni sporazum. Tek nakon što ti dokumenti stupe na snagu, te kada se ispune svi propisani uslovi, može početi isplata sredstava, uključujući i predfinansiranje." +
                "Odobrenje Reformske agende predstavlja važan iskorak u okviru šireg Plana rasta za Zapadni Balkan, vrijednog 6 milijardi eura. Ovaj program funkcioniše po principu \"investicija uz reforme\" i državama regiona treba da omogući brže približavanje jedinstvenom tržištu EU, uz određene rane ekonomske koristi za građane." +
                "BiH će, kao i ostale zemlje u regionu, sredstva dobiti isključivo pod uslovom uspješne provedbe reformskih mjera, koje obuhvataju temeljne političke promjene, jačanje institucija i socioekonomske reforme uz kontinuiranu saradnju s Evropskom komisijom." +
                "S odobrenjem Reformske agende Bosne i Hercegovine, svih šest partnera Zapadnog Balkana sada ima usvojene reformske programe i može početi koristiti pogodnosti iz Instrumenta, dok paralelno napreduje na svom evropskom putu.",
                CreatedAt = now.AddHours(-8),
                PublishedAt = now.AddHours(-8),
                Active = true,
                MainPhotoPath = "/Photos/article-26-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Sarajevo: U domu Bjelave isključili grijanje zbog curenja plina, studenti se okupili na protestu",
                Subheadline = "Poziv na reakciju",
                ShortText = "Nekoliko desetina studenata, stanara u Studentskom domu Bjelave i Sarajevu, okupilo se u znak protesta ispred doma kako bi mirnim protestom izrazili svoje nezadovoljstvo zbog gašenja grijanja i tople vode nakon curenja plina u kotlovnici.",
                Text = "Okupljeni studenti zahtijevaju od nadležnih hitno poduzimanje mjera kojima bi se novonastalo stanje popravilo, pri čemu je sanacija dotrajalne i nefunkcionalne kotlovnice ključni problem.\r\nU studentskom domu Bjelave trenutno boravi više od 500 studenata kojima je zbog curenja plina u kotlovnici ugašeno grijanje i topla voda." +
                "U saopštenju Udruženja studenata Studentskog centra Sarajevo navodi se da je današnji događaj potvrdio njihove apele odgovornima za sanaciju kotlovnice koja je u funkciji od 1969. godine." +
                "\"Problem kotlovnice u Studentskom domu Bjelave predstavlja dugogodišnji i izuzetno ozbiljan sigurnosni rizik, za koji nadležne institucije, uprkos višegodišnjim apelima, dopisima, sastancima i medijskim upozorenjima, ni danas nisu ponudile trajno rješenje\", navodi se u saopštenju.",
                CreatedAt = now.AddHours(-9),
                PublishedAt = now.AddHours(-9),
                Active = true,
                MainPhotoPath = "/Photos/article-27-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Zemljotres jačine čak 7 stepeni zatresao područje na granici Aljaske i Kanade",
                Subheadline = "Udaljeno područje\r\n",
                ShortText = "Zemljotres magnitude čak 7 stepeni pogodio je u subotu udaljeno područje blizu granice između Aljaske i kanadske teritorije Jukon.",
                Text = "\r\nYukon\r\nYukon\r\n\r\nPoslušajte članak\r\nFacebook\r\nMessenger\r\nTwitter\r\nEmail\r\nEmail\r\nZemljotres magnitude čak 7 stepeni pogodio je u subotu udaljeno područje blizu granice između Aljaske i kanadske teritorije Jukon.\r\nNije bilo upozorenja na cunami, a zvaničnici su rekli da nema neposrednih izvještaja o šteti ili povrijeđenim.\r\n\r\nAmerički geološki zavod saopštio je da se zemljotres dogodio oko 370 km sjeverozapadno od Juneaua na Aljasci i 250 km zapadno od Whitehorsea na Yukonu." +
                "U Whitehorseu, narednica Kraljevske kanadske konjičke policije Calista MacLeod izjavila je da je odred primio dva poziva na broj 911 u vezi sa zemljotresom." +
                "\"Definitivno se osjetilo. Mnogo je ljudi na društvenim mrežama, ljudi su to osjetili\", navela je." +
                "Alison Bird, seizmologinja iz Kanadske agencije za prirodne resurse, rekla je da je dio Yukona koji je najviše pogođen potresom planinski i da ima malo stanovnika.\r\n\r\n\"Uglavnom su ljudi prijavljivali da stvari padaju s polica i zidova. Čini se da nismo vidjeli nikakvu strukturnu štetu.\"" +
                "Kanadska zajednica najbliža epicentru je Haines Junction, rekao je Bird, udaljen oko 130 kilometara. Zavod za statistiku Yukona navodi da je broj stanovnika za 2022. godinu iznosio 1.018." +
                "Potres se dogodio i oko 91 kilometar od Yakutata na Aljasci, koji, prema podacima USGS-a, ima 662 stanovnika." +
                "Udario je na dubini od oko 10 kilometara, a uslijedilo je nekoliko manjih naknadnih potresa.",
                CreatedAt = now.AddDays(-12),
                PublishedAt = now.AddDays(-12),
                Active = true,
                MainPhotoPath = "/Photos/article-28-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = svijet.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Nakon snijega i leda, u BiH večeras stiže i ekstremna hladnoća, a onda opet padavine tokom vikenda",
                Subheadline = "Debeli minusi",
                ShortText = "Nakon snijega, u naredne dvije noći dolaze izraženiji minusi uz temperature do lokalno -15°C, a po mrazištima i hladnije.",
                Text = "Kako navode iz BHMeteo, padavine postepeno slabe i prestaju. Još večeras očekuje se slab snijeg, najprije na istoku, sjeveroistoku i sjeveru zemlje, uz još koji centimetar snijega.\r\n\r\n" +
                "\"Sutra prestanak padavina uz razvedravanje u svim krajevima. Razvedravanje najprije u Krajini gdje već noćas temperature padaju duboko ispod nule uz lokalno dvocifrene minuse do jutra, do oko -15°C\", navode iz BHMeteo.\r\n\r\n" +
                "Sutra navečer očekuju se još veći minusi i u ostatku zemlje.\r\n\r\n" +
                "\"Temperatura većinom od -16 do -8, na jugu do -3 °C. U noći na petak će dolaziti do postepenog naoblačenja sa zapada, uz probijanje juga pa bi temperature polako rasle. Najhladnije po kotlinama i mrazištima istočne i sjeveroistočne Bosne zajedno sa Posavinom i Semberijom uz temperature do lokalno -15°C i niže\", dodaju iz BHMeteo.\r\n\r\n" +
                "Nakon sunčanijeg sutrašnjeg dana, već u petak i za vikend slijedi porast naoblake uz nove padavine. U petak se očekuje jugo, a za vikend novo zahlađenje.",
                CreatedAt = now.AddHours(-6),
                PublishedAt = now.AddHours(-6),
                Active = true,
                MainPhotoPath = "/Photos/article-32-main.png",
                HideFullName = false,
                BreakingNews = false,  
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Zemljotres zatresao srednju Bosnu, osjetio se na širem području",
                Subheadline = "Okolica Bugojna",
                ShortText = "Područje Bugojna večeras je pogodio zemljotres, potvrđeno je na stranici Evropsko-mediteranskog seizmološkog centra (EMSC).\r\n " +
                "Prema prvim informacijama, epicentar je bio u okolini Bugojna, ali se potres osjetio na širem području srednje Bosne.",
                Text = "Građani Bugojna, Donjeg Vakufa, Gornjeg Vakufa, Travnika i okolnih mjesta prijavili su da je podrhtavanje tla trajalo nekoliko sekundi. Neki od njih navode da se čulo i tutnjanje, dok su drugi opisali osjećaj sličan udaru ili eksploziji, uz umjereno do jače podrhtavanje, naročito u višim spratovima zgrada.\r\n\r\n" +
                "Za sada nema zvaničnih podataka o magnitudi zemljotresa, niti informacija o eventualnoj materijalnoj šteti ili povrijeđenim osobama.\r\n\r\n" +
                "Nadležne službe prate situaciju, a više informacija očekuje se nakon što seizmološke institucije objave preciznije podatke o jačini i epicentru potresa.",
                CreatedAt = now.AddHours(-8),
                PublishedAt = now.AddHours(-8),
                Active = true,
                MainPhotoPath = "/Photos/article-33-main.png",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Tramvaji jutros voze od Ilidže do Željezničke stanice, a autobusi dalje prema Baščaršiji",
                Subheadline = "Sarajevo",
                ShortText = "Nakon novih sniježnih padavina koje su tokom noći pogodile Sarajevo, tramvajski saobraćaj se odvija na relaciji Ilidža - Željeznička stanica, objavio je ministar saobraćaja Kantona Sarajevo Adnan Šteta.",
                Text ="Kako je objavio na svom Facebook profilu, od Željezničke stanice do Baščaršije umjesto tramvaja voze autobusi. Istakao je da je trolejbuski saobraćaj u potpunosti operativan.\r\n\r\n" +
                "\"Izazovna noć je bila za sve, cijelu noć su ekipe bile na terenu, situacija se mijenja iz minute u minut\", napisao je Šteta.\r\n\r\n" +
                "Dodao je i da je sinoć posjetio radnike kojima se \"istinski zahvaljuje\", te da će GRAS obavještavati o svim promjenama u toku dana.\r\n\r\n" +
                "U noći sa utorka na srijedu palo je nekoliko novih centimetara snijega, a u satima prije toga u Sarajevu je padala ledena kiša.",
                CreatedAt = now.AddHours(-10),
                PublishedAt = now.AddHours(-10),
                Active = true,
                MainPhotoPath = "/Photos/article-34-main.png",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = bih.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Rusija poslala podmornicu i ratne brodove da brane tanker kojeg prate američke snage",
                Subheadline = "Tenzije na moru",
                ShortText = "Rusija je rasporedila ratne brodove kako bi eskortirala tanker s naftom koji istovremeno progone američke snage preko Atlantika, javlja CBS News.",
                Text = "Brod, koji je ranije prevozio venecuelansku sirovu naftu, ali trenutno navodi da je ne prevozi, nalazi se između Islanda i Velike Britanije.\r\n\r\n" +
                "Bella 1 je optužena za kršenje američkih sankcija i transport iranske nafte. U međuvremenu je promijenila ime u Marinera i, prema navodima, promijenila zastavu iz gvajanske u rusku.\r\n\r\n" +
                "Predsjednik SAD-a Donald Trump prošlog mjeseca izjavio je da naređuje blokadu sankcioniranih tankera s naftom koji ulaze u Venecuelu ili je napuštaju, što je tamošnja vlada opisala kao krađu.\r\n\r\n" +
                "Dva američka zvaničnika potvrdila su za CBS da je Rusija poslala podmornicu i druge ratne brodove kako bi eskortirala tanker.\r\n\r\n" +
                "Američka obalna straža pokušala je prošlog mjeseca da se ukrca na brod na Karibima, kada se vjerovalo da je na putu prema Venezueli. Imala je nalog za zapljenu broda zbog navodnog kršenja sankcija.\r\n\r\n" +
                "Od tada je brod dramatično promijenio kurs, a njegov dolazak prema Evropi poklopio se s dolaskom oko 10 američkih vojnih transportnih aviona, kao i helikoptera.\r\n\r\n" +
                "Rusija je saopćila da s zabrinutošću prati situaciju oko broda.\r\n\r\n" +
                "Dva američka zvaničnika ranije u utorak rekla su za CBS News da američke snage planiraju ukrcavanje na brod, te da Washington preferira da ga zaplijeni, a ne da ga potopi.\r\n\r\n" +
                "U utorak je Južna komanda američke vojske na društvenim mrežama objavila da ostaje spremna da podrži partnerske američke vladine agencije u suprotstavljanju sankcioniranim plovilima i akterima koji prolaze kroz ovu regiju.\r\n\r\n" +
                "\"Naše pomorske službe su budne, agilne i spremne da prate plovila od interesa. Kada poziv stigne, bit ćemo tu\", naveli su u objavi.",
                CreatedAt = now.AddDays(-6),
                PublishedAt = now.AddDays(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-35-main.png",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = vijesti.Id,
                SubcategoryId = svijet.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Fiorentina bez povrijeđenog Džeke osvojila bod u Rimu; Inter iskoristio kiks Napolija",
                Subheadline = "Serie A",
                ShortText = "Nogometaši Fiorentine osvojili su večeras vrijedan u borbi za opstanak u Seriji A, pošto su u 18. kolu remizirali s Lazijom na rimskom Olimpicu sa 2:2.",
                Text = "Svi golovi na ovoj utakmici viđeni su u drugom poluvremenu, pošto su Nebeskoplavi poveli preko Danila Cataldija u 52. minuti, a Viole poravnale samo četiri minute poslije golom Robina Gosensa.\r\n\r\n" +
                "Do preokreta Fiorentina stiže u samom finišu utakmice, kada je dosuđen penal za nju, a siguran realizator kaznenog udarca u 89. minuti bio je Albert Gudmundsson.\r\n\r\n" +
                "Tada je on pogodio za 2:1, ali Fiorentina nije uspjela stići do pobjede jer Lazio u 95. minuti poravnava na 2:2 golom Pedra iz penala. Fiorentina je do ovog boda stigla bez Edina Džeke, kapitena reprezentacije BiH koji je bio van kadra za utakmicu zbog povrede stopala. Na klupi Fiorentine je bio Eman Košpo, koji nije dobio priliku za igru.\r\n\r\n" +
                "U isto vrijeme je Inter gostovao Parmi te je savladao s minimalnih 1:0 golom Federica Dimarca iz 42. minute.\r\n\r\n" +
                "Tako su Nerazzurri uspjeli iskoristiti kiks Napolija, koji je remizirao s Veronom 2:2 i sada njihova prednost nad Napolitancima na vrhu tabele iznosi četiri boda.\r\n\r\n" +
                "Rezultati:\r\n\r\n" +
                "Bologna - Atalanta 0:2\r\n" +
                "Napoli - Verona 2:2\r\n" +
                "Lazio - Fiorentina 1:2\r\n" +
                "Parma - Inter 0:1\r\n" +
                "Torino - Udinese 1:2",
                CreatedAt = now.AddDays(-1),
                PublishedAt = now.AddDays(-1),
                Active = true,
                MainPhotoPath = "/Photos/article-36-main.png",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = sport.Id,
                SubcategoryId = fudbal.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Rastanak izvjestan: Liverpool već našao zamjenu za Salaha",
                Subheadline = "U lošoj formi",
                ShortText = "Liverpool je čini se pronašao zamjenu za Mohameda Salah. Naime, kako piše Goal, prva želja tima s Anfielda je mladi Bradley Barcola, jedan od najboljih nogometaša PSG-a.",
                Text = "Kao što je poznato Salah je već treću utakmicu ostao na klupi, a odnosi između njega i trenera Arnea Slota su odavno narušeni.\r\n\r\nEngleski mediji javljaju da su sve glasnije špekulacije o odlasku egipatskog napadača već u januaru." +
                "Upravo zbog toga u Liverpoolu već rade na planovima za život nakon Salaha, a na vrhu popisa želja nalazi se Bradley Barcola.\r\n\r\nPrema Transfermarktu, Francuz vrijedi 70 miliona eura.\r\n\r\nIako mu je pariški klub ponudio značajno poboljšan novi ugovor koji bi ga svrstao među najplaćenije igrače, Barcola ga još nije potpisao.",
                CreatedAt = now.AddDays(-1),
                PublishedAt = now.AddDays(-1),
                Active = true,
                MainPhotoPath = "/Photos/article-12-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = sport.Id,
                SubcategoryId = fudbal.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Admir Adžem podnio ostavku, čelnici Željezničara je prihvatili",
                Subheadline = "Saznaje NovinskiPortal.ba",
                ShortText = "Admir Adžem više nije trener Željezničara. On je tako svoj treći mandat na klupi Plavih okončao porazom u gradskom derbiju od Sarajeva s ubjedljivih 4:0.",
                Text = "Kako saznaje Klix.ba, Adžemovu ostavku je Uprava kluba s Grbavice i prihvatila tokom večerašnjeg hitnog sastanka.\r\n\r\nPodsjećamo, Željezničar je u nizu od čak šest susreta bez pobjede u domaćem prvenstvu, a u tom crnom nizu Plavi su izgubili čak četiri utakmice." +
                "Ostaje da se vidi ko će na narednom susretu protiv Radnika na Grbavici voditi Željezničar." +
                "Inače, Adžem je Željezničar vodio na 22 utakmice 2014. godine, potom na 40 duela od ljeta 2017. do ljeta 2018. godine, a svoj treći mandat na klupi Plavih je počeo ovog ljeta." +
                "U 20 utakmica u svim takmičenjima ostvario je skor od 7 pobjeda, 6 remija i 7 poraza uz gol-razliku 23:24.",
                CreatedAt = now.AddDays(-3),
                PublishedAt = now.AddDays(-3),
                Active = true,
                MainPhotoPath = "/Photos/article-13-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = sport.Id,
                SubcategoryId = fudbal.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Zašto smo uvezli električnu energiju vrijednu 300 miliona KM? Edhem Bičakčić smatra da je na djelu kriminal",
                Subheadline = "Značajno povećanje",
                ShortText = "Iz Vanjskotrgovinske komore Bosne i Hercegovine (VTK BiH) su nedavno objavili da je od januara do septembra ove godine značajno povećan uvoz električne energije.",
                Text = "Naime, taj uvoz je u odnosu na isti period prošle godine povećan za 184 posto, čime je dosegao iznos od 313 miliona KM.\r\n\r\nIz Vanjskotrgovinske komore (VTK) su kao razlog za to istakli strukturne slabosti." +
                "Edhem Bičakčić iz Međunarodnog vijeća za velike elektroenergetske sisteme (CIGRE) je u izjavi za Klix.ba naveo ono za šta tvrdi da je osnovni razlog značajnog povećanja uvoza električne energije." +
                "Naime, prema njegovim riječima, osnovni razlog jeste nedovoljna količina uglja u termoelektranama u Federaciji Bosne i Hercegovine te poteškoće u radu termoelektrana u Republici Srpskoj." +
                "Naime, prema njegovim riječima, osnovni razlog jeste nedovoljna količina uglja u termoelektranama u Federaciji Bosne i Hercegovine te poteškoće u radu termoelektrana u Republici Srpskoj." +
                "Bičakčić je kao razlog zašto mu je neprihvatljivo uvoziti električnu energiju istakao to da cijena uvozne električne energije košta 0,20 KM po kilovatu dok cijena električne energije kod domaćih privatnih proizvođača iznosi 0,05 KM, što je četiri puta manje." +
                "Naveo je da je povećanje uvoza električne energije nastavljeno i nakon septembra te očekuje da se to povećanje nastavi ako se nastave problemi s ugljem.",
                CreatedAt = now.AddDays(-3),
                PublishedAt = now.AddDays(-3),
                Active = true,
                MainPhotoPath = "/Photos/article-14-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = biznis.Id,
                SubcategoryId = privreda.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Nestle povlači nekoliko proizvoda za dojenčad: Sadrže toksine koji mogu izazvati trovanje",
                Subheadline = "Širom svijeta",
                ShortText = "Nestle povlači nekoliko proizvoda za dojenčad zbog zabrinutosti da sadrže toksin koji može izazvati trovanje hranom.\r\n",
                Text = "Prehrambeni gigant je izjavio da određene serije njegove SMA formule za dojenčad i formule za nastavak dojenja nisu sigurne za hranjenje beba.\r\n\r\n" +
                "Serije su prodate širom svijeta i potencijalno sadrže cereulid, koji može izazvati mučninu i povraćanje prilikom konzumiranja.\r\n\r\n" +
                "Kompanija je saopćila da nije bilo potvrđenih izvještaja o bolestima povezanim s proizvodima, ali ih povlači \"iz predostrožnosti\".\r\n\r\n" +
                "\"Sigurnost i dobrobit beba su naš apsolutni prioritet. Iskreno se izvinjavamo zbog bilo kakve zabrinutosti ili neugodnosti prouzrokovane roditeljima, starateljima i kupcima\", saopćio je Nestle.\r\n\r\n" +
                "Kompanija je potvrdila za BBC da je povlačenje globalno. Navedeni proizvodi prodavani su u nekoliko evropskih zemalja, uključujući Francusku, Njemačku, Austriju, Dansku, Italiju i Švedsku.\r\n\r\n" +
                "Nestle je obećao povrat novca kupcima i rekao da je problem uzrokovan sastojkom koji je obezbijedio jedan od njihovih dobavljača.",
                CreatedAt = now.AddDays(-12),
                PublishedAt = now.AddDays(-12),
                Active = true,
                MainPhotoPath = "/Photos/article-37-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = biznis.Id,
                SubcategoryId = privreda.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "I Općina Novo Sarajevo traži osobe za čišćenje snijega, mjesečni angažman plaća se 1.058 KM",
                Subheadline = "Pozvali na angažman",
                ShortText = "Nakon sarajevske Općine Stari Grad i Općina Novo Sarajevo traži radnike za čišćenje snijega. Riječ je o angažmanu u trajanju od mjesec dana, a najviše tri mjeseca, a naknada iznosi 1.058 KM.",
                Text ="Ovu informaciju je objavila načelnica Općine Novo Sarajevo Benjamina Karić. Poziv je raspisalo JP \"ONSA\" d.o.o. Sarajevo, a kako se navodi pojavila se potreba za angažmanom uslijed nepovoljnih vremenskih uslova.\r\n\r\n" +
                "Raspisan je javni poziv za radnike na čišćenju snijega.\r\n\r\n" +
                "Uslovi koje osobe koje se prijave na poziv moraju ispunjavati su sljedeći: završena osnovna škola, bh. državljanstvo i da su stariji od 18 godina.\r\n\r\n" +
                "Potrebna je i praktična spremnost za rad u otežanim vremenskim uslovima.\r\n\r\n" +
                "Plata iznosi 1.058,40 KM, a radi se na području Općine Novo Sarajevo.\r\n\r\n" +
                "Vrsta ugovora je na određeno vrijeme, od jednog do tri mjeseca.\r\n\r\n" +
                "Zainteresovani prijave mogu dostaviti lično ili putem e-maila na info@jponsa.ba uz CV.",
                CreatedAt = now.AddHours(-3),
                PublishedAt = now.AddHours(-3),
                Active = true,
                MainPhotoPath = "/Photos/article-38-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = biznis.Id,
                SubcategoryId = privreda.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Lego kaže da ima najveću inovaciju u posljednjih 50 godina, neki stručnjaci smatraju da urušavaju dječiju maštu",
                Subheadline = "Smart Bricks",
                ShortText = "Lego je predstavio Smart Bricks - pametne kockice pune tehnologije, a za koje tvrde da će njima oživjeti svoje setove. Naime, riječ je o kockicama koje imaju zvuk i svjetlo te reagiraju na pokret.",
                Text = "Ovaj novitet danske kompanije nazvan Smart Play je predstavljen na tehnološkom sajmu Consumer Electronics Show (CES) u Las Vegasu. Star Wars će biti prvi Legov set koji će imati spomenuti sistem. Iz Lega uvjeravaju da je to njihova najrevolucionarnija inovacija u posljednjih 50 godina.\r\n\r\n" +
                "S druge strane, stručnjaci za igru su zabrinuti jer smatraju da postoji rizik da Lego naruši ono što njegove proizvode čini posebnim za djecu. Naime, Josh Golin, izvršni direktor organizacije za djecu Fairplay, izjavio je da se Smart Bricksom urušava ono što je nekada bilo sjajno kod Lega, a to je korištenje dječije mašte tokom igre.\r\n\r\n" +
                "\"Kao što zna svako ko se ikada igrao s klasičnim Legovim kockicama, dječije kreacije od tih kockica mogu se pokretati i mogu imati zvuk zahvaljujući dječijoj mašti. Međutim, Smart Bricksom se igra uzima iz dječijih ruku i stavlja u male senzore tzv. pametnih uređaja\", kazao je Golin.\r\n\r\n" +
                "Profesor Univerziteta u Edinburghu Andrew Manches je saglasan da je Legova ljepota u slobodi stvaranja, prerade i prilagođavanja jednostavnih kockica u beskrajnim pričama pokretanim dječijom maštom. Ipak, on je pozdravio Legov napor da integriraju fizičku i digitalnu igru pomoću alata koji reagiraju na način dječije igre.\r\n\r\n" +
                "Za Legovu glavnu direktoricu proizvoda i marketinga Juliu Goldin ovo je prilika da se proširi fizička igra.\r\n\r\n" +
                "\"Digitalni svijet nije prijetnja\", rekla je Goldin i dodala da je Smart Bricks nešto čime se besprijekorno povezuju interaktivnost i fizički proizvod.\r\n\r\n" +
                "Šta je Lego Smart Bricks\r\n\r\n" +
                "Iz Lega su ukazali da Smart Bricks kockice mogu osjetiti pokret, položaj i udaljenost onih koji se igraju s njima, prilagođavajući se načinu igre. Kockice imaju senzore, svjetla, mali zvučni sintetizator, akcelerometar i specijalni silikonski čip, što služi za registraciju pokreta i reakciju na njega. Ove kockice će se koristiti sa Smart figurama i Smart Tags pločicama.\r\n\r\n" +
                "BBC-ova ekipa je isprobala Smart Bricks. Kao primjer kako funkcionira istakli su Legovu rođendansku tortu iz koje se reproducira pjesma \"Sretan rođendan\" nakon što se puhne u njene \"svijeće\". Nadalje, primjera radi, iz helikoptera se reproducira zvuk helikopterskog motora tokom kretanja letjelice, a na helikopteru se upali crveno svjetlo prilikom \"sudara\".\r\n\r\n" +
                "Tom Donaldson iz Lega je naveo da se tehnologijom reagira na dječije postupke i nadopunjuje način na koji se ona igraju. Naglasio je da stvaraju nešto za šta žele da potraje godinama.\r\n\r\n" +
                "Ovo nije prvi put da Lego digitalno eksperimentira kako bi privukao i one koji vole digitalni svijet, piše BBC.",
                CreatedAt = now.AddDays(-11),
                PublishedAt = now.AddDays(-11),
                Active = true,
                MainPhotoPath = "/Photos/article-39-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = biznis.Id,
                SubcategoryId = privreda.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Danas isplata penzija za decembar, od idućeg mjeseca penzioneri će primati više novca",
                Subheadline = "Federacija BiH",
                ShortText = "U skladu sa Zakonom o PIO/MIO, penzije za mjesec decembar bit će isplaćene danas preko jedinstvenog računa trezora Federacije BiH.",
                Text ="Najniža penzija za decembar iznosi 599,28 KM, zagarantovana 715,21 KM, dok je najviša penzija 2.996,40 KM, saopćio je Federalni zavod za penzijsko i invalidsko osiguranje.\r\n\r\n" +
                "Prosječna penzija korisnika samostalne penzije, kojih je na isplati za decembar 375.115, iznosi 761,91 KM.\r\n\r\n" +
                "Penziju za decembar primit će ukupno 465.132 korisnika, a potrebna sredstva za isplatu iznose oko 315,5 miliona KM.\r\n\r\n" +
                "Naredna isplata penzija znači i više novca za penzionere na osnovu odluke o rastu penzija za oko 17,2 posto ove godine.\r\n\r\n" +
                "Treba naglasiti da će penzije rasti na osnovu polugodišnjeg usklađivanja penzija, 1. januara i 1. jula.\r\n\r\n" +
                "Januarsko usklađivanje će iznositi oko 11,6 posto, dok će julsko usklađivanje iznositi dodatnih 5,6 posto.\r\n\r\n" +
                "Resorni ministar Adnan Delić je najavio da će minimalna penzija, koja sada iznosi 599 KM, tokom 2026. godine iznositi 700 KM. Zagarantovana penzija bi sa sadašnjih 715 KM tokom 2026. trebala porasti za 121 KM, dok bi najveće penzije, koje sada iznose skoro 3.000 KM, trebale porasti za oko 500 KM.",
                CreatedAt = now.AddDays(-9),
                PublishedAt = now.AddDays(-9),
                Active = true,
                MainPhotoPath = "/Photos/article-40-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = biznis.Id,
                SubcategoryId = privreda.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Evo zašto je vitamin D ključan tokom zimskih mjeseci i u kojim ga namirnicama možete pronaći",
                Subheadline = "Obratite pažnju",
                ShortText = "Zimi često provodimo više vremena u zatvorenim prostorima, a sunčeva svjetlost je oskudna. Upravo to može smanjiti prirodnu proizvodnju vitamina D u našem tijelu, što utiče na imunitet, raspoloženje i zdravlje kostiju.",
                Text = "Nedostatak ovog vitamina može se osjetiti kroz slabiju energiju, učestalije prehlade ili osjećaj umora koji prati većinu zimske sezone.\r\nSrećom, uz pravilnu ishranu možemo nadoknaditi manjak vitamina D i pomoći tijelu da održi vitalnost i otpornost." +
                "Masna riba poput lososa ili sardina ne samo da osigurava vitamin D, već i važne masne kiseline koje čuvaju srce i mozak. Jaja, posebno žumance, prirodan su izvor vitamina D i lako se uklapaju u svakodnevne obroke." +
                "Obogaćeni mliječni proizvodi poput mlijeka, jogurta ili sireva pomažu da tijelo dobije neophodne nutrijente, dok gljive, naročito one izložene sunčevoj svjetlosti, predstavljaju prirodni dodatak ovom vitaminu. Čak i biljni napici, poput sojinog ili bademovog mlijeka, često dolaze s vitaminom D i mogu biti savršen izbor za one koji žele raznovrsnu ishranu." +
                "Uzimanje ovih namirnica tokom zime pomaže da tijelo ostane snažno, imunitet jak, a energija stabilna te redovan unos vitamina D iz hrane može učiniti da se osjećate puno bolje.",
                CreatedAt = now.AddDays(-5),
                PublishedAt = now.AddDays(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-15-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Kako ishranu prilagoditi zimskim uslovima: Evo šta jesti",
                Subheadline = "Za jačanje imuniteta",
                ShortText = "Dolaskom hladnijih dana naš organizam prolazi kroz niz promjena - troši više energije da bi održao tjelesnu temperaturu, a imunitet je izložen većem izazovu zbog čestih infekcija. Upravo zato je važno prilagoditi prehranu zimskim uslovima.",
                Text ="Trebamo birati namirnice koje će pružiti potrebnu energiju, ojačati odbrambeni sistem i doprinijeti općem zdravlju. Zima ne mora biti period teške i jednolike hrane, naprotiv, uz pravi izbor može biti vrlo hranjiva i raznolika.\n\n" +
                "Koju hranu bismo trebali jesti tokom zime:\n\n" +
                "• Topla, hranjiva jela - Variva, čorbe i supe idealan su izbor jer griju organizam i donose bogatstvo nutrijenata. Koristite grah, sočivo, leblebije, krompir, mrkvu i druge zimske namirnice koje dugo drže sitost.\n" +
                "• Fermentirana hrana za jačanje imuniteta - Kiseli kupus, turšija, kefir i jogurt bogati su probioticima koji povoljno djeluju na crijevnu floru, ključnu za snažan imunitet.\n" +
                "• Agrumi i sezonsko voće - Narandže, mandarine, limun, grejp, kao i jabuke i kruške, obiluju vitaminom C i vlaknima. Pomažu u prevenciji prehlada i održavanju energije.\n" +
                "• Orašasti plodovi i sjemenke - Orasi, bademi, lješnjaci, sjemenke bundeve i suncokreta bogati su zdravim mastima, vitaminom E i mineralima.\n" +
                "• Riba i namirnice bogate omega-3 masnim kiselinama - Losos, sardine, skuša, ali i lanene i chia sjemenke doprinose zdravlju srca, poboljšavaju raspoloženje i smanjuju upalne procese.\n" +
                "• Začini koji griju organizam - Đumbir, cimet, kurkuma i bijeli luk imaju snažna protuupalna svojstva i mogu dodatno ojačati odbrambeni sistem.\n\n" +
                "Pravilna i uravnotežena ishrana zimi nije važna samo za očuvanje energije i imuniteta, već i za opću dobrobit. Birajući sezonske i nutritivno bogate namirnice, možemo olakšati tijelu da se nosi s hladnoćom i manjkom sunčeve svjetlosti.",
                CreatedAt = now.AddHours(-2),
                PublishedAt = now.AddHours(-2),
                Active = true,
                MainPhotoPath = "/Photos/article-16-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Kako svakodnevno ispijanje soka od narandže utječe na organizam",
                Subheadline = "Novo istraživanje",
                ShortText = "Prema novoj studiji čaša soka od narandže dnevno može da uradi mnogo više od pukog snabdijevanja vitaminom C - može da utječe na aktivnost gena na način koji podržava zdravlje srca.",
                Text = "U maloj, ali detaljnoj studiji, 20 zdravih odraslih osoba pilo je oko dvije šolje stopostotnog soka od narandže svaki dan tokom dva mjeseca.\r\n\r\nIstraživači sa Univerziteta u Sao Paulu u Brazilu, Državnog univerziteta Sjeverne Karoline i Univerziteta Kalifornije u Davisu pratili su promjene u više od 1.700 gena unutar imunoloških ćelija učesnika, otkrivajući velike promjene u genetskoj aktivnosti povezane s krvnim pritiskom, metabolizmom masti i upalom - svim ključnim faktorima kardiovaskularnog zdravlja." +
                "Nalazi ističu kako citrusni flavonoidi - biljni spojevi koji se nalaze i u bobičastom voću, čaju i kakau, a koji djeluju kao antioksidansi i protuupalna sredstva - mogu utjecati na tijelo na molekularnom nivou. Istraživanje je objavljeno u časopisu Molecular Nutrition & Food Research krajem oktobra." +
                "Većina promjena među učesnicima ukazivala je na nižu upalu i zdraviju funkciju krvnih sudova, iako su se odgovori razlikovali ovisno o tjelesnoj težini. Učesnici s normalnom težinom pokazali su promjene u genima povezanim s upalom, dok su oni s prekomjernom težinom pokazali promjene povezane s metabolizmom masti i potrošnjom energije." +
                "\"Ovi nalazi pojačavaju terapeutski potencijal soka od narandže pružajući neviđen uvid u molekularne mehanizme koji stoje iza njegovih zdravstvenih učinaka\", napisali su istraživači." +
                "Rezultati također ukazuju na to da tjelesna težina \"može utjecati na molekularni odgovor na bioaktivne spojeve u soku od narandže i pružiti informacije za personalizirane preporuke o konzumaciji hrane bogate flavonoidima\", dodali su.",
                CreatedAt = now.AddDays(-2),
                PublishedAt = now.AddDays(-2),
                Active = true,
                MainPhotoPath = "/Photos/article-17-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Prehlađeni ste i muči vas začepljen nos? Ova jednostavna metoda može olakšati simptome",
                Subheadline = "Prirodni saveznik",
                ShortText = "Dolaskom zime i hladnijeg vremena, mnogi se susreću sa respiratornim tegobama poput zapušenog nosa, kašlja, grebanja u grlu i otežanog disanja.",
                Text =
                "U sezoni prehlada i virusnih infekcija, prirodna inhalacija predstavlja jednostavan i djelotvoran način ublažavanja simptoma, naročito kod problema sa sinusima i nosom.\n\n" +
                "Udisanje tople pare pomaže u razrjeđivanju sluzi, olakšava njeno izbacivanje i smanjuje otok sluzokože nosa i sinusa. Osim toga, topla para poboljšava cirkulaciju u disajnim putevima, što dodatno olakšava disanje. Efekat inhalacije može se pojačati dodavanjem prirodnih sastojaka kao što su kamilica, so ili eterična ulja.\n\n" +
                "Za ovu metodu nije potrebna posebna oprema, a postupak se lako može obaviti kod kuće.\n\n" +
                "Potrebni sastojci:\n\n" +
                "• 1 do 2 litre kuhane vode.\n" +
                "• 1 kašičica morske ili kuhinjske soli.\n" +
                "• Po želji: kesica kamilice ili sušeni cvjetovi, nekoliko kapi eukaliptusovog ili mentinog eteričnog ulja, listovi žalfije ili lovora.\n\n" +
                "Postupak:\n\n" +
                "• Vodu zagrijati do ključanja i sipati je u stabilnu posudu.\n" +
                "• Dodati odabrane prirodne sastojke.\n" +
                "• Nagnuti se iznad posude, držeći lice na udaljenosti od oko 30 centimetara.\n" +
                "• Prekriti glavu peškirom kako bi para ostala koncentrisana.\n" +
                "• Udisati paru kroz nos i usta 5 do 10 minuta.\n" +
                "• Nakon inhalacije ostati u toplom prostoru najmanje 15 minuta i po potrebi pažljivo ispuhati nos.\n\n" +
                "Ova metoda pomaže kod virusnih infekcija, blažih oblika sinusitisa, alergijskog rinitisa, kao i kod suhog vazduha koji nadražuje nosnu sluzokožu. Inhalacija se može koristiti jednom do dva puta dnevno dok traju simptomi.\n\n" +
                "Iako je prirodna inhalacija generalno sigurna, potrebno je pridržavati se osnovnih pravila:\n\n" +
                "Para ne smije biti previše vrela kako bi se izbjegle opekotine.\n" +
                "Malu djecu ne treba inhalirati bez savjeta doktora.\n" +
                "Osobe sa hroničnim respiratornim bolestima, poput astme ili hroničnog bronhitisa, treba da se konsultuju sa ljekarom prije primjene inhalacije.\n\n" +
                "Pored inhalacije, preporučuje se i unos toplih napitaka, poput čaja od žalfije, mente ili đumbira, ovlaživanje prostorije i korištenje fiziološkog rastvora za ispiranje nosa. Sve ove mjere mogu značajno smanjiti zapušenost i ubrzati oporavak.",                CreatedAt = now.AddHours(-6),
                PublishedAt = now.AddHours(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-29-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Ova dva pića mogu povećati rizik od začepljenja arterija",
                Subheadline = "Smanjite konzumaciju",
                ShortText = "U svakodnevnom životu često posežemo za omiljenim napicima kako bismo započeli dan, osvježili se ili uživali u trenutku odmora. Iako mnogi od ovih napitaka djeluju bezopasno, njihova dugoročna konzumacija može imati negativan utjecaj na zdravlje srca i krvnih sudova.\r\n",
                Text = "Začepljenje arterija, poznato i kao ateroskleroza, jedan je od glavnih uzroka srčanih problema, a način ishrane i izbor pića igraju značajnu ulogu u njegovom nastanku. Neki napici, iako se često smatraju \"bezopasnima\", mogu doprinijeti nakupljanju masnih naslaga u arterijama i povećati rizik od kardiovaskularnih problema.\r\nZaslađeni gazirani napici sadrže velike količine šećera, a samo jedna limenka može imati i do deset kašičica rafiniranog šećera. Česta konzumacija ovih napitaka može povećati nivo triglicerida u krvi, što dugoročno oštećuje zidove arterija. Osim toga, fosforna kiselina i vještačke boje koje sadrže dodatno remete ravnotežu minerala u organizmu. Umjesto gaziranih sokova, preporučuje se voda s dodatkom svježeg voća ili biljni čajevi bez šećera." +
                "Energetski napici postali su uobičajeni izbor za brzu energiju i bolju koncentraciju. Međutim, visoke količine kofeina, šećera i stimulansa u ovim pićima mogu povisiti krvni pritisak i ubrzati rad srca." +
                "Dugoročno, to može oštetiti krvne sudove i povećati rizik od začepljenja arterija. Osim toga, energetski napici često izazivaju dehidraciju i remete prirodan ritam rada srca. Umjesto njih, bolje je odmoriti se, piti dovoljno vode i birati hranu bogatu vlaknima, magnezijem i zdravim mastima koje podržavaju zdravlje srca." +
                "Iako povremena konzumacija ovih napitaka vjerovatno neće izazvati ozbiljne posljedice, česta i dugotrajna upotreba povećava rizik za zdravlje srca i krvnih sudova. Umjerenost i svjestan izbor pića mogu značajno doprinijeti očuvanju zdravlja.",
                CreatedAt = now.AddDays(-6),
                PublishedAt = now.AddDays(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-30-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Prekomjerna konzumacija pomfrita povećava rizik od ove bolesti",
                Subheadline = "Smanjite unos",
                ShortText = "Iako je teško odoljeti vrućem, hrskavom pomfritu koji dolazi tek iz friteze, pretjerivanje s ovim omiljenim jelom može imati ozbiljne posljedice.",
                Text = "Naime, osobe koje jedu pomfrit tri puta sedmično imaju i do 20 posto veći rizik od razvoja dijabetesa tipa 2, dok se taj rizik dodatno povećava kod onih koji prženi krompir konzumiraju pet puta sedmično.\r\nIpak, rizik se ne odnosi na druge načine pripreme krompira. Kuhan, pečen ili pire krompir nisu pokazali negativne efekte koji se povezuju s prženom verzijom, što jasno pokazuje koliko način pripreme utiče na zdravlje." +
                "Također, zamjena nekoliko sedmičnih porcija krompira cjelovitim žitaricama može doprinijeti smanjenju rizika od dijabetesa. Time se dodatno ističe važnost pravilnog izbora namirnica u svakodnevnoj prehrani." +
                "Podsjetimo, Svjetski dan dijabetesa obilježava se danas. Utemeljen je 1991. godine kao odgovor na rastuću zabrinutost zbog zdravstvene i ekonomske prijetnje koju ova bolest predstavlja, a 2006. postao je i službeni dan Ujedinjenih nacija. Simbol obilježavanja je plavi krug, znak jedinstva i globalne borbe protiv dijabetesa.",
                CreatedAt = now.AddDays(-1),
                PublishedAt = now.AddDays(-1),
                Active = true,
                MainPhotoPath = "/Photos/article-2-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Počela skijaška sezona na Jahorini: Pogledajte prizore snježne idile",
                Subheadline = "Staze su spremne",
                ShortText = "Skijaška sezona na bosanskohercegovačkoj olimpijskoj ljepotici Jahorini je otvorena, a skijanje je danas besplatno za sve posjetioce. Zahvaljujući najboljoj kombinaciji prirodnog i vještačkog snijega stvorena je kvalitetna podloga za rani početak rada skijališta.",
                Text ="Od devet do 16 sati su u funkciji u funkciji gondola Poljice, staze 1 i 1b kao i dječiji ski poligon Poljice. Trener Smučarskog kluba Jahorina Vlado Lučić je kazao da im je drago što je Olimpijski centar Jahorina uspio obezbijediti uslove za skijanje ovako rano.\n\n" +
                "Djeca iz Smučarskog kluba Jahorina su danas već obavila prvi trening. Nastavljamo s daljim radom. Dosad smo već imali dva treninga u Austriji na glečeru i planirali smo treći. Zahvaljujući dobrim uslovima ovdje na Jahorini, taj trening neće biti potreban i mislim da već sada krećemo s odličnim pripremama za tekuću skijašku sezonu, između ostalog je kazao.\n\n" +
                "Načelnik općine Pale Dejan Kojić je naveo da se rukovodstvo OC Jahorina potrudilo da obezbijedi dobre uslove za skijanje.\n\n" +
                "Ubijeđen sam da će i u narednom dijelu sezone zaposleni radnici i rukovodstvo olimpijskog centra dati sve od sebe da uslovi budu odlični na našoj olimpijskoj ljepotici. Ako staze budu ovakve, očekujemo veliki broj turista, što je značajno za Jahorinu, za Pale, za grad Istočno Sarajevo i za sve okolne općine, također. Danas smo se dogovorili da općina Pale ustupi parking olimpijskom centru, a zauzvrat će građani Pala imati besplatan parking na Jahorini. U narednom periodu ćemo ih obavijestiti gdje će moći da podignu stickere i karte, izjavio je.\n\n" +
                "Mi iz lokalne uprave smo se trudili da damo što veći doprinos da sezona bude što bolja. U proteklom periodu sanirali smo dosta saobraćajnica. Radili smo na dosta infrastrukturnih projekata. Obezbijedili smo rasvjetu na komplet lokalitetu Obućina bare. U narednih 15-ak dana ćemo otvoriti moderno klizalište kako bismo povećali zabavni sadržaj na Jahorini. Također ćemo prvi put otvoriti prostorije općine Trnovo na lokalitetu Obućina bare, gdje će biti naš turistički info centar kako bismo pružili što kvalitetniju i bolju uslugu svim turistima, poručio je.\n\n" +
                "OC Jahorina danas organizuje promotivni ski štand u Sarajevo City Centru, gdje će posjetioci tokom cijelog dana moći da kupe ski karte po najpovoljnijim cijenama ove sezone. Ponuda je ograničena i dostupna samo u Sarajevu 2. decembra, a čine je sljedeće karte:\n\n" +
                "• Sezonska ski karta - 1.500 KM (noćno skijanje uključeno bez doplate)\n\n" +
                "• Sezonska karta - radni dani + noćno - 975 KM\n\n" +
                "• Ski karta 10 od sezone - 520 KM\n\n" +
                "Nakon besplatnog prvog dana skijanja, u narednim danima posjetiocima će biti dostupne dnevne ski karte po 50% nižoj cijeni. Olimpijski centar Jahorina poziva sve ljubitelje zime i skijanja da iskoriste rani početak rada skijališta, najpovoljnije cijene ski karata i prve dane decembra provedu na stazama.",
                CreatedAt = now.AddDays(-5),
                PublishedAt = now.AddDays(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-18-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = putovanja.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Zašto u Švedskoj žele da turistima koji posjećuju zemlju bude dosadno",
                Subheadline = "Zanimljiva strategija",
                ShortText = "Švedska ohrabruje turiste da putuju u ovu zemlju u potrazi za dosadom. Turistička organizacija je pokrenula kampanju promovirajući \"usporena\" putovanja te blagodati koje dolaze s nemanjem nikakvih planova za odmor.",
                Text = "Prema naučnim istraživanjima na koje se Švedska poziva dosada pomaže mozgu da se oporavi od kompleksnosti svakodnevnog života. Istovremeno sebe predstavljaju kao savršeno mjesto za bijeg." +
                "Kao jedna od najslabije naseljenih zemalja u Evropi, sa prostranim šumama i bezbroj jezera, Švedska je, kažu iz Visit Sweden, idealno mjesto za spavanje, opuštanje i razmišljanje." +
                "\"Mnogo je stvari koje možeš raditi u Švedskoj\", kaže čelnica Visit Sweden, \"ali jedna od najboljih bi mogla biti da dođeš ovamo, prihvatiš tišinu i — budeš dosadan\"." +
                "Dosada koju spominju ne mora značiti da prilikom posjete zemlji u potpunosti ne radite ništa - već mirniji ili sporiji odmor: digitalni detoks, prirodu, kolibu u šumi.\r\n\r\nMeđu opcijama koje predlažu su: odlazak u daleku kolibu, promatranje zvijezda na sjeveru (npr. u Laponiji), šetnje u snijegu ili sporije zimske izlete." +
                "Također navode mogućnosti istraživanja tradicionalne hrane (poput grilovane bijele ribe, dimljenih suovasa ili mesa soba), opuštanja hladnim kupanjem u spa-hotelima ili kupalištima, ili pak opuštene vožnje dugim drumovima (kao što je put poznat kao \"Blue Highway\" koji povezuje Švedsku, Norvešku i Finsku)." +
                "Cilj kampanje - umjesto brze, ispunjene avanture - jeste da privuku turiste koji žele sporiji, \"wellness & slow travel\" odmor, sa manje obaveza, više mira i šanse da se mozak odmori.",
                CreatedAt = now.AddDays(-3),
                PublishedAt = now.AddDays(-3),
                Active = true,
                MainPhotoPath = "/Photos/article-19-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = putovanja.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Dubrovnik zimi sjaji posebnim sjajem: Festival koji spaja tradiciju, muziku i dječju radost",
                Subheadline = "12. izdanje",
                ShortText = "U decembru, kad se blagdanska atmosfera uvuče u gradske zidine, Dubrovnik ponovno postaje posebno mjesto, ispunjeno svjetlom, pjesmom i zajedništvom. Već 12 godina advent donosi poseban doživljaj, a Stradun sjaji u punom sjaju.",
                Text = "Lampice obasjavaju kamene zidine, mirisi domaćih specijaliteta ispunjavaju zrak, a glazba i smijeh stvaraju atmosferu koja grije i u najhladnijim danima." +
                "Dubrovački zimski festival otvara Doris Dragović već 29. novembra. Program se nastavlja 6. decembra koncertom Đanija Stipaničeva s klapama Ragusavecchia i More, koji donose mediteranski duh u zimske večeri. Uoči Božića, 20. novembra, na Stradun stiže Vanna, dok će 27. decembraParni Valjak podići atmosferu i rasplesati cijeli grad.Niz se nastavlja 28. decembra kada Dražen Zečić donosi romantične stihove, a 30. decembra Željko Bebek energijom svojih hitova vodi publiku prema novogodišnjoj proslavi. Umjesto njegove \"čaše otrova\", uz pjesmu će se nazdravljati čašom dubrovačke Malvasije." +
                "Na Staru godinu program počinje dječjim dočekom uz Jacquesa Houdeka, dok će u večernjem slavlju nastupiti Dino Merlin i Hiljson Mandela, a uz njih i mladi talent Jakov Jozinović, zaokružujući noć ispraćaja stare i doček nove godine." +
                "Već u prvim danima 2026. godine na Stradun stižu Petar Grašo i Tomislav Bralić & klapa Intrade, čiji će glasovi donijeti prepoznatljive dalmatinske tonove." +
                "Festival donosi i bogat program za djecu i porodice - vožnju adventskim vlakićem, klizališta u Lapadu i Mokošici, kreativne radionice, božićne koncerte i kazališne predstave. Svaki kutak Grada oživljava posebnim sadržajem i veseljem." +
                "Dubrovnik ni u decembru nije hladan - grije osmijehom ljudi, okusima adventske kuhinje, pjesmom i svjetlom koje ispunjava njegove ulice." +
                "Dobrodošli na Dubrovački zimski festival - doživite advent u srcu Grada.",
                CreatedAt = now.AddDays(-1),
                PublishedAt = now.AddDays(-1),
                Active = true,
                MainPhotoPath = "/Photos/article-20-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = putovanja.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Zašto vam stjuardese gledaju u cipele prilikom ukrcavanja",
                Subheadline = "Važan razlog",
                ShortText = "Kada se ukrcavate u avion, stjuardese ne samo da vas pozdravljaju, već i diskretno posmatraju jedan detalj: vaše cipele. Iako ovo može djelovati trivijalno, one analiziraju ispunjavate li sigurnosne standarde.",
                Text ="Stjuardese, koje su u hitnim situacijama na prvoj liniji, moraju procijeniti jesu li putnici opremljeni za evakuaciju. Cipele koje nosite mogu olakšati ili otežati vašu mobilnost u hitnoj situaciji.\r\n\r\n" +
                "Kada putnike treba evakuisati, svaka sekunda je važna. Neprikladna obuća poput glomaznih čizama, cipela s visokom potpeticom ili sandala može usporiti kretanje, uzrokovati padove ili smetati drugim putnicima. Još gore, neke cipele mogu oštetiti sigurnosnu opremu.\r\n\r\n" +
                "Ovo je naročito slučaj s toboganima za evakuaciju. Tanke potpetice mogu probiti ove tobogane. Zbog toga je u sigurnosnim uputama često navedeno da nošenje cipela s visokim potpeticama nije dopušteno tokom evakuacije.\r\n\r\n" +
                "Osim sigurnosti, izbor obuće može utjecati i na zdravlje putnika, posebno na dugim letovima. S obzirom na to da se pritisak u kabini razlikuje od onog na tlu, što može pogoršati određene probleme s cirkulacijom, poput venske tromboze. Za udobno i sigurno putovanje, najbolje je da:\r\n\r\n" +
                "• nosite zatvorene cipele koje se lako skidaju ako je to potrebno\r\n" +
                "• izbjegavate nositi cipele s visokim petama, japanke i cipele s platformom\r\n" +
                "• ponesete par čistih čarapa ako poželite skinuti cipele tokom leta\r\n" +
                "• obujete cipele tokom polijetanja, turbulencija i slijetanja.",
                CreatedAt = now.AddDays(-15),
                PublishedAt = now.AddDays(-15),
                Active = true,
                MainPhotoPath = "/Photos/article-47-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = putovanja.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Sarajevo je prvo na listi najjeftinijih city break destinacija u Evropi: \"Možete satima lutati i neće vam biti dosadno\"",
                Subheadline = "Izbor magazina TimeOut",
                ShortText = "Magazin TimeOut objavio je listu najjeftinijih city break destinacija u Evropi za 2026. godinu, a na prvom mjestu našao se glavni grad Bosne i Hercegovine.",
                Text = "Popularne destinacije u Grčkoj, Španiji, Italiji i drugim zemljama koje su pogođene prekomjernim turizmom bilježe odgovarajuće povećanje cijena. Međutim, magazin TimeOut ističe da i s ograničenim budžetom možete pronaći mjesta za istraživanje i odmor.\r\n\r\n" +
                "\"Ova lista destinacija povoljnih cijena obično dolazi ruku pod ruku s drugim prednostima, mislimo na manje turista, manje gužve, a letovi ka tamo će vjerovatno biti i mnogo jeftiniji\", navodi magazin TimeOut.\r\n\r\n" +
                "Napominju i da je pojam \"jeftinog grada\" vrlo subjektivan i ovisi o mnogim faktorima: iz kojeg grada ste doputovali, u koje doba godine ga posjećujete, kakav je vaš ukus i sve ostalo.\r\n\r\n" +
                "Sarajevo se našlo prvo na listi, a magazin navodi da ostaje vrlo pristupačno.\r\n\r\n" +
                "\"To je također grad koji ne zahtijeva trošenje novca, možete lutati njegovim ulicama satima i praktički vam nikada ne bude dosadno. Još bolje, pridružite se besplatnoj pješačkoj turi kako biste se upoznali i saznali više o historiji grada (kažemo besplatno, ali obavezno ostavite napojnicu svom turističkom vodiču)\", preporučuju.\r\n\r\n" +
                "Dalje navode: \"Uzmite zalogaje za ručak na Gradskoj tržnici Markale, natkrivenoj pijaci u centru grada, najedite se tradicionalnog bureka za manje od pet eura i svratite na pivo ili vino za samo dva eura\".\r\n\r\n" +
                "Preporučili su posjetu Sarajevu u augustu kazavši da je grad tad najsunčaniji, ali da je \"daleko najveći razlog Sarajevo Film Festival, jedan od najvećih u jugoistočnoj Evropi\".\r\n\r\n" +
                "Cijelu listu najjeftinijih city break destinacija prema izboru magazina TimeOut čine:\r\n\r\n" +
                "1. Sarajevo, BiH\r\n" +
                "2. Tirana, Albanija\r\n" +
                "3. Hull, Velika Britanija\r\n" +
                "4. Miskolc, Mađarska\r\n" +
                "5. Zagreb, Hrvatska\r\n" +
                "6. Beograd, Srbija\r\n" +
                "7. Sofija, Bugarska\r\n" +
                "8. Kaunas, Litvanija\r\n" +
                "9. Krakov, Poljska\r\n" +
                "10. Argos, Grčka\r\n" +
                "11. Bukurešt, Rumunija\r\n" +
                "12. Graz, Austrija",
                CreatedAt = now.AddDays(-13),
                PublishedAt = now.AddDays(-13),
                Active = true,
                MainPhotoPath = "/Photos/article-48-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = putovanja.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Sedam razloga zašto se stalno budite s glavoboljom",
                Subheadline = "Obratite pažnju",
                ShortText = "Buđenje s glavoboljom može signalizirati poremećaje spavanja ili druge zdravstvene probleme. Ključno je identifikovati okidače poput lošeg sna, alergija ili depresije.",
                Text = "Kako navodi Health, postoji sedam razloga zašto biste se mogli probuditi s glavoboljom.\r\n\r\n" +
                "Apneja u snu\r\n\r\n" +
                "Jedan od uobičajenih uzroka jutarnjih glavobolja je apneja za vrijeme spavanja, stanje u kojem povremeno prestajete disati tokom noći.\r\n\r\n" +
                "Vaše tijelo vas zatim probudi i vi nastavljate disati. Možda čak ni ne shvatate da se to događa. Pitajte svog partnera ili prijatelja da li glasno hrčete jer to je često znak.\r\n\r\n" +
                "Međutim, imajte na umu da hrkanje ne znači uvijek da imate apneju za vrijeme spavanja. U svakom slučaju, vaš ljekar može vas uputiti na studiju spavanja, što je najtačniji način dijagnosticiranja apneje za vrijeme spavanja.\r\n\r\n" +
                "Nesanica\r\n\r\n" +
                "Vjerovatno ste čuli za nesanicu, čest poremećaj spavanja koji može uzrokovati probleme s održavanjem sna ili spriječiti dobar san. Glavobolje su jedan od zdravstvenih problema uzrokovanih ovim stanjem.\r\n\r\n" +
                "Simptomi nesanice uključuju sporo usnivanje, kratko spavanje ili prerano buđenje. Također se možete buditi pospani i osjećati umorno tokom dana.\r\n\r\n" +
                "Škripanje zubima\r\n\r\n" +
                "Škripanje zubima, također poznato kao bruksizam, preko noći može uzrokovati bol u mišićima čeljusti ili temporomandibularnom zglobu (ili TMJ-u, uobičajenom nazivu za poremećaj čeljusti koji ponekad uključuje škripanje). Ta bol može dovesti do glavobolje.\r\n\r\n" +
                "Možda ne znate da škripite zubima, ali pripazite na bol u uhu, osjetljivost mišića, osjetljivost zuba ili bolnu čeljust. Sve su to simptomi bruksizma. Stomatolog može otkriti problem ako postoji.\r\n\r\n" +
                "Alergije\r\n\r\n" +
                "Vaše jutarnje glavobolje mogu biti uzrokovane i alergenima. Izloženost grinjama tokom spavanja (vole živjeti u vašim plahtama i madracu) također vas može probuditi s glavoboljom zbog začepljenja sinusa koje uzrokuju.\r\n\r\n" +
                "Ako imate alergije, pokušajte koristiti posteljinu otpornu na alergije, posebne jastučnice, navlake za madrace i poplune dizajnirane da vas zaštite od izloženosti grinjama i češće perite plahte. Ljekar vam može pomoći pronaći dodatne načine za ublažavanje simptoma.\r\n\r\n" +
                "Migrene\r\n\r\n" +
                "Iako se ove ponavljajuće glavobolje mogu pojaviti u bilo koje vrijeme, migrene su češće ujutro. Često se javljaju na jednoj strani glave, s umjerenom do jakom pulsirajućom ili lupajućom boli.\r\n\r\n" +
                "Drugi znakovi da biste mogli imati migrenu uključuju mučninu, slabost i osjetljivost na svjetlo i zvuk. Postoje i potencijalni simptomi koji se mogu pojaviti i do 24 sata prije glavobolje, poput aure.\r\n\r\n" +
                "Nedostatak ili previše sna\r\n\r\n" +
                "Previše ili premalo sna može biti okidač za tenzijske glavobolje. Često se osjećaju kao da vam traka steže glavu. Također, možete osjetiti bol ili nelagodu u glavi, vlasištu ili vratu.\r\n\r\n" +
                "Depresija i anksioznost\r\n\r\n" +
                "Depresija i anksioznost također mogu izazvati tenzijske glavobolje ujutro. Ako primijetite glavobolje koje se javljaju tokom vremena kada doživljavate ili očekujete stres (npr. ujutro prije posla), razgovarajte sa zdravstvenim djelatnikom kako biste procijenili je li uzrok mentalno zdravstveno stanje.",
                CreatedAt = now.AddDays(-3),
                PublishedAt = now.AddDays(-3),
                Active = true,
                MainPhotoPath = "/Photos/article-49-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Kako vam redovno konzumiranje magnezija može pomoći pri očuvanju zdravlja",
                Subheadline = "Posebno nakon 50. godine",
                ShortText = "Prilikom starenja mnoge osobe posvećuju pažnju navikama koje će pomoći u očuvanju zdravlja, a dijetetičari pojašnjavaju da je redovno konzumiranje jednog minerala posebno važno nakon 50. godine.",
                Text = "Kako ističu, riječ je o magneziju, čiju apsorpciju tijelo kroz godine sve teže održava. Osim toga, starije osobe rjeđe konzumiraju namirnice bogate magnezijem i češće koriste lijekove koji mogu utjecati na nivo ovog minerala u organizmu.\r\n\r\n" +
                "\"Brojne su koristi magnezija za osobe starije od 50 godina, uključujući manji rizik od krhkosti, bolju funkciju mišića, smanjen rizik od kognitivnih poteškoća, podršku zdravlju kostiju i bolji kvalitet sna\", kazala je dijetetičarka Vanessa Imus za Parade.\r\n\r\n" +
                "Magnezij učestvuje u nizu procesa u tijelu, a povezuje se sa zdravljem srca, regulacijom šećera u krvi, očuvanjem gustoće kostiju i kvalitetnijim snom. Preporučeni dnevni unos za starije osobe od 50 godina je 320 miligrama za žene i 420 miligrama za muškarce. Osim kao dodatak ishrani, magnezij se može unijeti kroz lisnato zeleno povrće, orašaste plodove, sjemenke, cjelovite žitarice i mahunarke.\r\n\r\n" +
                "\"Moguće je unijeti dovoljno magnezija samo hranom, ali to zahtijeva mnogo truda. Iako je suplementacija sigurna za zdrave odrasle osobe u odgovarajućim dozama, rizične grupe trebaju ljekarski nadzor i praćenje\", kazala je Imus.\r\n\r\n" +
                "Ona dodaje da osobe s bolestima bubrega, kao i one sa srčanim i probavnim problemima ne bi trebale konzumirati magnezij.",
                CreatedAt = now.AddDays(-2),
                PublishedAt = now.AddDays(-2),
                Active = true,
                MainPhotoPath = "/Photos/article-50-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = lifestyle.Id,
                SubcategoryId = zdravlje.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Motorola predstavila specijalno izdanje telefona Edge 70 ukrašeno Swarovski kristalima",
                Subheadline = "Za odabrana tržišta",
                ShortText = "Motorola je prvobitno predstavila smartphone Edge 70 u oktobru u tri Pantone boje, a to su Gadget siva, Lily Pad i Bronze zelena, a sada je ova kompanija najavila novu specijalnu nijansu koja slavi Pantone boju godine 2026, a zove se Cloud Dancer.",
                Text = "Ova boja je opisana kao \"prozračna bijela nijansa koja komunicira jasnoću umjesto nereda, mekoću umjesto spektakla i prisustvo umjesto pritiska\". Cloud Dancer \"djeluje smirujuće i inspirativno, kao savršen odraz ravnoteže i profinjenosti\", navodi se u Motorolinom saopćenju za javnost." +
                "Poseban detalj su Swarovski kristali, a oni predstavljaju \"eteričan detalj koji omogućava kreativnosti da diše i fokusu da se produbi, vraćajući mir u džepove, dlanove i digitalne živote\", dodaju iz Motorole." +
                "Smartphone će biti dostupan na \"odabranim tržištima\" širom svijeta. Cijena i datum izlaska još nisu objavljeni.",
                CreatedAt = now.AddDays(-2),
                PublishedAt = now.AddDays(-2),
                Active = true,
                MainPhotoPath = "/Photos/article-21-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Sony predstavio novi PS5 kontroler na temu igre \"Genshin Impact\"",
                Subheadline = "Prodaja u februaru",
                ShortText = "Kompanija Sony će početkom 2026. godine predstaviti novo brojčano ograničeno izdanje PS5 DualSense kontrolera te je novim dizajnom odlučila proslaviti veliki hit na konzoli PlayStation 5, odnosno igru \"Genshin Impact\", koja je prisutna duže od pet godina.",
                Text = "Kontroler ograničenog izdanja \"Genshin Impact\" ima \"eteričnu paletu bijele, zlatne i zelene boje ukrašenu arkanskim simbolima fantastičnog carstva, uključujući ambleme blizanaca Aethera i Lumine te njihovog pouzdanog pratioca vodiča Paimona\", navodi Sony. Ovo se poklapa sa lansiranjem \"Genshin Impact\" verzije Luna III." +
                "Kontroler ograničenog izdanja bit će predstavljen 21. januara 2026. u Japanu i Aziji. Lansiranje će biti 25. februara u Sjevernoj Americi, Centralnoj i Južnoj Americi, Evropi, Bliskom istoku, Africi, Australiji i Novom Zelandu" +
                "U regijama gdje je PlayStation Direct dostupan, prednarudžbe će početi 11. decembra. \"Genshin Impact\" kontroler će također biti dostupan u maloprodaji po cijeni od 84,99 eura.",
                CreatedAt = now.AddDays(-4),
                PublishedAt = now.AddDays(-4),
                Active = true,
                MainPhotoPath = "/Photos/article-22-main.jpg",
                HideFullName = false,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Fantastična Xiaomi ponuda u BH Telecomu: Redmi 15C uz dva vrijedna poklona",
                Subheadline = "Adapter i slušalice",
                ShortText = "BH Telecom je pripremio novu, izuzetno atraktivnu ponudu za sve ljubitelje mobilnih uređaja. Uz svaku kupovinu Xiaomi Redmi 15C uređaja u verziji 8/256GB, kupci potpuno besplatno dobijaju Xiaomi adapter 33W i Xiaomi Redmi Buds 6 Play slušalice.",
                Text = "Riječ je o kombinaciji koja donosi odličan omjer cijene i performansi te je idealna za korisnike koji žele velik ekran, snažnu bateriju i praktične dodatke za svakodnevno korištenje.\n\n" +
                "Veliki ekran, svjež dizajn i napredne mogućnosti\n\n" +
                "Redmi 15C donosi jednostavan, moderan dizajn i dolazi u nekoliko novih, elegantnih boja. Čim se uključi, pažnju privlači veliki 6,9-inčni IPS LCD zaslon, sa HD+ rezolucijom, impresivnim 120Hz osvježenjem i svjetlinom do 810 nita, što ga čini odličnim izborom za gledanje sadržaja, društvene mreže, gaming i multitasking.\n\n" +
                "Telefon pokreće MediaTek Helio G81 Ultra procesor sa osam jezgri, dok se za fotografije brine AI sistem dvostruke kamere od 50MP na poleđini i prednja kamera od 8MP. Sve zajedno donosi vrlo solidne rezultate u svakodnevnim uslovima korištenja.\n\n" +
                "Snaga baterije koja traje\n\n" +
                "Ono što Redmi 15C posebno izdvaja je izuzetno izdržljiva 6000mAh baterija, koja uz optimizaciju sistema omogućava dugotrajan rad bez potrebe za čestim dopunjavanjem. Uz to, podržano je 33W brzo punjenje, što zna biti ključno u užurbanom dnevnom ritmu.\n\n" +
                "Telefon dolazi i sa bočnim čitačem otiska prsta, a kućište ima IP64 certifikat, što znači da je otporno na prskanje vode i kišu.\n\n" +
                "Vrijedni pokloni: Adapter 33W i Redmi Buds 6 Play\n\n" +
                "Kupovinom Xiaomi Redmi 15C u BH Telecomu korisnici dobijaju i dva poklona koja dodatno upotpunjuju cjelokupan doživljaj:\n\n" +
                "• Xiaomi Adapter 33W - idealan za iskorištavanje brzog punjenja koje uređaj podržava.\n" +
                "• Xiaomi Redmi Buds 6 Play - lagane i moderne bežične slušalice odličnog kvaliteta zvuka.\n\n" +
                "Ova kombinacija čini ponudu još atraktivnijom, posebno u periodu kada mnogi tragaju za praktičnim i korisnim poklonima.\n\n" +
                "Prilika koja se ne propušta\n\n" +
                "Ponuda je vremenski ograničena i dostupna u svim poslovnicama BH Telecoma, kao i putem web shopa.\n\n" +
                "Sve informacije o cijeni, dostupnim bojama i načinu kupovine možete pronaći na web stranici BH Telecoma. Požurite i iskoristite ovu neodoljivu Xiaomi ponudu.",
                CreatedAt = now.AddDays(-12),
                PublishedAt = now.AddDays(-12),
                Active = true,
                MainPhotoPath = "/Photos/article-23-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Dijelovima Evrope ponestaje vode: Naučnici otkrili da se rezerve značajno smanjuju",
                Subheadline = "Najgore na jugu",
                ShortText = "Ogromne količine evropskih rezervi vode se smanjuju, otkriva nova analiza koja koristi dva desetljeća satelitskih podataka, a zalihe slatke vode se smanjuju širom južne i središnje Evrope, od Španije i Italije do Poljske i dijelova Velike Britanije.",
                Text = "Naučnici sa Univerzitetskog koledža u Londonu (UCL), u saradnji sa Watershed Investigations i Guardianom, analizirali su podatke sa satelita iz perioda 2002-2024, koji prate promjene u Zemljinom gravitacionom polju." +
                "Budući da je voda teška, promjene u podzemnim vodama, rijekama, jezerima, vlažnosti tla i glečerima vidljive su u signalu, što satelitima omogućava da efikasno \"procijene\" koliko je vode uskladišteno." +
                "Nalazi otkrivaju oštru neravnotežu: sjever i sjeverozapad Evrope - posebno Skandinavija, dijelovi Velike Britanije i Portugala - postaju vlažniji, dok se veliki dijelovi juga i jugoistoka, uključujući dijelove Velike Britanije, Španije, Italije, Francuske, Švicarske, Njemačke, Rumunije i Ukrajine, isušuju, što bi moglo imati dalekosežne posljedice." +
                "Zbog ovakvog negativnog trenda će najpogođenija biti poljoprivreda i ekosistemi koji zavise od vode, a posljedično će biti ugrožena i sigurnost hrane." +
                "Agencija za zaštitu okoliša već je upozorila Englesku da se pripremi za sušu koja će trajati i 2026. godine, osim ako ne bude značajnih padavina tokom jeseni i zime.",
                CreatedAt = now.AddDays(-4),
                PublishedAt = now.AddDays(-4),
                Active = true,
                MainPhotoPath = "/Photos/article-24-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = nauka.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "U Australiji otkrivena nova vrsta pčela, zbog neobičnih rogova dobila ime \"Lucifer\"",
                Subheadline = "Na rijetkom cvijetu",
                ShortText = "Australski znanstvenici otkrili su novu autohtonu vrstu pčele s malim rogovima i dali joj \"prikladno\" đavolsko ime. Istraživači su pronašli \"Megachile Lucifer\" dok su promatrali rijedak divlji cvijet koji raste samo u Bremer Rangesu u regiji Goldfields u Zapadnoj Australiji, 470 km istočno od Pertha.",
                Text = "\"Vrlo prepoznatljivi, istaknuti rogovi\" nalaze se samo na ženki pčele i mogu se koristiti kao odbrambeni mehanizam, za skupljanje peludi ili nektara ili za skupljanje materijala poput smole za gnijezda." +
                "Vođa istraživanja rekla je da ju je inspiracija za korištenje imena Lucifer bila gledanje istoimene Netflixove serije u to vrijeme. Dodaje da je to prvi novi član ove pčelinje grupe u 20 godina, piše BBC." +
                "\"Ženka je imala ove nevjerovatne male rogove na licu. Dok sam pisala opis nove vrste, gledala sam Netflixovu seriju Lucifer i ime mi je savršeno pristajalo. Također sam veliki obožavatelj Netflixovog lika Lucifera, tako da je to bilo logično\", rekao je dr. Kit Prendergast sa Univerziteta Curtin." +
                "Lucifer, što na latinskom znači \"donositelj svjetlosti\", također je referenca na osvjetljavanje potrebe za boljim očuvanjem autohtonih vrsta pčela i boljim razumijevanjem načina oprašivanja ugroženih biljaka, rekla je." +
                "Izvještaj, koje je objavljeno u časopisu Journal of Hymenoptera Research, također je pozvalo na to da se područje u i oko gdje su pronađene nove vrste pčela i rijetko divlje cvijeće \"formalno zaštiti i proglasi zaštićenim zemljištem koje se ne može krčiti\"." +
                "\"Budući da je nova vrsta pronađena na istom malom području kao i ugroženi divlji cvijet, obje bi mogle biti u opasnosti od poremećaja staništa i drugih prijetećih procesa poput klimatskih promjene\"“, rekla je, dodajući da mnoge rudarske kompanije ne uključuju domaće pčele prilikom procjene utjecaja svog poslovanja na okoli" +
                "\"Dakle, moguće je da nam nedostaju neopisane vrste, uključujući i one koje igraju ključnu ulogu u podržavanju ugroženih biljaka i ekosistema. Bez znanja koje domaće pčele postoje i o kojim biljkama ovise, riskiramo da izgubimo obje prije nego što uopće shvatimo da postoje\", navela je.",
                CreatedAt = now.AddDays(-16),
                PublishedAt = now.AddDays(-16),
                Active = true,
                MainPhotoPath = "/Photos/article-25-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = nauka.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Samsung će 25. februara u San Franciscu predstaviti Galaxy S26 seriju",
                Subheadline = "U prodaji od marta",
                ShortText = "Prema izvještajima koji kruže južnokorejskim medijima, Samsung će predstaviti svoju seriju Galaxy S26 uređaja 25. februara na posebnom događaju Unpacked u San Franciscu.",
                Text ="Ovaj datum lansiranja sada je potvrdio i tipster s X-a Evan Blass, koji je siguran da ćemo vidjeti seriju Galaxy S26 na policama početkom marta.\r\n\r\n" +
                "To znači da će Galaxy S26 biti lansiran cijeli mjesec kasnije u odnosu na generaciju Galaxy S25, koja je predstavljena 22. januara 2025. Prema špekulacijama, lansiranje u februaru je posljedica Samsungove odluke da u posljednji čas otkaže Galaxy S26 Edge i zamijeni ga modelom Galaxy S26+.\r\n\r\n" +
                "Očekuje se da će Galaxy S26, S26+ i S26 Ultra stići s višim cijenama na nekim tržištima u poređenju sa svojim prethodnicima.",
                CreatedAt = now.AddDays(-8),
                PublishedAt = now.AddDays(-8),
                Active = true,
                MainPhotoPath = "/Photos/article-41-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "AMD i Intel predstavljaju nove AI procesore za PC i gaming te mijenjaju tržišnu utakmicu",
                Subheadline = "Tehnološki Las Vegas",
                ShortText = "Lisa Su, CEO AMD-a, na CES 2026 sajmu u Las Vegasu najavila je nove Ryzen AI procesore i gejmerski Ryzen 7 9850X3D, a s druge strane Intel je predstavio Panther Lake AI čip i platformu za ručne gejming uređaje, uz nedavni ulazak američke vlade u vlasničku strukturu kompanije.",
                Text = "Na svjetskom sajmu tehnologije (CES) predstavljeni su brojni noviteti, a politika čipova je u posebnom fokusu proizvođača, kako AMD-a tako i Intela, posebno u segmentu razvoja vještačke inteligencije i gaminga, prenosi AP.\r\n\r\n" +
                "Tako je AMD najavio novu liniju svojih Ryzen AI procesora, kojom kompanija nastoji dodatno proširiti prisustvo na tržištu AI PC računara. Pored toga, za gejmere je predstavljen i najnoviji model igrama posvećenog procesora AMD Ryzen 7 9850X3D.\r\n\r\n" +
                "S druge strane, Intel je najavio vlastiti AI čip za laptope pod nazivom Panther Lake, poznat i kao Intel Core Ultra Series 3.\r\n\r\n" +
                "Saopćeno je i da Intel planira pokretanje nove platforme namijenjene rastućem tržištu ručnih uređaja za videoigre, čime želi uhvatiti korak u segmentu handheld gaminga.\r\n\r\n" +
                "Intel, pionir iz Silicijske doline koji je decenijama rastao zahvaljujući procesorima za lične računare, u međuvremenu je zapao u krizni period nakon što je propustio talas prelaska na eru mobilnog računarstva koju je pokrenuo iPhone.\r\n\r\n" +
                "Zaostatak se dodatno produbio nakon što je AI bum u prvi plan probio nVidiju, koja je daleko ispred konkurenata.\r\n\r\n" +
                "Važno je spomenuti i da je administracija predsjednika SAD-a Donalda Trumpa nedavno preuzela 10 posto udjela u Intelu, čime je vlada postala jedan od najvećih akcionara kompanije, što se smatra podrškom američkoj tehnologiji i domaćoj proizvodnji.",
                CreatedAt = now.AddDays(-7),
                PublishedAt = now.AddDays(-7),
                Active = true,
                MainPhotoPath = "/Photos/article-42-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Kina predlaže stroga AI pravila za zaštitu djece i sprečavanje savjeta o samopovređivanju",
                Subheadline = "Kina reguliše AI",
                ShortText = "Kina je predstavila nacrt strogih pravila za vještačku inteligenciju kojima želi zaštititi djecu i spriječiti da chatbotovi daju savjete povezane sa samopovređivanjem, nasiljem ili kockanjem. Novi propisi obavezat će pružaoce AI usluga u zemlji na dodatne sigurnosne mehanizme i nadzor nad rizičnim razgovorima.",
                Text ="Nacrt propisa objavila je Uprava za kibernetički prostor Kine (CAC), a odnosi se na širok spektar AI proizvoda i usluga koje su dostupne korisnicima u zemlji, prenosi BBC.\r\n\r\n" +
                "Planirana pravila uskoro bi, nakon javnih konsultacija, trebala postati obavezujuća i predstavljaju jedan od najambicioznijih pokušaja regulacije ubrzano rastuće tehnologije.\r\n\r\n" +
                "Kompanije koje razvijaju i nude AI sisteme morat će osigurati da njihovi modeli ne generišu sadržaj koji promoviše kockanje ili druge oblike štetnog ponašanja.\r\n\r\n" +
                "Posebno su naglašene obaveze zaštite maloljetnika, uključujući uvođenje personaliziranih postavki, vremenskih ograničenja korištenja te pribavljanje saglasnosti staratelja prije pružanja usluga emocionalnog \"društva\" ili razgovora namijenjenih podršci djeci.\r\n\r\n" +
                "Za operatere chatbotova propisana je obaveza da u svim razgovorima koji se tiču samoubistva ili samopovređivanja obavezno interveniše čovjek, odnosno da ljudski operater preuzme komunikaciju.\r\n\r\n" +
                "Uz to, zahtijeva se da čuvari ili hitni kontakti korisnika budu odmah obaviješteni ukoliko postoji opasnost po život ili sigurnost.\r\n\r\n" +
                "Također, tražilo se i sprječavanje širenja \"sadržaja koji ugrožava nacionalnu sigurnost, narušava nacionalnu čast i interese ili podriva nacionalno jedinstvo\".\r\n\r\n" +
                "CAC je poručio da ohrabruje upotrebu vještačke inteligencije za promociju lokalne kulture, razvoj alata za društvo starijih osoba i druge društveno korisne svrhe, pod uslovom da su sistemi sigurni i pouzdani.\r\n\r\n" +
                "Objava nacrta je uslijedila nakon snažnog rasta broja chatbotova u Kini i svijetu, pri čemu su pojedine kineske kompanije postigle globalnu vidljivost.\r\n\r\n" +
                "Kineska AI firma DeepSeek ove godine dospjela je na vrh ljestvica preuzimanja aplikacija, dok su startupi Z.ai i Minimax, koji zajedno imaju desetine miliona korisnika, najavili planove za izlazak na berzu.\r\n\r\n" +
                "Direktor OpenAI-ja Sam Altman ranije je isticao da je način na koji chatbotovi odgovaraju na teme samopovređivanja jedan od najtežih izazova za kompaniju.\r\n\r\n" +
                "U Kaliforniji je protiv OpenAI-ja podignuta tužba zbog smrti šesnaestogodišnjeg mladića, u kojoj porodica tvrdi da je ChatGPT ohrabrio tinejdžera da naudi sebi, što je prvo pravno postupanje u SAD-u u kojem se kompanija tereti za krivicu za smrt korisnika.",
                CreatedAt = now.AddDays(-5),
                PublishedAt = now.AddDays(-5),
                Active = true,
                MainPhotoPath = "/Photos/article-43-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Korisnici iPhonea 17 Pro i Pro Max prijavljuju statički šum u zvučniku tokom punjenja",
                Subheadline = "Apple radi na rješenju",
                ShortText = "Vlasnici Appleovih smartphonea iPhone 17 Pro i Pro Max imaju problema sa zvučnicima svojih uređaja i žale se na statički ili šištajući zvuk, koji se javlja tokom punjenja uređaja.\r\n",
                Text ="Postoje brojne diskusije o ovom problemu na Redditu, MacRumors forumima i Appleovoj zajednici za podršku, gdje pogođeni korisnici kažu da postoji primjetan statički šum \"poput starog radija\". Neki ljudi izvještavaju da ga čuju prilikom reprodukcije zvuka i smanjenja jačine zvuka, dok drugi kažu da se statički šum čuje bez ikakvog zvuka iz zvučnika. U nekim slučajevima postoji tiho pucketanje ili šištanje prilikom pregledavanja web stranica kada se iPhone puni, a neki ljudi čuju šum pri malim jačinama zvuka čak i kada iPhone nije na punjaču.\r\n\r\n" +
                "Također, korisnici izvještavaju da se šum može čuti prilikom korištenja punjača svih vrsta, uključujući i Appleove punjače. MagSafe punjenje također uzrokuje problem, ali korisnici izvještavaju da je statički šum u ovom slučaju tiši. Isključivanjem iPhonea s punjača zvuk nestaje u slučaju korisnika koji imaju statički šum tokom punjenja.\r\n\r\n" +
                "Neki korisnici iPhonea 17 Pro zamijenili su svoje uređaje novima, ali su se susreli s istim problemom. Jedan korisnik Reddita kontaktirao je Appleovu podršku i kaže da je problem proslijeđen inženjerima ove kompanije. Apple navodno radi na rješenju, ali iOS ažuriranja, koja su dosad objavljena, ne rješavaju problem. Zvuk je suptilan prema većini izvještaja, tako da bi se moglo raditi o široko rasprostranjenom problemu koji su primijetili samo oni osjetljivi na buku.",
                CreatedAt = now.AddDays(-6),
                PublishedAt = now.AddDays(-6),
                Active = true,
                MainPhotoPath = "/Photos/article-44-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = tehnologija.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "NASA bi mogla 6. februara lansirati misiju Artemis 2: Historijsko putovanje astronauta oko Mjeseca",
                Subheadline = "Prema aktuelnom planu",
                ShortText = "Artemis 2, prva misija s ljudskom posadom u okviru programa Artemis američke svemirske agencije NASA-e, mogla bi biti lansirana već 6. februara, pod uslovom da se aktuelni raspored ne promijeni.\r\n",
                Text = "Ova misija vodi NASA-ine astronaute Reida Wisemana, Victora Glovera i Christinu Koch te astronauta Kanadske svemirske agencije Jeremyja Hansena na prvo putovanje u lunarni svemir nakon više od pola stoljeća, a također će utrti put onome što NASA namjerava da bude eventualno trajno ljudsko prisustvo na Mjesecu.\r\n\r\n" +
                "Posada je posljednjih nekoliko godina provela trenirajući za svoju misiju i obavila je nekoliko generalnih proba za dan lansiranja u posljednjih nekoliko mjeseci u NASA-inom Svemirskom centru Kennedy (KSC) na Floridi. Kada dođe veliki dan, ukrcat će se u svemirsku letjelicu Orion postavljenu na vrhu NASA-ine masivne rakete Space Launch System (SLS) i potom krenuti na 10-dnevnu misiju leta oko Mjeseca i nazad.\r\n\r\n" +
                "Ako sve bude išlo prema planu, lansiranje će postaviti Orion u Zemljinu orbitu, gdje će posada izvršiti niz provjera sistema na svojoj letjelici prije nego što se odluči za nastavak putovanja prema Mjesecu.\r\n\r\n" +
                "Aktiviranje gornjeg stepena SLS-a će postaviti Orion na putanju slobodnog povratka, petlju u obliku osmice oko Mjeseca koja će \"izbaciti\" kapsulu nazad prema Zemlji bez potrebe za ponovnim paljenjem motora.\r\n\r\n" +
                "Putanja ne ubacuje Orion u Mjesečevu orbitu, ali osigurava povratak letjelice i posade na Zemlju bez obzira na bilo kakve anomalije na koje bi mogli naići.\r\n\r\n" +
                "Artemis 2 će biti prva misija koja će poslati ljude na Mjesec još od završetka NASA-inog programa Apollo i odlaska astronauta misije Apollo 17 s Mjeseca 1972. godine, a priprema se već skoro dvije decenije. Planovi SLS-a, Oriona i svemirske agencije za ponovno pokretanje svog lunarnog programa imali su evoluirajuću arhitekturu s troškovima od gotovo 50 milijardi dolara od 2006. godine, dok trenutna cijena po lansiranju iznosi otprilike 4 milijarde dolara.\r\n\r\n" +
                "Misija Artemis 1 je lansirana u novembru 2022. godine, kada je uspješno poslala bespilotnu kapsulu Orion u i iz lunarne orbite. Dizajniran kao test sistema svemirske letjelice, NASA se nadala da će Artemis 1 brzo usmjeriti program ka Artemisu 2 i povratku astronauta na Mjesec. Međutim, prvobitni cilj lansiranja Artemisa 2 planiranog za 2023. godinu odgođen je zbog oštećenja Orionovog toplotnog štita nastalog tokom ponovnog ulaska Artemisa 1 u Zemljinu atmosferu.\r\n\r\n" +
                "Nakon što su osmislili rješenje kako bi spriječili ponavljanje takve štete, u NASA-i se nadaju da će predstojeće lansiranje Artemisa 2 vratiti program na pravi put. Ali, komplikacije s infrastrukturom Artemisa 3 mogle bi poremetiti njihov vremenski okvir.\r\n\r\n" +
                "Baš kao što je Artemis 1 dizajniran kao bespilotna probna verzija Oriona tokom produženog svemirskog leta, Artemis 2 je probni let koji će potvrditi da letjelica može održavati posadu u dubokom svemiru. Artemis 3 će astronaute poslati na površinu Mjeseca, a da bi to učinila, NASA je ugovorila SpaceX-ov Starship kao prvo vozilo za slijetanje ljudi (HLS) u programu Artemis.\r\n\r\n" +
                "NASA cilja na 2027. godinu za lansiranje misije Artemis 3, ali kašnjenja u razvoju Starshipa mogu pomaknuti tu misiju na 2028. godinu. Kako bi to izbjegao, bivši vršilac dužnosti administratora NASA-e Sean Duffy najavio je u oktobru da razmatra ponovno otvaranje ugovora HLS-a za alternativne landere koji bi mogli biti spremni ranije.\r\n\r\n" +
                "Međutim, zasad je NASA fokusirana na to da Artemis 2 bude lansiran u svemir na siguran i pravovremen način. Kompletna instalacija rakete SLS i Oriona završena je unutar Zgrade za montažu vozila u KSC-u u oktobru i trenutno čeka isporuku na rampu u Lansirnom kompleksu 39A, što se očekuje za samo nekoliko dana.\r\n\r\n" +
                "\"Artemis 2 nastavlja da ostvaruje stalan napredak, a isporuka je sada udaljena manje od dvije sedmice\", rekla je sekretarica za štampu NASA-e Bethany Stevens u videu objavljenom na X-u.\r\n\r\n" +
                "Nakon što bude transportovan do lansirne rampe LC-39A, SLS će proći završne provjere sistema i integraciju rampe te će obaviti generalnu probu kako bi se raketa napunila gorivom i pokrenula kroz proceduru odbrojavanja. Prozor za lansiranje misije otvara se 6. februara, ali NASA još nije objavila taj zvanični ciljni datum.\r\n\r\n" +
                "\"Želim više podataka kako bih osigurao da postavimo odgovarajuća očekivanja. Bit ćemo vrlo transparentni u vezi s tehničkom spremnošću i vremenskim rokovima nakon isporuke\", rekao je novopotvrđeni administrator NASA-e Jared Isaacman u objavi na X-u.",
                CreatedAt = now.AddHours(-4),
                PublishedAt = now.AddHours(-4),
                Active = true,
                MainPhotoPath = "/Photos/article-45-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = nauka.Id,
                UserId = admin.Id
            },
            new Article
            {
                Headline = "Jedan od najčudnijih prirodnih fenomena se nalazi u Saudijskoj Arabiji: Stijena savršeno podijeljena na pola",
                Subheadline = "Al Naslaa",
                ShortText = "Nekih 50 kilometara južno od oaze Tayman u Saudijskoj Arabiji nalazi se jedna od najzagonetnijih geoloških formacija na Zemlji. Smješten na dva gotovo savršena postolja, nalazi se ogroman kamen promjera oko 9 metara, podijeljen savršeno na pola.",
                Text =
                "Razdjeljak je dovoljno ravan da izgleda kao da je isečen laserom, a ipak, uprkos nestabilnosti, kamen još nije počeo da se naginje i zatvara razmak. Efekat čini da kamen izgleda gotovo kao da lebdi, pa nije ni čudo što su neki brzo sugerisali da to mora biti djelo nečeg vanzemaljskog, piše IflScience.\r\n\r\n" +
                "Pronađen u oazi Tayma, Al Naslaa kamen nije samo čudnog izgleda, on je i petroglif. Možda jedan od najfotogeničnijih na svijetu.\r\n\r\n" +
                "Petroglifi su slike napravljene rezbarenjem ili graviranjem površine kamena (za razliku od piktografa, koji se slikaju na kamen). Na površini Al Naslaa mogu se vidjeti prikazi arapskih konja, divokoza i ljudi. Tačno vrijeme kada su gravure nastale nije poznato, ali se vjeruje da pijeskoviti kamen datira od prije nekoliko hiljada godina.\r\n\r\n" +
                "Postoji nekoliko teorija o savršenom razdjeljku Al Naslaa. Jedna je da kamen leži na rasjedu i da je pukotina prvobitno nastala kada se tlo ispod kamena pomjerilo, uzrokujući da se razdijeli na slaboj tački.\r\n\r\n" +
                "Pukotina stvorena ovom aktivnošću mogla je zatim postati svojevrsni vjetrotok za pijeskom natopljene struje koje su prolazile kroz pejzaž. Kako su zrna prolazila kroz razmak hiljadama godina, mogla su praktično izbrusiti neravni razdjeljak i stvoriti savršeno glatku površinu.\r\n\r\n" +
                "Također je moguće da je pukotina \"zglob\", što u geologiji znači kada se prirodno stvori lom u kamenu bez pomjeranja. Fraktura dijeli kamen i često može biti neuobičajeno ravna, kao što se vidi na Al Naslaa.\r\n\r\n" +
                "Druga teorija je da je razdjeljak uzrokovan zamrzavanjem i odmrzavanjem. Ako je neka voda ušla u mali razmak u drevnoj prošlosti, mogla je da se smrzne i proširi, postupno povećavajući pukotinu i povećavajući vjerovatnoću daljeg erozivnog djelovanja. Kada bi se vrijeme ponovo ugrijalo, sav led bi nestao i ostavio savršen razdjeljak u pijeskovitom kamenu.\r\n\r\n" +
                "Što se tiče čudnih postolja na kojima Al Naslaa stoji, ona su zapravo prilično česta u pustinjskim pejzažima. Poznata kao \"gljive kameni\", obično su rezultat erozije od jakih vjetrova ili glacijalne aktivnosti.\r\n\r\n" +
                "Al Naslaa je napravljen od pijeskovitog kamena, koji je prilično slab. Dobro podnosi eroziju, ali moguće je i da su ljudi pokušali napraviti razdjeljak. Jednostavni metalni alati mogli bi odsjeći kamen na pola, ali zašto bi neko to radio? To je sasvim drugo pitanje.\r\n\r\n" +
                "Moguće je da su drevne civilizacije napravile neobičnu kamenu skulpturu kao geografski orijentir, mjesto vjerskog značaja ili rani primjer umjetnosti. Ali, kao što petroglifi na njegovoj površini pokazuju, ne znači da sve što ljudi rade mora imati svrhu osim izražavanja.",
                CreatedAt = now.AddDays(-3),
                PublishedAt = now.AddDays(-3),
                Active = true,
                MainPhotoPath = "/Photos/article-46-main.jpg",
                HideFullName = true,
                BreakingNews = false,
                Live = false,
                CategoryId = scitech.Id,
                SubcategoryId = nauka.Id,
                UserId = admin.Id
            },
        };

            await context.Articles.AddRangeAsync(articles);
            await context.SaveChangesAsync();
        }
        private static async Task SeedArticlePhotosAsync(NovinskiPortalDbContext context)
        {
            var articles = await context.Articles.ToListAsync();

            var articlePhotosMap = new Dictionary<string, List<string>>
            {
                {
                    "Vrijedna donacija",
                    new List<string>
                    {
                      "/Photos/article-additional-1.jpg",
                      "/Photos/article-additional-2.jpg",
                      "/Photos/article-additional-3.jpg"
                    }
                },
                {
                    "12. izdanje",
                    new List<string>
                    {
                        "/Photos/article-additional-4.jpg",
                        "/Photos/article-additional-5.jpg",
                    }
                },
                {
                    "Sarajevo",
                     new List<string>
                     {
                        "/Photos/article-additional-6.jpg",
                        "/Photos/article-additional-7.jpg",
                        "/Photos/article-additional-8.jpg",
                     }
                }
            };

            var photosToInsert = new List<ArticlePhoto>();

            foreach (var kvp in articlePhotosMap)
            {
                var subheadline = kvp.Key;
                var photoPaths = kvp.Value;

                var article = articles.SingleOrDefault(a => a.Subheadline == subheadline);
                if (article == null)
                    continue; 

                var existingPaths = await context.ArticlePhotos
                    .Where(p => p.ArticleId == article.Id)
                    .Select(p => p.PhotoPath)
                    .ToListAsync();

                foreach (var path in photoPaths)
                {
                    if (existingPaths.Contains(path))
                        continue;

                    photosToInsert.Add(new ArticlePhoto
                    {
                        ArticleId = article.Id,
                        PhotoPath = path
                    });
                }
            }

            if (photosToInsert.Count > 0)
            {
                await context.ArticlePhotos.AddRangeAsync(photosToInsert);
                await context.SaveChangesAsync();
            }
        }
    }
}