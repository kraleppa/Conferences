# Conferences - System zarządzania konferencjami

## Project description
Project was a part of database classes. The main goal was to create a database system for company which organizes confrences.

## Requirements

### Opis problemu
Projekt dotyczy systemu wspomagania działalności firmy organizującej konferencje:

### Ogólne informacje
  Firma organizuje konferencje, które mogą być jedno- lub kilkudniowe. Klienci
powinni móc rejestrować się na konferencje za pomocą systemu www . Klientami mogą być
zarówno indywidualne osoby jak i firmy, natomiast uczestnikami konferencji są osoby (firma
nie musi podawać od razu przy rejestracji listy uczestników - może zarezerwować
odpowiednią ilość miejsc na określone dni oraz na warsztaty, natomiast na 2 tygodnie przed
rozpoczęciem musi te dane uzupełnić - a jeśli sama nie uzupełni do tego czasu, to pracownicy
dzwonią do firmy i ustalają takie informacje). Każdy uczestnik konferencji otrzymuje
identyfikator imienny (+ ew. informacja o firmie na nim). Dla konferencji kilkudniowych,
uczestnicy mogą rejestrować się na dowolne z tych dni.

### Warsztaty
  Ponadto z konferencją związane są warsztaty, na które uczestnicy także mogą się
zarejestrować - muszą być jednak zarejestrowani tego dnia na konferencję, aby móc w nich
uczestniczyć. Kilka warsztatów może trwać równocześnie, ale uczestnik nie może
zarejestrować się na więcej niż jeden warsztat, który trwa w tym samym czasie. Jest także
ograniczona ilość miejsc na każdy warsztat i na każdy dzień konferencji. Część warsztatów
może być płatna, a część jest darmowa.

### Opłaty
  Opłata za udział w konferencji zależy nie tylko od zarezerwowanych usług, ale także
od terminu ich rezerwacji - jest kilka progów ceny (progi ceny dotyczą tylko udziału w
konferencji, cena warsztatów jest stała) i im bliżej rozpoczęcia konferencji, tym cena jest
wyższa (jest także zniżka procentowa dla studentów i w takim wypadku przy rezerwacji
trzeba podać nr legitymacji studenckiej). Na zapłatę klienci mają tydzień od rezerwacji na
konferencję - jeśli do tego czasu nie pojawi się opłata, rezerwacja jest anulowana.

### Raporty
  Dla organizatora najbardziej istotne są listy osobowe uczestników na każdy dzień
konferencji i na każdy warsztat, a także informacje o płatnościach klientów. Ponadto
organizator chciałby mieć informację o klientach, którzy najczęściej korzystają z jego usług.

### Specyfika firmy
  Firma organizuje średnio 2 konferencje w miesiącu, każda z nich trwa zwykle 2-3 dni,
w tym średnio w każdym dniu są 4 warsztaty. Na każdą konferencję średnio rejestruje się
200 osób. Stworzona baza danych powinna zostać wypełniona w takim stopniu, aby
odpowiadała 3-letniej działalności firmy.

## Database diagram
![diagram](https://github.com/kraleppa/conferences/blob/master/schemat%20bazy.PNG)

## Documentation
https://docs.google.com/document/d/1hsIda8uZYX6Z50RRbwqy7R4PR8k5gudpohNYhq2Ojj4/edit?usp=sharing

## Contributors :mushroom:
<table>
  <tr>
    <td align="center"><a href="https://github.com/kraleppa"><img src="https://avatars1.githubusercontent.com/u/56135216?s=460&u=359e017d16c70a31d3bdb086172308cc6f045acf&v=4" width="100px;" alt=""/><br /><sub><b>Krzysztof Nalepa</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/jakubsolecki"><img src="https://avatars3.githubusercontent.com/u/57220835?s=400&v=4" width="100px;" alt=""/><br /><sub><b>Jakub Solecki</b></sub></a><br />
    </td>
  </tr>
</table>

