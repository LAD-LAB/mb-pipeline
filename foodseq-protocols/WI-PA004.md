# WI-PA004 Indexing qPCR for Diet Metabarcoding Sequening - qPCRB

## Purpose
The purpose of this document is to provide instructions on indexing amplified DNA (trnGH or 12SV5) for in-house sequencing.

## Scope
All persons who perform FoodSeq work in the David Lab.

## Associated Documents
  * WI-DEXXX DNA Extraction
  * WI-PA003 Primary qPCR for trnGHL or WI-PA003B Primary qPCR for 12SV5

## Required reagents, equipment, and consumables
- [ ] Clean PCR hood and clean biosafety cabinet (BSC)
- [ ] 96-well optical PCR plate, optical sealing film, and foil seals
- [ ] PCR certified filter pipet tips and pipettors
- [ ] Cooling rack, ice, and ice bucket
- [ ] Nuclease-free water
- [ ] Pre-mixed Illumina-compatible barcoding primers, 2.5 uM each primer, 5 uM total (Ordered from IDT, diluted and mixed in-house)
  * Working barcode plate is generally made for three uses (contains 36 uL of pre-mixed primer when new)
- [ ] Aliquot(s) of KAPA HiFi HotStart plus dNTPs (7958897001/KK2502) **OR KAPA HiFi HotStart ReadyMix (7958935001/KK2602)**

   The dNTP kit (also referred to as "individual components") is more temperature-sensitive. The lab has had issues with kits going bad because of this. As of July 2022, Dr. David prefers the ReadyMix to avoid issues with PCR.

   Using individual components allows for the adjustment of polymerase which redues primer dimers.

- [ ] SYBR Green I - diluted in filtered DMSO to 100x
- [ ] Primary PCR-amplified template

   
## Instructions
  * Procedure follows on subsequent pages
  * An Excel template for reaction component calculations is available
  * Once gels are completed on barcoded amplicons, move onto WI-AC001

## Revision History
| Summary of Changes | Date | Version |
| ------------------ | ------------------ | ------------------ |
| N/A - 1st version | 07/18/2022 | 1|
|Updated initial denat time from 5 min to 3 min to match current protocol | 12/07/2022 | 2 |
|Updated protocol to make and add templates in the BSC | 05/19/2023 | 3 |


## PROCEDURE
**Prepare template DNA (manually)**
**Location:** Biosafety cabinet (BSC)
Note that preparing the template DNA (diluting 1:10 and 1:100) can be done with the **epMotion**. Otherwise, manual steps are as follows:

- [ ] Treat BSC area with RNAse Away, let dry, then treat with UV light for ~15 minutes.
- [ ] **In a new plate,** make a 1:10 dilution of the primary PCR-amplified template by adding 5 uL of amplicons to 45 uL of nuclease-free water. Mix well.
- [ ] **In a new plate,** make a 1:100 dilution of the primary PCR-amplified template by adding 5 uL of the 1:10 diluted amplicons to 45 uL of nuclease-free water. Mix well.


**Prepare PCR reagents**
**Location:** Reagent PCR hood
- [ ] **With new gloves and disposable lab gown**, treat PCR area with RNAse Away, let dry, then treat with UV light for ~15 minutes.
- [ ] Generate enough PCR master mix for the reactions desired according to **Table 1**. Mix gently.
  * Note 1: The reaction mix and plate must be kept on ice; otherwise, the exonuclease in the enzyme can degrade the primers prior to the start of the reaction.
  * Note 2: **Barcoding does not have to be a qPCR.** Replace SYBR Green volume with more nuclease-free wtaer if running as a regular PCR.
- [ ] Aliquot 35 uL mix into each well.
- [ ] Add 10 uL premixed barcoding oligos to each well.
- [ ] Seal plate with foil seal.

*Table 1. Indexing qPCR Master Mix*

|                               | Component          | 1 rxn (uL)   |100 rxns (uL) |
|-------------------------------|--------------------|--------------|--------------|
|2x KAPA HiFi Hotstart ReadyMix |Nuclease-free water |9.5           |950           |
|                               |2X KAPA HiFi HS RM|25.0           |2500            |
|                               |100x SYBR Green|0.3           |50            |
|                               |Total  |35.0           |3500.0           |
|                               |                    |              |              |
|                               | **Component**      |**1 rxn (uL)**|**100 rxns (uL)**|
|5X KAPA HiFi Hotstart + dNTPs  |Nuclease-free water | 22.5          | 2250          |
|                               |5X KAPA HiFi Buffer | 10.0          | 1000          |
|                               |10 mM dNTPs         | 1.5          | 150           |
|                               |100X SYBR Green     | 0.5          | 50           |
|                               |KAPA HiFi polymerase| 0.5          | 50           |
|                               |Total               |35.0           |3500           |

**Add template (dilution of primary PCR products)**
**Location:** Biosafety cabinet (BSC)

- [ ] In the BSC, add 5 uL 1:100 dilution of primary PCR products.
- [ ] Seal plate with optical film.

**Place on qPCR machine**
**Location:** Bay 4
- [ ] Briefly spin down the plate (13 seconds at 1K rpm in bench-top centrifuge).
- [ ] Run (q)PCR with cycling conditions from **Table 2**.
- [ ] Clean up work areas. Replace any consumables that have been used up. Treat PCR hood and BSC with RNAse Away, let dry, then treat with UV light for ~15 minutes.
- [ ] After (q)PCR run is done, transfer places to -20˚C if processing is going to be paused. Otherwise, keep plates at 4˚C.
- [ ] Run 5 uL on an agarose gel or E-gel to confirm amplification

*Table 2. Indexing qPCR Amplification Parameters*

Cycle | Temperature (˚C) | Time
--------|--------|--------
Initial Denaturation | 95 | 3 min
10 cycles: | | 
Denature|98|20 sec
Anneal|55|15 sec
Extend|72|30 sec
Holidng|12|Forever
