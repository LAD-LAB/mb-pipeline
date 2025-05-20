# WI-PA003B Primary qPCR for 12SV5 Sequencing - qPCRA

## Purpose
The purpose of this document is to provide instructions on amplifying 12SV5 for in-house squencing.

## Scope
All persons who perform animal FoodSeq work in the David Lab.

## Associated Documents
  * WI-DEXXX DNA Extraction
  * WI-PA004 Indexing qPCR

## Required reagents, equipment, and consumables
- [ ] Clean PCR hoods: reagent and DNA
- [ ] 96-well optical PCR plate, optical sealing film, and foil seal
- [ ] PCR certified filter pipet tips and pipettors
- [ ] Cooling rack for 96-well plate, ice, and ice bucket
- [ ] Nuclease-free water
- [ ] 2X AccuStart II PCR SuperMix (95137-100, 95137-500, 95137-04K)
- [ ] 10 uM working stock of PCR primers with Illumina bridges for 12SV5 (BP039 and BP040)
  * BP039 (12SV5F-Seq)

   5' TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGTAGAACAGGCTCCTCTA\*G 3'

  * BP040 (12SV5R-Seq)

   5' GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGTTAGATACCCCACTATG\*C 3'

  * Make only as much as you ned as 10 uM primers degrade with multiple freeze thaws.

- [ ] 100 uM working stock of human blocking primer (BP102)

   5' CTATGCTTAGCCCTAAACCTCAACAGTTAAATCAACAAAACTGCT\*/3SpC3/ 3'

- [ ] 20 ug/uL working stock of bovine serum albumin (BSA) (Thermo Fisher B14)
- [ ] SYBR Green I - diluted in filtered DMSO to 100x
- [ ] gDNA from DNA extraction or other source
- [ ] Positive control template DNA (ex// gecko gDNA)

## Instructions
  * Procedure follows on subsequent pages
  * An Excel template for reaction component calculations is available

## Revision History
| Summary of Changes | Date | Version |
| ------------------ | ------------------ | ------------------ |
| N/A - 1st version | 07/18/2022 | 1|

## PROCEDURE
- [ ] Thaw on ice all necessary reagents. Vortex and spin down all **except** the mix containing the polymerase.
- [ ] Wipe Reagent **and** DNA PCR hood are with RNAse Away
- [ ] Set out any necessary plastic consumables or open nuclease-free water containers in each hood to be UV'ed
   Treat **both hoods** with UV light or ~15 minutes.

**Location: Reagent PCR hood**
- [ ] Generate enough PCR master mix for the reactions desired according to **Table 1**.
  * Note: The reaction mix and plate must be kept on ice; otherwise, the exonuclease in the enzyme can degrade the primers prior to the start of the reaction.
- [ ] Aliquot 9 uL mix into each well. Seal with adhesive foil seal.


**Table 1**. Primary qPCR Master Mix.

|Component|1 rxn (uL)| 100 rxns (uL)|
|------ |------ |------ |
|Nuclease-free water| 1.65|165|
| 10 uM forward primer| 0.5| 50|
|10 uM reverse primer| 0.5| 50|
|100 uM blocking primer| 1| 100|
|100X SYBR Green| 0.1| 10|
|20 mg/mL BSA|0.25|25|
|2X AccuStart|5|500|
|**Total**|9|900|

<br>
<br>

**Location: DNA PCR hood**
- [ ] Add 1 uL water to no-template control well.
- [ ] Add 1 μl of DNA template to sample wells.
- [ ] Add 1 ul control DNA to positive control well.
  * Control DNA should be synthetic OR relatively phylogenetically distinct and not (commonly) eaten by humans.
- [ ] Seal plate with optical film.
- [ ] Briefly spin down the plate (13 seconds at 1K rpm in bench-top centrifuge).
- [ ] Run qPCR with cycling conditions from **Table 2**.
- [ ] **RNAse Away and UV both hoods and put away PCR reagents.**
- [ ] After qPCR run is done, transfer plates to -20˚C if processing is going to be paused. Otherwise, keep plates at 4˚C.
- [ ] Inspect qPCR curves to confirm amplification and/or run 2 ul on an agarose gel or E-gel to confirm a single band of expected size.
- [ ] Proceed to WI-PA004.

**Table 2**. qPCR Cycling Parameters.

Cycle | Temperature (˚C) | Time
--------|--------|--------
Initial Denaturation | 94 | 3 min
35 cycles: | | 
Denature|94|20 sec
Anneal|57|15 sec
Extend|72|1 min
Holidng|12|Forever

