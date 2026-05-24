# BacPro 🎓

BacPro este o aplicație mobilă dezvoltată cu **Flutter**, dedicată elevilor de liceu din România care se pregătesc pentru examenul de Bacalaureat. Proiectul oferă o interfață intuitivă, curată și rapidă (inspirată din designul nativ iOS - Cupertino), care îi ajută pe elevi să se organizeze, să rezolve variante și să își monitorizeze progresul.

> **Notă:** În acest stadiu, proiectul reprezintă o implementare de **Frontend**. Backend-ul și integrarea cu baza de date pentru fișierele PDF urmează a fi adăugate.

---

## Caracteristici principale

* **Autentificare minimalistă:** Ecran de login elegant cu suport viitor pentru autentificare prin Apple, Google și Facebook.
* **Profile educaționale:** Selectarea profilului (ex: *Mate-Info*, *Filologie*) pentru a afișa doar materiile relevante.
* **Structură organizată:** Subiectele sunt filtrate logic pe Materie -> An (2020-2025) -> Sesiune (Iunie, August, Simulări, Modele oficiale).
* **Mod Examen (Cronometru 3h):** Simulează condițiile reale de examen cu un timer de 3 ore, feedback haptic și alerte de timp.
* **Sistem de auto-evaluare:** Permite utilizatorului să își adauge note personale pe un slider (1-10) și să scrie observații/formule de reținut după fiecare test.
* **Dashboard & Statistici:** Urmărirea progresului general, a orelor de studiu și a mediilor pe fiecare materie.
* **Interfață iOS-like:** Utilizarea widgeturilor Cupertino pentru o experiență de utilizare extrem de fluidă, inclusiv suport pentru gesturi și Dark Mode (în dezvoltare).

---


## Tehnologii folosite

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **UI Toolkit:** Material & Cupertino Icons, Custom CustomPainters (pentru fundaluri geometrice).
* **Arhitectură:** Frontend modularizat (Componente reutilizabile precum `IOSSection`, `IOSCell`, butoane custom).

---

## Instalare și Rulare

Pentru a rula acest proiect local, urmează pașii de mai jos. Asigură-te că ai [Flutter instalat](https://docs.flutter.dev/get-started/install) pe mașina ta.

### 1. Clonează repozitoriul

```bash
git clone https://github.com/numele-tau/bacpro.git
cd bacpro
```

### 2. Descarcă dependențele

```bash
flutter pub get
```

### 3. Rulează aplicația

Conectează un emulator (iOS Simulator recomandat pentru a vedea designul Cupertino exact cum a fost gândit) sau un dispozitiv fizic și rulează:

```bash
flutter run
```

---

## 🗺 Roadmap (Planuri de viitor)

* [ ] Extragerea asset-urilor reale (Logo, Fundal SVG) din design-ul Figma.
* [ ] Conectarea la un serviciu de Backend (Firebase / Supabase) pentru autentificare reală.
* [ ] Integrarea unui vizualizator PDF pentru a deschide subiectele și baremele oficiale.
* [ ] Salvarea notițelor și a progresului în Cloud.
* [ ] Finalizarea implementării pentru Dark Mode.

---

## 🤝 Contribuții

Contribuțiile sunt binevenite! Dacă dorești să îmbunătățești aplicația:

1. Fă un Fork acestui repozitoriu.
2. Creează un branch nou:

```bash
git checkout -b feature/functie-noua
```

3. Dă commit la modificări:

```bash
git commit -m 'Adaugă o funcție nouă'
```

4. Dă push pe noul branch:

```bash
git push origin feature/functie-noua
```

5. Deschide un Pull Request.

---

## 📄 Licență

Acest proiect este licențiat sub MIT License.


