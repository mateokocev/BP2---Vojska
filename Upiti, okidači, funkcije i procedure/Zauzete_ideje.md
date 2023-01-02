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

- imamo: id 3, 4 pistolja te kosirnik bespotrebno dodaje id 5 s 3 pistolja. Stvaramo okidac koji ce tih 3 zbrojit s 5 zato jer
  korisnik nije ispravno postupio. Tezimo tome da baza bude optimalna te da optimalno radi -> doradit!!!

- Prati se da zbroj izdane količine željene opreme ne bude veći od sveukupne moguće količine opreme tijekom INSERT-a

- Prati se da zbroj izdane količine ne bude veći od sveukupne moguće količine opreme tijekom UPDATE-a

- ...



## **FUNKCIJE**:
- Funkcija vraca ukupni trosak(zbroj troskova iz svih tablica)

- Funkcija racuna koliko je novca ostalo "viska" iz proracuna(u ovoj funkciji se koristila prethodna funkcija)

- ...



## **PROCEDURE**:
- Ispisati koliki je broj osoblja, vozila, opreme trenutačno dostupno(3 vrijednosti) u danom intervalu (dva datuma koje korisnik izabere kao ulazne argumente)

- Za dva vremenski intervala (pojedini će biti određen s dvije datumske vrijednosti) se mora odrediti  pojedinačni 
 ukupni trošak za misije, ukupni trošak za popravak, ukupni trošak za liječenje te usporedit. 
 Ispis treba biti u obliku:
	Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji trošak kada je riječ o misijama u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..
    Vremensko razdoblje od 23.04.1997. do 2.12.2001. ima manji trošak kada je riječ o popravcima u usporedbi s razdobljem od 1.10.1991. do 11.07.1998..
    Vremensko razdoblje od 1.10.1991. do  11.07.1998. ima manji trošak kada je riječ liječenju u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..

- ...



