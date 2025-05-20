# WI-PA003 Primary qPCR for trnLGH Sequencing - qPCRA

## Purpose
The purpose of this document is to provide instructions on amplifying trnLGH for in-house sequencing.

## Scope
All persons who perform plant FoodSeq work in the David Lab.

## Associated Documents
  * WI-DEXXX DNA Extraction
  * WI-PA004 Indexing qPCR

## Required reagents, equipment, and consumables
- [ ] Clean PCR hoods: reagent and DNA
- [ ] 96-well optical PCR plate, optical sealing film, and foil seals
- [ ] PCR certified filter pipet tips and pipettors
- [ ] Cooling rack for 96-well plate, ice, and ice bucket
- [ ] Nuclease-free water
- [ ] PCR primers with Illumina bridges for trnLGH (BP031 and BP032) at 10 uM working concentration, diluted with IDTE pH 8.0

  * BP031 (trnL(UAA)g-Sq)

   5' TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGGGCAATCCTGAGCCA\*A 3'

  * BP032 (trnL(UAA)h-Seq)

   5' GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGCCATTGAGTCTCTGCACCTAT\*C 3'

  * Make only as much as you ned as 10 uM primers degrade with multiple freeze thaws.

- [ ] Aliquot(s) of KAPA HiFi HotStart plus dNTPs (7958897001/KK2502) **OR KAPA HiFi HotStart ReadyMix (7958935001/KK2602)**

   The dNTP kit (also referred to as "individual components") is more temperature-sensitive. The lab has had issues with kits going bad because of this. As of July 2022, Dr. David prefers the ReadyMix to avoid issues with PCR.

   Using individual components allows for the adjustment of polymerase which redues primer dimers.

- [ ] SYBR Green I - diluted in filtered DMSO to 100x
- [ ] gDNA from DNA extraction or other source
- [ ] Positive control template DNA

   
## Instructions
  * Procedure follows on subsequent pages
  * An Excel template for reaction component calculations is available

## Revision History
| Summary of Changes | Date | Version |
| ------------------ | ------------------ | ------------------ |
| N/A - 1st version | 2022/07/18 | 1|
|Reduced primer concentration from 0.5 to 0.3 uL | 2023/01/19 | 2 |

## PROCEDURE
- [ ] Thaw on ice all necessary reagents. Vortex and spin down all **except** the mix containing the polymerase
- [ ] Wipe Reagent **and** DNA PCR hood are with RNAse Away
- [ ] Set out any necessary plastic consumables or open nuclease-free water containers in each hood to be UV'ed
- [ ] Treat **both hoods** with UV light or ~15 minutes.

**Location: Reagent PCR hood**
- [ ] Generate enough PCR master mix for the reactions desired according to **Table 1**.
  * Note: The reaction mix and plate must be kept on ice; otherwise, the exonuclease in the enzyme can degrade the primers prior to the start of the reaction.
- [ ] Aliquot 7 uL mix into each well.
- [ ] Seal plate and move to DNA room.


**Table 1**. Primary qPCR Master Mix.

|                               | Component          | 1 rxn (uL)   |100 rxns (uL) |
|-------------------------------|--------------------|--------------|--------------|
|2x KAPA HiFi Hotstart ReadyMix |Nuclease-free water |1.3           |130           |
|                               |10 uM Forward primer|0.3           |30            |
|                               |10 uM Reverse primer|0.3           |30            |
|                               |2X KAPA HiFi HS RM  |5.0           |500           |
|                               |100X SYBR Green     |0.1           |10            |
|                               |Total               |7.0           |700           |
|                               |                    |              |              |
|                               | **Component**      |**1 rxn (uL)**|**100 rxns (uL)**|
|5X KAPA HiFi Hotstart + dNTPs  |Nuclease-free water | 3.5          | 350          |
|                               |10 uM Forward primer| 0.5          | 50           |
|                               |10 uM Reverse primer| 0.5          | 50           |
|                               |5X KAPA HiFi Buffer | 2.0          | 200          |
|                               |10 mM dNTPs         | 0.3          | 30           |
|                               |100X SYBR Green     | 0.1          | 10           |
|                               |KAPA HiFi polymerase| 0.1          | 10           |
|                               |Total               |7.0           |700           |



**Location: DNA PCR hood**
- [ ] Add 3 uL nuclease-free water to no-template control wells.
- [ ] Add 3 μl of DNA template to sample wells.
- [ ] Add 3 ul control DNA to positive control well(s).
  * Control DNA should be synthetic OR relatively phylogenetically distinct and not (commonly) eaten by humans
- [ ] Seal plate with optical film.
- [ ] Briefly spin down the plate (13 seconds at 1K rpm in bench-top centrifuge).
- [ ] Run qPCR with cycling conditions from **Table 2**.
- [ ] **RNAse Away and UV both hoods and put away PCR reagents.**
- [ ] After qPCR run is done, transfer plates to -20˚C if processing is going to be paused for more than one day. Otherwise, keep plates at 4˚C.
- [ ] Inspect qPCR curves to confirm amplification and/or run 2 ul on an agarose gel or E-gel to confirm a single band of expected size.
- [ ] Proceed to WI-PA004.

**Table 2**. Primary qPCR Amplification Parameters.


Cycle | Temperature (˚C) | Time
--------|--------|--------
Initial Denaturation | 95 | 3 min
35 cycles: | | 
Denature|98|20 sec
Anneal|63|15 sec
Extend|72|15 sec
Holidng|12|Forever


