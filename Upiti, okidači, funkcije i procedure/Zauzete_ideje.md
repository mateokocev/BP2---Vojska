# Prikaz zauzetih ideja za upite, okidače, funkcije i procedure(kako bi se izbjegli duplikati)
## **UPITI**:
- Prikaži id, ime i prezime 10 osoba koje su imale najveći performans na treningu, a preduvjet za njihovo pojavljivanje na listi
  je da su bile na barem jednoj misiji koja u svom intervalu održavanja ima najmanje jedan dan u 12. mjesecu.
  
- Prikaži id, ime, prezime i cin osobe koja je bila odgovorna za vozilo vrste "Helikopteri"
  koje je bilo na najviše popravaka.
  
- Prikazi naziv ture kod koje je izdano najmanje opreme

- Prikaži ukupni proracun sektora koji ima drugi najveci broj osoblja koji nisu bili na lijecenju niti jedanput te koji su sudjelovali
  na najmanje jednom treningu ciji datum pocetka nije bio prije 23 godinu dana od sada.

- Prikaži nazive misija i njene lokacije, ali samo za misije u kojima je sudjelovalo osoblje starije
  od 31 godinu i koje je bilo odgovorno za najmanje jedno vozilo u nekoj turi.

- navedi sva imena i prezimena ozlijedenih vojnika na misiji kojima lijecenje kosta vise od 500 i manje od 5000

- navedi koliko se izdanih samokresa na misiji koristi od strane mornarice

- nabroji sva vozila na popravku koja su ujedno i na misiji te ih nabroji koliko ih je

- svo osoblje koje je na misiji u ohiu

- svi idevi osoblja krvne grupe 0+ koje je na lijecenju i u sektoru je "Hrvatska kopnena vojska"

- ...



## **OKIDAČI**:
- Datum početka ture ne može biti veći ili jednak od datuma kraja ture. Idemo ih uspoređivat samo uz uvjet da kraj nije NULL. 
  U slučaju da je kraj NULL to znači da je tura još uvijek u tijeku. Riječ je o UPDATE-u.                                                               
                                                                                                                            
- Datum početka misije ne može biti veći ili jednak od datuma kraja misije. Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.              
  U slučaju da je kraj NULL to znači da je misija još uvijek u tijeku. Riječ je o UPDATE-u.                                                             

- Datum početka sudjelovanja osoblja na turi ne može biti veći ili jednak od datuma kraja sudjelovanja. Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.             U slučaju da je kraj NULL to znači da osoba još uvijek sudjeluje u turi. Riječ je o UPDATE-u.                                                            
																				
- Datum početka popravka ne može biti veći ili jednak od datuma kraja popravka. Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.              
  U slučaju da je kraj NULL to znači da je popravak još uvijek u tijeku. Riječ je o INSERT-u.                                                          

- Datum početka treninga ne može biti veći ili jednak od datuma kraja treninga te trening bi najmanje trebao trajat 20 min. Riječ je o INSERT-u.                                                                                                                
- Datum početka lijecenja ne može biti veći ili jednak od datuma kraja liječenja kada je riječ o INSERT-u. 
  Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.
  U slučaju je datum kraja liječenja NULL to znači da je liječenje još uvijek u tijeku.                                               

- Napraviti okidač koji će u slučaju da korisnik unese opremu koja je već unešena zbrojit količinu opreme.
  Npr u skladištu već postoji (1330, "RBG-6", "Bacač granata", 124) te korisnik unosi (1370, "RBG-6", "Bacač granata", 6).
  To je "nepotrebno" te stoga okidač pridodaje dodatnu količinu onoj već postojećoj tj (1330, "RBG-6", "Bacač granata", 130).

- Prati se da zbroj izdane količine željene opreme ne bude veći od sveukupne moguće količine opreme tijekom INSERT-a. 
  Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno.

- Prati se da zbroj izdane količine ne bude veći od sveukupne moguće količine opreme tijekom UPDATE-a.
  Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno.

- ...



## **FUNKCIJE**:
- Funkcija vraca ukupni trosak(zbroj troskova iz svih tablica)

- Funkcija racuna koliko je novca ostalo "viska" iz proracuna(u ovoj funkciji se koristila prethodna funkcija)

- Funkcija koja vraća broj osoblja koje je imalo uvijek perofrmans na treningu viši od 6 te da nikad nisu bili na liječenju.

- Za određeni id osoblja treba se dati tekstualni odgovor u čemu je sve osoba sujelovala. 
  Npr. "Arabela Herceg je sudjelovala u najmanje jednoj/m: treningu i lijecenju."
  Moguće je više kombinacija, a najduža je npr "Arabela Herceg je sudjelovao/la u najmanje 
  jednoj: turi, misiji,treningu i lijecenju." U slučaju da osoba nije sudjelovala još uvijek u ničemu bit će ispisano npr 
  "Arabela Herceg nije sudjelovao/la ni u jednoj: turi, misiji,treningu ili lijecenju."

- Performans na treningu može bit od 1 do 10 ([1,10]). Želi se pratiti koliki je bio broj osoblja po određenom činu s pojedinom
  ocijenom performansa. Ne treba prikazat čin čije osoblje uopće nije dio tog performansa.
  Format treba izgledat kao:
  performans   cinovi_i_br_pojavljivanja
	10            skupnik: 3 , brigadir: 3 , bojnik: 1 , pukovnik: 1 , poručnik: 2 , narednik: 2 
	9             pozornik: 1 , narednik: 2 , bojnik: 3 , satnik: 1 , brigadir: 2 , poručnik: 2 , skupnik: 1 , razvodnik: 1 
	...           ...

- ...



## **PROCEDURE**:
- Ispisati koliki je broj osoblja, vozila, opreme trenutačno dostupno(3 vrijednosti) u danom intervalu (dva datuma koje korisnik izabere kao ulazne argumente)

- Za dva vremenski intervala (pojedini će biti određen s dvije datumske vrijednosti) se mora odrediti  pojedinačni 
 ukupni trošak za misije, ukupni trošak za popravak, ukupni trošak za liječenje te usporedit. 
 Ispis treba biti u obliku:
	Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji trošak kada je riječ o misijama u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..
    Vremensko razdoblje od 23.04.1997. do 2.12.2001. ima manji trošak kada je riječ o popravcima u usporedbi s razdobljem od 1.10.1991. do 11.07.1998..
    Vremensko razdoblje od 1.10.1991. do  11.07.1998. ima manji trošak kada je riječ liječenju u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..

- Treba odrediti koje misije su održane na području sjeverne polutke, a koje na području južne polutke. Prilikom 
  navoda se koristi naziv misije. Format mora bit sličan: 
   Misije održane na sjevernoj polutci: naziv1, naziv2, ...
   Misije održane na južnoj polutci: naziv1, naziv2, ...
- ...

- ...



