#import "@preview/iconic-salmon-svg:3.0.0": *
#import "@preview/touying:0.6.1": *
#import "@preview/chronos:0.2.1": diagram as seq-diagram, _par, _seq, _gap, _note, _delay
#import themes.simple: *

#set text(font: "Source Sans Pro", lang: "de")

#metadata((
  presented-at: "2026-01-19",
  time: "52m",
))

#let title = [Signal Messenger Prä-Quanten Kryptographie]
#let subtitle = [Präsentation im Modul "C179 - Kryptologie"]
#let author = [Eric Behrendt, Daniel Kretschmer, Mose Schmiedel]
#let date = "2026-01-19"
#let institution = [HTWK Leipzig \ University of Applied Sciences Leipzig]
#let logo = image("assets/HTWK_Zusatz_de_H_Black_sRGB.svg")

#let _sources_dict = state("sources", [])

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    institution: institution,
    logo: logo,
  ),
  footer: [
    #context {
      text(20pt, fill: gray.darken(70%), _sources_dict.get())
      _sources_dict.update([])
    }
  ],
)

#show link: underline.with(offset: 4pt)

#let sources(body) = context {
  _sources_dict.update(
    body,
  )
}


#title-slide[
  #align(right)[#logo]
  #v(1fr)
  #box(fill: rgb("eee"), radius: 5pt, width: 100%, inset: 15pt)[
    #text(36pt, title)

    #text(24pt, fill: rgb("#222"), subtitle)
  ]

  #text(18pt)[
    #v(1fr)

    #date

    #v(1fr)

    #author

    #institution
  ]
]

== Überblick
+ Schutzmaßnahmen
+ Sessionverwaltung
+ Verschlüsselung
+ Gruppenchats
+ Anwendungsbeispiel

#v(1fr)

#align(center)[
  #github-info("krypto-ws25/signal-pre-quantum")
]

#v(1fr)

// Das ist ein Beispiel wie die Quellen angegeben werden:
//#sources[
  // @noauthor_array_nodate
  // @noauthor_stdarray_nodate
  // @noauthor_stdvector_nodate
  // @noauthor_stdrangesrange_nodate
  // @noauthor_stdrangesview_nodate
  // @noauthor_stdspan_nodate
//]

= Schutzmaßnahmen

== Routing
// https://signal.org/blog/sealed-sender/
#sources[
  @noauthor_technology_nodate-1
]

*Sealed Sender*
- Absender wird in der Nachricht verschlüsselt
- Minimierung der sichtbaren Metadaten
- Spamvermeidung durch Delivery Token

#image("assets/Sealed-Sender.png", height: 1fr)

== Push Notifications
// https://mastodon.world/@Mer__edith/111563866152334347
#sources[
  @noauthor_meredith_2023
]

/*
*"Wake-Up" Push Notification*
- Nutzung von Push-Benachrichtigungen als Hinweis
- Keine Übertragung sensiblen Inhalts
- Lokale Abfrage und Entschlüsselung
#image("assets/Notification.jpeg", height: 1fr) // https://community.home-assistant.io/t/use-signal-messenger-for-notifications/80214/14
*/

#align(center)[ #seq-diagram({ let c = text.with(14pt)
let _seq = _seq.with(comment-align: "center")

_par("Sender")
_par("Signal Server")
_par("Push Service")
_par("Empfänger")

// Step 1: Sending the encrypted message
_seq("Sender", "Signal Server",
    comment: c[Verschlüsselte Nachricht]
)

_gap(size: 10)

// Step 2: Server pings the Push Service
_seq("Signal Server", "Push Service",
    comment: c[Leerer Ping]
)

// Step 3: Push Service wakes up the device
_seq("Push Service", "Empfänger",
    comment: c["Wake-Up" / Push Event],
    dashed: true
)

_gap(size: 10)

// Step 4: App connects to Server to fetch content
_seq("Empfänger", "Signal Server",
    comment: c[Datenabruf]
)

// Step 5: Server delivers encrypted content
_seq("Signal Server", "Empfänger",
    comment: c[Verschlüsselter Inhalt],
    dashed: true
)

// Step 6: Local processing
_seq("Empfänger", "Empfänger",
    comment: c[Entschlüsselung],
    comment-align: "left"
)

// Step 7: Local display
_seq("Empfänger", "Empfänger",
    comment: c[Anzeige Benachrichtigung],
    comment-align: "left"
)
}) ]

== Attachments

*Blob Store*
- Anhänge werden nicht über die Nachrichten-Warteschlange übertragen
- Übertragung als verschlüsseltes Objekt mittels weiterem Server
- Schlüsselübertragung über Nachrichtenweg

== Calling Infrastructure
// https://signal.org/blog/how-to-build-encrypted-group-calls/
#sources[
  @noauthor_how_nodate
]

*RingRTC*
- Erweiterung von WebRTC
//- Anrufe werden mittels verschlüsselter Nachricht angekündigt
//- Peer-to-Peer-Verbindung
- TURN-Relay auf Wunsch oder bei Bedarf
#image("assets/Call.png", height: 1fr) // https://desosa.nl/projects/signal-android/2020/03/19/rome-wasnt-built-in-a-signal-day

== Private Contact Discovery
// https://signal.org/blog/private-contact-discovery/

*SGX Enclaves*
- Kontaktabgleich auf Server
- Nutzung Intel SGX Software Guard Extensions

== Secure Backups
// https://signal.org/blog/introducing-secure-backups/
#sources[
  @noauthor_introducing_nodate
]

- Privacy-First "Zero-Knowledge" Architecture
  - Unlinked Data
  - No Tracking
- User-Controlled 64-Character Recovery Key
  //- Ownership
  //- Finality
  //- Separation
- Layered Encryption & Padding
  //- Doppelte Verschlüsselung
  //- Größenverfälschung
- Handling of Disappearing Messages
- Opt-In
- Cross-Platform Wiederherstellung
  //- Beachtung von Flüchtigkeit von Nachrichten

= Sessionverwaltung - Sesame
// https://signal.org/docs/specifications/sesame/
#sources[
  @noauthor_specifications_nodate
]

// - Ausgelegt auf asynchrone Kommunikation
// - Server-Warteschlange (Mailbox) pro Gerät
// - Nachrichten flüchtig Speichern

== Kernfunktionen

*Multi-Device Management*
- UserRecords und DeviceRecords
  - Hierarchie zum Speichern der Encryption-Sessions
- Self-Sending
  - Nachrichten werden auch eigenen Geräte geschickt
*Session Convergence*
- Abstimmung über aktive Session
  - Aktive Session für das Senden von Nachrichten
- Receiving & Switching

== Kernfunktionen

*Handling Stale Devices und Messages*
- Stale Records
  - Behandlung von abgelaufenen Records
*Identity Key Models*
- Per-User Identity Keys
- Per-Device Identity Keys

== Server Interaction

- Mailboxes
  //- Pro Gerät existiert eine Mailbox
  //- Abruf von Empfänger-Prekeys für neue Sessions
- Unreliable Network Resilience
  //- Behandlung von gestörten Nachrichten
    //- Out-of-Order
    //- Verspätet
    //- Doppelt

#image("assets/Messaging.png", width: 100%) // https://desosa.nl/projects/signal-android/2020/03/19/rome-wasnt-built-in-a-signal-day
#sources[
  @noauthor_rome_nodate
]

/*
== Multi-Device Management

- UserRecords and DeviceRecords
  - Hierarchie zum Speichern der Encryption-Sessions
- Self-Sending
  - Nachrichten werden auch eigene Geräte verschickt

== Session Convergence

- Active Session
  - Aktive Session für das Senden von Nachrichten
- Receiving & Switching
  - Abstimmung über aktive Session

== Handling Stale Devices und Messages

- Stale Records
  - Behandlung von abgelaufenen Records

== Identity Key Models

- Per-User Identity Keys
- Per-Device Identity Keys
*/

= Verschlüsselung – X3DH

== Allgemeine Informationen
#sources[
  @noauthor_specifications_nodate-2
]

- *Überblick*
  - "Extended Triple Diffie-Hellman"
  - Etabliert einen gemeinsamen geheimen Schlüssel zwischen zwei Parteien
  - Bietet gegenseitige Authentifizierung mittels öffentlicher Schlüssel
  - Entwickelt für asynchrone Umgebungen (z. B. wenn eine Partei offline ist)
  - Bietet Forward Secrecy (Folgenlosigkeit) und kryptografische Abstreitbarkeit

- *Schlüsselarten*
  #figure(
  table(
    columns: (auto, auto, 1fr),
    inset: 10pt,
    align: horizon,
    fill: (col, row) => if row == 0 { luma(230) } else { white },

    // Header
    [*Bezeichnung*], [*Symbol*], [*Beschreibung*],

    // Rows
    [Identitätsschlüssel],
    [$"IK"_A, "IK"_B$],
    [Langzeitschlüssel],

    [Ephemerer Schlüssel],
    [$"EK"_A$],
    [Wird für einen einzelnen Durchlauf generiert],

    [Signierter Prekey],
    [$"SPK"_B$],
    [Wird von Bob periodisch aktualisiert],

    [Einmal-Prekey],
    [$"OPK"_B$],
    [Wird einmalig verwendet und dann gelöscht],
  ),
)

  == Veröffentlichen der Schlüssel
#align(center)[#image("assets/x3dh/step1.png", height:84%)]

== Abrufen des Schlüsselbündels
#align(center)[#image("assets/x3dh/step2.png", height:84%)]

== Verarbeiten des Schlüsselbundes

- *Schlüsselberechnung (Alice)*
  - Alice generiert ein ephemeres Schlüsselpaar ($"EK"_A$)
  - Alice berechnet die DH-Ausgaben:
    - $"DH1" = "DH"("IK"_A, "SPK"_B)$
    - $"DH2" = "DH"("EK"_A, "IK"_B)$
    - $"DH3" = "DH"("EK"_A, "SPK"_B)$
    - Optional: $"DH4" = "DH"("EK"_A, "OPK"_B)$

- *Ableitung des gemeinsamen Geheimnisses (SK)*
  - $"SK" = "KDF"("DH1" || "DH2" || "DH3" [ || "DH4"])$

- *Assoziierte Daten (AD)*
  - Konstruiert für die Authentifizierung
  - $"AD" = "Encode"("IK"_A) || "Encode"("IK"_B)$
  - Optionale Identifikationsdaten (Benutzernamen etc.) können angehängt werden

- *Senden der Nachricht*
  - Alice sendet Initialnachricht an Bob:
    - Alices Identitätsschlüssel ($"IK"_A$)
    - Alices Ephemerer Schlüssel ($"EK"_A$)
    - Identifikatoren für die verwendeten Prekeys
    - Ein mit SK (und AD) verschlüsselter initialer Geheimtext

== Verarbeiten der Initialnachricht
#align(center)[#image("assets/x3dh/step3.png", height:84%)]


= Verschlüsselung – Double Ratchet

== Warum der Name "Ratchet" (Ratsche)?
- *Einweg-Prinzip*: Bewegung nur vorwärts (wie mechanische Ratsche)
- *Unumkehrbarkeit*: Keine Rückrechnung auf alte Schlüssel möglich
- *Sofortige Löschung*: Nachrichtenschlüssel werden nach Gebrauch vernichtet
#align(center)[#image("assets/double_ratchet/Ratchet_rotation_prevented.jpg", height:45%)]
//https://www.notesandsketches.co.uk/images/Ratchet_rotation_prevented.jpg
#sources[
  @noauthor_mechanisms_nodate
]

== Warum "Double" (Doppel)?
Kombination zweier Mechanismen:
1. *Diffie-Hellman-Ratchet*:
  - Auslösung bei Generierung neuer privater Schlüssel
  - Erneuert das Schlüsselmaterial ("Selbstheilung")
2. *Symmetrische Ratchet (KDF)*:
  - Auslösung pro Nachricht
  - Schnelle Generierung neuer Schlüssel

  == Warum wird diese benötigt?
  #sources[
    @noauthor_signal_nodate-1
  ]
  - *Ende-zu-Ende-Sicherheit*: Vertraulichkeit zwischen zwei Parteien
  - *Forward Secrecy*: Schutz vergangener Nachrichten bei Schlüsseldiebstahl
  - *Post-Compromise Security*: Automatische "Selbstheilung" nach Kompromittierung

== KDF-Ketten (Key Derivation Function)
#align(center)[#image("assets/double_ratchet/Set0_0.png", height:84%)]

== Symmetrische Schlüssel-Ratchet
#align(center)[#image("assets/double_ratchet/Set0_1.png", height:84%)]

== Diffie-Hellman-Ratchet
#align(center)[#image("assets/double_ratchet/Set1_0.png", height:84%)]
== Diffie-Hellman-Ratchet
#align(center)[#image("assets/double_ratchet/Set1_1.png", height:84%)]
== Diffie-Hellman-Ratchet
#align(center)[#image("assets/double_ratchet/Set1_2.png", height:84%)]
== Diffie-Hellman-Ratchet
#align(center)[#image("assets/double_ratchet/Set2_1.png", height:84%)]
== Diffie-Hellman-Ratchet
#align(center)[#image("assets/double_ratchet/Set2_2.png", height:84%)]

== Double Ratchet
#align(center)[#image("assets/double_ratchet/Set3_0.png", width:100%)]
== Double Ratchet
#align(center)[#image("assets/double_ratchet/Set3_1.png", width:96%)]
== Double Ratchet
#align(center)[#image("assets/double_ratchet/Set3_2.png", height:84%)]
== Double Ratchet
#align(center)[#image("assets/double_ratchet/Set3_3.png", height:84%)]
== Double Ratchet
#align(center)[#image("assets/double_ratchet/Set3_4.png", height:84%)]


= Gruppenchats

== Allgemeines (1/2)

#align(center)[

#let end = 3

#grid(
  columns: (auto, auto, auto),
  rows: 1.9em,
  align: left + horizon,
  inset: (x: 7pt, y: 8pt),
  stroke: (x, y) =>
  if x < 2 and y == 0 {
    (
      paint: black,
      thickness: 2pt,
    )
  } else {
    if x < 2 and y <= end {
    (
      bottom: (
        paint: black,
        thickness: if y == end { 2pt } else { 1pt },
      ),
      ..if x == 0 {
        (
          left: (
            paint: black,
            thickness: 2pt,
          )
        )
      } else {
        if x == 1 {
          (
            right: (
              paint: black,
              thickness: 2pt,
            )
          )
        }
      }
  )
  }},
  grid.cell(colspan: 2)[*Gruppe*], [],
  [Mitglieder], [$C_"M" (U_i)$], [_verschlüsselte Mitgliederliste (UIDs)_],
  [Profilschlüssel], [$C_"PK" (P(U_i))$], [_verschlüsselte Schlüssel für Profildaten_],
  [Profile], [$C_"P" (P(U_i))$], [_verschlüsselte Profildaten zu ggb. UID_]
)
]

== Allgemeines (2/2)
// https://signal.org/blog/signal-private-group-system/
#sources[
  @noauthor_technology_nodate-3
  @chase_signal_2019
]
- Problem: Server soll Gruppenmetadaten (Mitgliederliste, Beschreibung, Bild, usw.) nicht lesen und schreiben können
- früher: jeder Nutzer verwaltet lokal Gruppenmetadaten
- heute: Gruppenmetadaten liegen verschlüsselt auf dem Server mit geteiltem Schlüssel #sym.arrow *GroupMasterKey*
- Gruppennachrichten werden Peer-to-peer verschlüsselt und versendet
- *Wie kann Server Veränderungen der Gruppenmetadaten authentifizieren?*

== Anonymous Credentials (1/2)
- UserID $U$ liegt nur verschlüsselt $C(U)$ auf dem Server #sym.arrow kann vom Server nur in diesem Zustand verwendet werden
- User muss zeigen, dass er der Besitzer von $C(U)$ ist ohne $U$ dem Server zu verraten #sym.arrow Zero-Knowledge proof
- außerdem müssen Kollisionen $C(U_1) = C(U_2)$ zwingend verhindert werden um Spoofing zu verhindern

- neue Verschlüsselung keyed-verification anonymous credentials (KVAC)

== Anonymous Credentials (2/2)

- GroupMemberEntry ist UID mit deterministischer Verschlüsselung

- Server erzeugt regelmäßig AuthCredentials pro UID #sym.arrow müssen von User geholt werden

- User kann mit AuthCredential und eigener UID verschlüsselten GroupMemberEntry wieder erzeugen #sym.arrow Authentifizierung

== Beispiel: Gruppe erstellen

#align(center)[
  #seq-diagram({
      let c = text.with(14pt)
      let _seq = _seq.with(comment-align: "center")

      _par("Alice")
      _par("Server")
      _par("Bob")

    // Schritt 1: Alice erzeugt GroupMasterKey
    _seq("Alice", "Alice",
        comment: c[Erzeugt GroupMasterKey & GroupPublicParams],
        comment-align: "left"
    )

    _gap(size: 5)

    // Schritt 2: Alice → Server (GroupPublicParams)
    _seq("Alice", "Server",
        comment: c[GroupPublicParams]
    )

    // Schritt 3: Alice → Server (Paare hochladen)
    _seq("Alice", "Server",
        comment: c[$(C_"M" (U_"Alice"), C_"P"), (C_"M" (U_"Bob"), C_"P")$]
    )

    // Schritt 4: Alice → Server (AuthCredentials Beweis)
    _seq("Alice", "Server",
        comment: c[AuthCredential]
    )

    _gap(size: 15)

    // Schritt 5: Alice → Bob (GroupMasterKey verschlüsselt) - E2E
    _seq("Alice", "Bob",
        comment: c(fill: blue)[GroupMasterKey als verschlüsselte Privatnachricht],
    )

    _gap(size: 10)

    // Schritt 6: Bob → Server (AuthCredential + Anfrage)
    _seq("Bob", "Server",
        comment: c[AuthCredential]
    )

    // Schritt 6b: Server → Bob (Metadaten zurück)
    _seq("Server", "Bob",
        comment: c[verschlüsselte Metadaten],
        dashed: true
    )

    // Schritt 7: Bob entschlüsselt
    _seq("Bob", "Bob",
        comment: c[Entschlüsselt mit GroupMasterKey],
        comment-align: "left"
    )
  })
]

== Beispiel: Gruppenmitglied hinzufügen

#align(center)[
  #seq-diagram({

      let c = text.with(14pt)
      let _seq = _seq.with(comment-align: "center")

    _par("Bob")
    _par("Server")
    _par("Charlie")

    // Schritt 1: Bob hat GroupMasterKey
    _seq("Bob", "Bob",
        comment: c[Besitzt GroupMasterKey],
        comment-align: "left"
    )

    // Schritt 2: Bob → Server (Paar hochladen)
    _seq("Bob", "Server",
        comment: c[$(C_"M" (U_"Charlie"), C_"P")$]
    )

    // Schritt 3: Bob → Server (AuthCredential Beweis)
    _seq("Bob", "Server",
        comment: c[AuthCredential]
    )

    _gap(size: 10)

    // Schritt 4: Bob → Charlie (GroupMasterKey verschlüsselt) - E2E
    _seq("Bob", "Charlie",
        comment: c(fill: blue)[GroupMasterKey als verschüsselte Privatnachricht],
    )

    _gap(size: 10)

    // Schritt 5: Charlie → Server (AuthCredential + Anfrage)
    _seq("Charlie", "Server",
        comment: c[`AuthCredential`]
    )

    // Schritt 5b: Server → Charlie (Metadaten zurück)
    _seq("Server", "Charlie",
        comment: c[verschlüsselte Metadaten],
        dashed: true
    )

    // Schritt 6: Charlie entschlüsselt
    _seq("Charlie", "Charlie",
        comment: c[Entschlüsselt mit GroupMasterKey],
        comment-align: "left"
    )
  })
]


=

== Zusammenfassung

- Sesame
- RingRTC
- X3DH
- Double Ratchet
- Anonymous Credentials
- Secure Backups

#v(1fr)
#v(1fr)

== Quellen


https://signal.org/docs/specifications/doubleratchet/
#bibliography("C179 - Kryptologie.bib", title: none)
